--  Copyright (c) 2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with Ada.Containers.Hashed_Maps;

with League.Strings.Hash;

with LSP.Messages;

with Ada_LSP.Documents;

with Ada_LSP.Ada_Lexers;
with Ada_LSP.Ada_Parser_Data;
with Incr.Lexers.Incremental;
with Incr.Parsers.Incremental;

package Ada_LSP.Contexts is
   type Context is tagged limited private;
   type Document_Access is access all Ada_LSP.Documents.Document;

   not overriding procedure Initialize
     (Self : in out Context;
      Root : League.Strings.Universal_String);

   not overriding procedure Load_Document
     (Self  : in out Context;
      Item  : LSP.Messages.TextDocumentItem);

   not overriding function Get_Document
     (Self : Context;
      URI  : LSP.Messages.DocumentUri) return Document_Access;

   not overriding procedure Update_Document
     (Self : in out Context;
      Item : not null Document_Access);
   --  Reparse document after changes

private

   package Document_Maps is new Ada.Containers.Hashed_Maps
     (Key_Type        => LSP.Messages.DocumentUri,
      Element_Type    => Document_Access,
      Hash            => League.Strings.Hash,
      Equivalent_Keys => League.Strings."=");

   type Context is tagged limited record
      Root        : League.Strings.Universal_String;
      Documents   : Document_Maps.Map;
      Batch_Lexer : aliased Ada_LSP.Ada_Lexers.Batch_Lexer;
      Incr_Lexer  : aliased Incr.Lexers.Incremental.Incremental_Lexer;
      Incr_Parser : aliased Incr.Parsers.Incremental.Incremental_Parser;
      Provider    : aliased Ada_LSP.Ada_Parser_Data.Provider;
   end record;

end Ada_LSP.Contexts;
