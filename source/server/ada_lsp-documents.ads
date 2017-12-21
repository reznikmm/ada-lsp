--  Copyright (c) 2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

private with Ada.Containers.Hashed_Sets;
private with Incr.Nodes.Hash;

with LSP.Messages;
with LSP.Types;

with Ada_LSP.Ada_Parser_Data;
limited with Ada_LSP.Completions;

with Incr.Documents;
with Incr.Lexers.Incremental;
with Incr.Nodes.Tokens;
with Incr.Parsers.Incremental;
with Incr.Version_Trees;

package Ada_LSP.Documents is

   type Document is new Incr.Documents.Document with private;
   type Document_Access is access all Ada_LSP.Documents.Document;
   type Constant_Document_Access is access constant Ada_LSP.Documents.Document;

   not overriding procedure Initialize
     (Self : in out Document;
      Item : LSP.Messages.TextDocumentItem);

   not overriding procedure Update
     (Self     : aliased in out Document;
      Parser   : Incr.Parsers.Incremental.Incremental_Parser;
      Lexer    : Incr.Lexers.Incremental.Incremental_Lexer_Access;
      Provider : access Ada_LSP.Ada_Parser_Data.Provider'Class);
   --  Reparse document

   not overriding procedure Apply_Changes
     (Self   : aliased in out Document;
      Vector : LSP.Messages.TextDocumentContentChangeEvent_Vector);

   not overriding procedure Get_Errors
     (Self   : Document;
      Errors : out LSP.Messages.Diagnostic_Vector);

   not overriding procedure Get_Symbols
     (Self   : Document;
      Result : out LSP.Messages.SymbolInformation_Vector);

   not overriding procedure Get_Completion_Context
     (Self     : Document;
      Place    : LSP.Messages.Position;
      Result   : in out Ada_LSP.Completions.Context);

private

   package Node_Sets is new Ada.Containers.Hashed_Sets
     (Element_Type        => Incr.Nodes.Node_Access,
      Hash                => Incr.Nodes.Hash,
      Equivalent_Elements => Incr.Nodes."=",
      "="                 => Incr.Nodes."=");

   type Document is new Incr.Documents.Document with record
      URI       : LSP.Messages.DocumentUri;
      Symbols   : Node_Sets.Set;
      Reference : Incr.Version_Trees.Version;
      Factory   : aliased Ada_LSP.Ada_Parser_Data.Node_Factory
        (Document'Unchecked_Access);
   end record;

   not overriding procedure Find_Token
     (Self   : Document;
      Line   : LSP.Types.Line_Number;
      Column : LSP.Types.UTF_16_Index;
      Time   : Incr.Version_Trees.Version;
      Token  : out Incr.Nodes.Tokens.Token_Access;
      Offset : out Positive;
      Extra  : out LSP.Types.UTF_16_Index);
   --  Find Token spanning over given Line:Column.
   --  Set Offset to corresponding index in Token.Text (Time).
   --  If Line exceeds total line count return null Token.
   --  If Column exceeds line length return last Token in the line and set
   --  Extra to exceed count.

   not overriding procedure Update_Symbols
     (Self      : in out Document;
      Provider  : access Ada_LSP.Ada_Parser_Data.Provider'Class;
      Reference : Incr.Version_Trees.Version;
      Node      : Incr.Nodes.Node_Access);

end Ada_LSP.Documents;
