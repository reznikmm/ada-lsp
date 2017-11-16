--  Copyright (c) 2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with Ada.Streams;
with Ada.Characters.Wide_Wide_Latin_1;
with League.Stream_Element_Vectors;
with League.Strings;
with League.Text_Codecs;
with League.String_Vectors;

package body Checkers is

   function "+" (Text : Wide_Wide_String)
      return League.Strings.Universal_String renames
       League.Strings.To_Universal_String;

   Pattern : constant Wide_Wide_String :=
     "^(..[^\:]*)\:([0-9]+)\:(([0-9]+)\:)?\ ((warning\:|\(style\))?.*)";
   --  1           2         34             56

   type Capture_Kinds is
     (File_Name, Line, Column_Group, Column, Message, Warning);

   pragma Unreferenced (Column_Group);

   type Capture_Array is
     array (Capture_Kinds) of League.Strings.Universal_String;

   procedure Decode
     (Got  : Capture_Array;
      File : out LSP.Types.LSP_String;
      Item : out LSP.Messages.Diagnostic);

   ------------
   -- Decode --
   ------------

   procedure Decode
     (Got  : Capture_Array;
      File : out LSP.Types.LSP_String;
      Item : out LSP.Messages.Diagnostic)
   is
      From  : constant Positive := Positive'Wide_Wide_Value
        (Got (Line).To_Wide_Wide_String);
      Col   : Positive := 1;
   begin
      File := Got (File_Name);

      if not Got (Column).Is_Empty then
         Col := Positive'Wide_Wide_Value
           (Got (Column).To_Wide_Wide_String);
      end if;

      Item.span :=
        (first =>
           (LSP.Types.Line_Number (From - 1),
            LSP.Types.UTF_16_Index (Col - 1)),
         last =>
           (LSP.Types.Line_Number (From - 1),
            LSP.Types.UTF_16_Index (Col - 1)));

      if Got (Warning).Is_Empty then
         Item.severity := (True, LSP.Messages.Error);
      elsif Got (Warning).Starts_With ("warning") then
         Item.severity := (True, LSP.Messages.Warning);
      elsif Got (Warning).Starts_With ("(style)") then
         Item.severity := (True, LSP.Messages.Hint);
      end if;

      Item.message := Got (Message);
      Item.source := (True, +"Compiler");
   end Decode;

   ----------------
   -- Initialize --
   ----------------

   not overriding procedure Initialize
     (Self    : in out Checker;
      Project : LSP.Types.LSP_String) is
   begin
      Self.Project := Project;
      Self.Pattern := League.Regexps.Compile (+Pattern);
      Self.Compiler := GNAT.OS_Lib.Locate_Exec_On_Path ("gprbuild");
   end Initialize;

   ---------
   -- Run --
   ---------

   not overriding procedure Run
     (Self   : in out Checker;
      File   : LSP.Types.LSP_String;
      Result : in out LSP.Messages.Diagnostic_Vector)
   is
      Data   : League.Stream_Element_Vectors.Stream_Element_Vector;
      Input  : GNAT.OS_Lib.File_Descriptor;
      Name   : aliased String := File.To_UTF_8_String;
      U      : aliased String := "-u";
      F      : aliased String := "-f";
      C      : aliased String := "-c";
      P      : aliased String := "-P";
      GPR    : aliased String := Self.Project.To_UTF_8_String;
      Args   : constant GNAT.OS_Lib.Argument_List (1 .. 6) :=
        (U'Unchecked_Access,
         F'Unchecked_Access,
         C'Unchecked_Access,
         P'Unchecked_Access,
         GPR'Unchecked_Access,
         Name'Unchecked_Access);
      Code   : Integer;
   begin
      Input := GNAT.OS_Lib.Create_File
        ("/tmp/ada-lsp.log", GNAT.OS_Lib.Binary);
      GNAT.OS_Lib.Spawn
        (Program_Name           => Self.Compiler.all,
         Args                   => Args,
         Output_File_Descriptor => Input,
         Return_Code            => Code);

      Input := GNAT.OS_Lib.Open_Read
        ("/tmp/ada-lsp.log", GNAT.OS_Lib.Binary);
      loop
         declare
            use type Ada.Streams.Stream_Element_Offset;
            Buffer : Ada.Streams.Stream_Element_Array (1 .. 512);
            Last   : Ada.Streams.Stream_Element_Offset;
         begin
            Last := Ada.Streams.Stream_Element_Offset
              (GNAT.OS_Lib.Read (Input, Buffer'Address, Buffer'Length));

            Data.Append (Buffer (1 .. Last));

            exit when Last /= Buffer'Length;
         end;
      end loop;

      declare
         Text   : constant League.Strings.Universal_String :=
           League.Text_Codecs.Codec_For_Application_Locale.Decode (Data);

         Lines  : constant League.String_Vectors.Universal_String_Vector :=
           Text.Split (Ada.Characters.Wide_Wide_Latin_1.LF);

      begin
         for J in 1 .. Lines.Length loop
            declare
               Name  : LSP.Types.LSP_String;
               Item  : LSP.Messages.Diagnostic;
               Got   : Capture_Array;
               Match : constant League.Regexps.Regexp_Match :=
                 Self.Pattern.Find_Match (Lines (J));
            begin
               if Match.Is_Matched then
                  for J in Got'Range loop
                     Got (J) := Match.Capture (Capture_Kinds'Pos (J) + 1);
                  end loop;
                  Decode (Got, Name, Item);
                  Result.Append (Item);
               end if;
            end;
         end loop;
      end;
   end Run;

end Checkers;
