--  Copyright (c) 2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with League.String_Vectors;
with League.Strings;

with Ada_LSP.Documents.Debug;

package body Ada_LSP.Documents is

   function "+" (Text : Wide_Wide_String)
      return League.Strings.Universal_String renames
       League.Strings.To_Universal_String;

   function Token_Column
     (Token : Incr.Nodes.Tokens.Token_Access;
      Time  : Incr.Version_Trees.Version) return LSP.Types.UTF_16_Index;

   Error_Message : constant LSP.Types.LSP_String := +"Syntax error";

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
            First_Offset : Positive;
            Last_Offset  : Positive;
            First_Extra  : LSP.Types.UTF_16_Index;
            Last_Extra   : LSP.Types.UTF_16_Index;
         begin
            Self.Find_Token
              (Line   => Change.span.Value.first.line,
               Column => Change.span.Value.first.character,
               Time   => Now,
               Token  => First,
               Offset => First_Offset,
               Extra  => First_Extra);

            Self.Find_Token
              (Line   => Change.span.Value.last.line,
               Column => Change.span.Value.last.character,
               Time   => Now,
               Token  => Last,
               Offset => Last_Offset,
               Extra  => Last_Extra);

            if First = Last then
               if First = null then
                  First := Self.End_Of_Stream;
               end if;

               Text := First.Text (Now);
               Text.Replace
                 (Low  => First_Offset,
                  High => Last_Offset - 1,
                  By   => Change.text);
               First.Set_Text (Text);
            else
               Text := First.Text (Now);
               Text.Replace
                 (Low  => First_Offset,
                  High => Text.Length,
                  By   => Change.text);
               First.Set_Text (Text);

               Text := Last.Text (Now);
               Text.Replace
                 (Low  => 1,
                  High => Last_Offset - 1,
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

   ----------------
   -- Get_Errors --
   ----------------

   not overriding procedure Get_Errors
     (Self   : Document;
      Errors : out LSP.Messages.Diagnostic_Vector)
   is
      procedure Collect_Errors
        (Node   : not null Incr.Nodes.Node_Access;
         Line   : Natural;
         Time   : Incr.Version_Trees.Version);

      --------------------
      -- Collect_Errors --
      --------------------

      procedure Collect_Errors
        (Node   : not null Incr.Nodes.Node_Access;
         Line   : Natural;
         Time   : Incr.Version_Trees.Version)
      is
         Child       : Incr.Nodes.Node_Access;
         Next_Line   : Natural := Line;
      begin
         if Node.Local_Errors (Time) then
            if Node.Is_Token then
               declare
                  use type LSP.Types.Line_Number;
                  use type LSP.Types.UTF_16_Index;

                  Token : constant Incr.Nodes.Tokens.Token_Access :=
                    Incr.Nodes.Tokens.Token_Access (Node);
                  Text : constant League.Strings.Universal_String :=
                    Token.Text (Time);
                  List : constant League.String_Vectors.Universal_String_Vector
                    := Text.Split (Incr.Nodes.LF);
                  Error : LSP.Messages.Diagnostic;
                  Span  : LSP.Messages.Span renames Error.span;
               begin
                  Span.first.line := LSP.Types.Line_Number (Line);
                  Span.first.character := Token_Column (Token, Time);

                  if List.Length > 1 then
                     Span.last.line := Span.first.line +
                       LSP.Types.Line_Number (List.Length - 1);
                     Span.last.character :=
                       LSP.Types.UTF_16_Index (List (List.Length).Length);
                  else
                     Span.last.line := Span.first.line;
                     Span.last.character := Span.first.character +
                       LSP.Types.UTF_16_Index (Text.Length);
                  end if;

                  Error.message := Error_Message;
                  Errors.Append (Error);
               end;
            end if;
         end if;

         if not Node.Nested_Errors (Time) then
            return;
         end if;

         for J in 1 .. Node.Arity loop
            Child := Node.Child (J, Time);

            if Child.Nested_Errors (Time) or Child.Local_Errors (Time) then
               Collect_Errors (Child, Next_Line, Time);
            end if;

            Next_Line := Next_Line + Child.Span (Incr.Nodes.Line_Count, Time);
         end loop;
      end Collect_Errors;

   begin
      Collect_Errors (Self.Ultra_Root, 0, Self.Reference);
   end Get_Errors;

   ----------------
   -- Find_Token --
   ----------------

   not overriding procedure Find_Token
     (Self   : Document;
      Line   : LSP.Types.Line_Number;
      Column : LSP.Types.UTF_16_Index;
      Time   : Incr.Version_Trees.Version;
      Token  : out Incr.Nodes.Tokens.Token_Access;
      Offset : out Positive;
      Extra  : out LSP.Types.UTF_16_Index)
   is
      use type Incr.Nodes.Node_Access;
      use type Incr.Nodes.Tokens.Token_Access;
      use type LSP.Types.UTF_16_Index;

      function Get_Rest
        (Text : League.Strings.Universal_String) return Natural;
      --  Number of characters in Text from Offset till LF or end of Text

      --------------
      -- Get_Rest --
      --------------

      function Get_Rest
        (Text : League.Strings.Universal_String) return Natural
      is
         Last : Natural := Text.Index (Offset, Incr.Nodes.LF);
      begin
         if Last = 0 then
            Last := Text.Length;
         else
            Last := Last - 1;
         end if;

         return Last - Offset + 1;
      end Get_Rest;

      Rest   : Natural;
      Text   : League.Strings.Universal_String;
      Node   : Incr.Nodes.Node_Access := Self.Ultra_Root;
      Skip   : Natural := Natural (Line);  --  N of lines or chars to skip
      Child  : Incr.Nodes.Node_Access;
      Span   : Natural;
   begin
      Offset := 1;
      Extra := Column;

      while Token = null and Node /= null loop
         for J in 1 .. Node.Arity loop
            Child := Node.Child (J, Time);
            Span := Child.Span (Incr.Nodes.Line_Count, Time);

            if Skip <= Span then
               if Child.Is_Token then
                  Token := Incr.Nodes.Tokens.Token_Access (Child);
               else
                  Node := Child;
               end if;

               exit;
            elsif J = Node.Arity then
               Node := null;
            else
               Skip := Skip - Span;
            end if;
         end loop;
      end loop;

      if Token = null then  --  No such a line
         return;
      else
         --  Find Offset of the first character in the line
         Text := Token.Text (Time);
         while Skip > 0 loop
            Offset := Text.Index (Offset, Incr.Nodes.LF) + 1;
            Skip := Skip - 1;
         end loop;
      end if;

      while Extra > 0 loop
         Rest := Get_Rest (Text);

         if Rest >= Positive (Extra) then
            Offset := Offset + Positive (Extra);
            Extra := 0;
         else
            Offset := Offset + Rest;
            Extra := Extra - LSP.Types.UTF_16_Index (Rest);

            if Offset > Text.Length then
               Token := Token.Next_Token (Time);
               Text := Token.Text (Time);
               Offset := 1;
            else  --  We have found LF before Column exceeded
               exit;
            end if;
         end if;
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

   ------------------
   -- Token_Column --
   ------------------

   function Token_Column
     (Token : Incr.Nodes.Tokens.Token_Access;
      Time  : Incr.Version_Trees.Version) return LSP.Types.UTF_16_Index
   is
      use type Incr.Nodes.Tokens.Token_Access;
      use type LSP.Types.UTF_16_Index;

      Result : LSP.Types.UTF_16_Index := 0;
      Prev   : Incr.Nodes.Tokens.Token_Access := Token.Previous_Token (Time);
   begin
      while Prev /= null loop
         declare
            Text : constant League.Strings.Universal_String :=
              Prev.Text (Time);
            List : constant League.String_Vectors.Universal_String_Vector :=
              Text.Split (Incr.Nodes.LF);
         begin
            if List.Length > 1 then
               Result := Result + LSP.Types.UTF_16_Index
                 (List (List.Length).Length);

               exit;
            else
               Result := Result + LSP.Types.UTF_16_Index
                 (Prev.Span (Incr.Nodes.Text_Length, Time));
            end if;
         end;

         Prev := Prev.Previous_Token (Time);
      end loop;

      return Result;
   end Token_Column;

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
      Ada_LSP.Documents.Debug.Dump (Self, "before.xml", Provider.all);
      Parser.Run
        (Lexer     => Lexer,
         Provider  => Provider,
         Factory   => Self.Factory'Unchecked_Access,
         Document  => Self'Unchecked_Access,
         Reference => Self.Reference);
      Self.Reference := Self.History.Changing;
      Self.Commit;
      Ada_LSP.Documents.Debug.Dump (Self, "after.xml", Provider.all);
   end Update;

end Ada_LSP.Documents;
