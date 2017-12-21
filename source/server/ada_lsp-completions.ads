--  Copyright (c) 2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with LSP.Messages;

with Incr.Nodes.Tokens;

with Ada_LSP.Documents;

package Ada_LSP.Completions is

   type Context is tagged limited private;

   not overriding function Token
     (Self : Context) return Incr.Nodes.Tokens.Token_Access;

   not overriding function Document
     (Self : Context) return Ada_LSP.Documents.Constant_Document_Access;

   not overriding procedure Set_Token
     (Self   : in out Context;
      Token  : Incr.Nodes.Tokens.Token_Access;
      Offset : Positive);

   not overriding procedure Set_Document
     (Self   : in out Context;
      Value  : Ada_LSP.Documents.Constant_Document_Access);

   type Handler is limited interface;
   type Handler_Access is access all Handler'Class;

   not overriding procedure Fill_Completion_List
     (Self    : Handler;
      Context : Ada_LSP.Completions.Context'Class;
      Result  : in out LSP.Messages.CompletionList) is abstract;

private
   type Context is tagged limited record
      Document : Ada_LSP.Documents.Constant_Document_Access;
      Token    : Incr.Nodes.Tokens.Token_Access;
      Offset   : Positive := 1;
   end record;

end Ada_LSP.Completions;
