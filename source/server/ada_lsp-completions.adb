--  Copyright (c) 2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

package body Ada_LSP.Completions is

   --------------
   -- Document --
   --------------

   not overriding function Document
     (Self : Context) return Ada_LSP.Documents.Constant_Document_Access is
   begin
      return Self.Document;
   end Document;

   ------------------
   -- Set_Document --
   ------------------

   not overriding procedure Set_Document
     (Self   : in out Context;
      Value  : Ada_LSP.Documents.Constant_Document_Access) is
   begin
      Self.Document := Value;
   end Set_Document;

   ---------------
   -- Set_Token --
   ---------------

   not overriding procedure Set_Token
     (Self   : in out Context;
      Token  : Incr.Nodes.Tokens.Token_Access;
      Offset : Positive)
   is
   begin
      Self.Token := Token;
      Self.Offset := Offset;
   end Set_Token;

   -----------
   -- Token --
   -----------

   not overriding function Token
     (Self : Context) return Incr.Nodes.Tokens.Token_Access is
   begin
      return Self.Token;
   end Token;

end Ada_LSP.Completions;
