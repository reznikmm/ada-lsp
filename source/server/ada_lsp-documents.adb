--  Copyright (c) 2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with League.Strings;

with Ada_LSP.Ada_Lexers;

package body Ada_LSP.Documents is

   -------------------
   -- Apply_Changes --
   -------------------

   not overriding procedure Apply_Changes
     (Self   : aliased in out Document;
      Vector : LSP.Messages.TextDocumentContentChangeEvent_Vector)
   is
      Now : constant Incr.Version_Trees.Version := Self.History.Changing;
   begin
      --  FIX ME Sort Vector before applying?
      for Change of reverse Vector loop
         declare
            use type Incr.Nodes.Tokens.Token_Access;

            Text  : League.Strings.Universal_String;
            First : Incr.Nodes.Tokens.Token_Access;
            Last  : Incr.Nodes.Tokens.Token_Access;
            First_Offset : LSP.Types.UTF_16_Index;
            Last_Offset  : LSP.Types.UTF_16_Index;
         begin
            Self.Find_Token (Change.span.Value.first, First, First_Offset);
            Self.Find_Token (Change.span.Value.last, Last, Last_Offset);

            if First = Last then
               Text := First.Text (Now);
               Text.Replace
                 (Low  => Natural (First_Offset) + 1,
                  High => Natural (Last_Offset),
                  By   => Change.text);
               First.Set_Text (Text);
            else
               Text := First.Text (Now);
               Text.Replace
                 (Low  => Natural (First_Offset) + 1,
                  High => Text.Length,
                  By   => Change.text);
               First.Set_Text (Text);

               Text := Last.Text (Now);
               Text.Replace
                 (Low  => 1,
                  High => Natural (Last_Offset),
                  By   => League.Strings.Empty_Universal_String);
               Last.Set_Text (Text);
               Last := Last.Previous_Token (Now);

               while Last /= First loop
                  Last.Set_Text (League.Strings.Empty_Universal_String);
                  Last := Last.Previous_Token (Now);
               end loop;
            end if;
         end;
      end loop;

      Self.Commit;
   end Apply_Changes;

   ---------------
   -- Find_Line --
   ---------------

   not overriding function Find_Line
     (Self : Document;
      Line : LSP.Types.Line_Number) return Incr.Nodes.Tokens.Token_Access
   is
      Target : constant Positive := Natural (Line);
      Now    : constant Incr.Version_Trees.Version := Self.History.Changing;
      Node   : Incr.Nodes.Node_Access := Self.Ultra_Root;
      Child  : Incr.Nodes.Node_Access;
      Offset : Natural := 0;
      Span   : Natural;
   begin
      while not Node.Is_Token loop
         for J in 1 .. Node.Arity loop
            Child := Node.Child (J, Now);
            Span := Child.Span (Incr.Nodes.Line_Count, Now);
            if Offset + Span < Target then
               Offset := Offset + Span;
            else
               Node := Child;
               exit;
            end if;
         end loop;
      end loop;

      return Incr.Nodes.Tokens.Token_Access (Node).Next_Token (Now);
   end Find_Line;

   ----------------
   -- Find_Token --
   ----------------

   not overriding procedure Find_Token
     (Self   : Document;
      Place  : LSP.Messages.Position;
      Token  : out Incr.Nodes.Tokens.Token_Access;
      Offset : out LSP.Types.UTF_16_Index)
   is
      use type Ada_LSP.Ada_Lexers.Token;
      use type Incr.Nodes.Tokens.Token_Access;
      use type LSP.Types.UTF_16_Index;

      Now : constant Incr.Version_Trees.Version := Self.History.Changing;
   begin
      Offset := Place.character;
      Token := Self.Find_Line (Place.line);

      while Token /= null
        and then Ada_LSP.Ada_Lexers.Token (Token.Kind) /=
                    Ada_LSP.Ada_Lexers.New_Line_Token
      loop
         declare
            Span : constant LSP.Types.UTF_16_Index := LSP.Types.UTF_16_Index
              (Token.Span (Incr.Nodes.Text_Length, Now));
         begin
            exit when Offset < Span;
            Offset := Offset - Span;
            Token := Token.Next_Token (Now);
         end;
      end loop;
   end Find_Token;

   ----------------
   -- Initialize --
   ----------------

   not overriding procedure Initialize
     (Self : in out Document;
      Item : LSP.Messages.TextDocumentItem)
   is
      Root : Incr.Nodes.Node_Access;
      Kind : Incr.Nodes.Node_Kind;
   begin
      Self.Factory.Create_Node
        (Prod     => 2,
         Children => (1 .. 0 => <>),
         Node     => Root,
         Kind     => Kind);

      Incr.Documents.Constructors.Initialize (Self, Root);
      Self.End_Of_Stream.Set_Text (Item.text);
      Self.Commit;
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
      Self.Reference := Self.History.Changing;
      Self.Commit;
   end Update;

end Ada_LSP.Documents;
