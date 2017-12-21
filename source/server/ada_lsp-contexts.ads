--  Copyright (c) 2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with Ada.Containers.Hashed_Maps;
with Ada.Containers.Doubly_Linked_Lists;

with League.Strings.Hash;

with LSP.Messages;

with Incr.Lexers.Incremental;
with Incr.Nodes;
with Incr.Parsers.Incremental;

with Ada_LSP.Ada_Lexers;
with Ada_LSP.Ada_Parser_Data;
with Ada_LSP.Completions;
with Ada_LSP.Documents;

package Ada_LSP.Contexts is
   type Context is tagged limited private;

   not overriding procedure Initialize
     (Self : in out Context;
      Root : League.Strings.Universal_String);

   not overriding procedure Load_Document
     (Self  : in out Context;
      Item  : LSP.Messages.TextDocumentItem);

   not overriding function Get_Document
     (Self : Context;
      URI  : LSP.Messages.DocumentUri)
        return Ada_LSP.Documents.Document_Access;

   not overriding procedure Update_Document
     (Self : in out Context;
      Item : not null Ada_LSP.Documents.Document_Access);
   --  Reparse document after changes

   not overriding procedure Add_Completion_Handler
     (Self  : in out Context;
      Value : not null Ada_LSP.Completions.Handler_Access);

   not overriding procedure Fill_Completions
     (Self    : Context;
      Context : Ada_LSP.Completions.Context'Class;
      Result  : in out LSP.Messages.CompletionList);

private

   package Document_Maps is new Ada.Containers.Hashed_Maps
     (Key_Type        => LSP.Messages.DocumentUri,
      Element_Type    => Ada_LSP.Documents.Document_Access,
      Hash            => League.Strings.Hash,
      Equivalent_Keys => League.Strings."=",
      "="             => Ada_LSP.Documents."=");

   type Kind_Map is array (Incr.Nodes.Node_Kind range <>) of Boolean;

   type Provider is new Ada_LSP.Ada_Parser_Data.Provider with record
      Is_Defining_Name : Kind_Map (108 .. 120);
   end record;

   overriding function Is_Defining_Name
     (Self : Provider;
      Kind : Incr.Nodes.Node_Kind) return Boolean;

   package Completion_Handler_Lists is new Ada.Containers.Doubly_Linked_Lists
     (Ada_LSP.Completions.Handler_Access, Ada_LSP.Completions."=");

   type Context is tagged limited record
      Root        : League.Strings.Universal_String;
      Documents   : Document_Maps.Map;
      Batch_Lexer : aliased Ada_LSP.Ada_Lexers.Batch_Lexer;
      Incr_Lexer  : aliased Incr.Lexers.Incremental.Incremental_Lexer;
      Incr_Parser : aliased Incr.Parsers.Incremental.Incremental_Parser;
      Provider    : aliased Ada_LSP.Contexts.Provider;
      Completions : Completion_Handler_Lists.List;
   end record;

end Ada_LSP.Contexts;
