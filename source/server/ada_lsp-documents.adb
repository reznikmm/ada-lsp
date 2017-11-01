--  Copyright (c) 2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with Incr.Nodes.Tokens;

package body Ada_LSP.Documents is

   ----------------
   -- Initialize --
   ----------------

   not overriding procedure Initialize
     (Self : in out Document;
      Item : LSP.Messages.TextDocumentItem)
   is
   begin
      Incr.Documents.Constructors.Initialize (Self, null);
      Self.End_Of_Stream.Set_Text (Item.text);
   end Initialize;

   ------------
   -- Update --
   ------------

   not overriding procedure Update
     (Self     : aliased in out Document;
      Parser   : Incr.Parsers.Incremental.Incremental_Parser;
      Lexer    : Incr.Lexers.Incremental.Incremental_Lexer_Access;
      Provider : Incr.Parsers.Incremental.Parser_Data_Providers.
                   Parser_Data_Provider_Access) is
   begin
      Parser.Run
        (Lexer     => Lexer,
         Provider  => Provider,
         Factory   => Self.Factory'Unchecked_Access,
         Document  => Self'Unchecked_Access,
         Reference => Self.Reference);
   end Update;

end Ada_LSP.Documents;
