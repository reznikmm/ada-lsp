--  Copyright (c) 2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with LSP.Messages;
with Incr.Documents;
with Incr.Lexers.Incremental;
with Incr.Parsers.Incremental;
with Incr.Version_Trees;
with Ada_LSP.Ada_Parser_Data;

package Ada_LSP.Documents is

   type Document is new Incr.Documents.Document with private;

   not overriding procedure Initialize
     (Self : in out Document;
      Item : LSP.Messages.TextDocumentItem);

   not overriding procedure Update
     (Self     : aliased in out Document;
      Parser   : Incr.Parsers.Incremental.Incremental_Parser;
      Lexer    : Incr.Lexers.Incremental.Incremental_Lexer_Access;
      Provider : Incr.Parsers.Incremental.Parser_Data_Providers.
        Parser_Data_Provider_Access);

private

   type Document is new Incr.Documents.Document with record
      Reference : Incr.Version_Trees.Version;
      Factory   : aliased Ada_LSP.Ada_Parser_Data.Node_Factory
        (Document'Unchecked_Access);
   end record;

end Ada_LSP.Documents;
