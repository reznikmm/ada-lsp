--  Copyright (c) 2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with Ada.Containers.Hashed_Maps;
with League.Strings.Hash;
package body Ada_LSP.Ada_Lexers is

   package body Tables is separate;

   package Maps is new Ada.Containers.Hashed_Maps
     (Key_Type        => League.Strings.Universal_String,
      Element_Type    => Token,
      Hash            => League.Strings.Hash,
      Equivalent_Keys => League.Strings."=",
      "="             => Incr.Lexers.Batch_Lexers."=");

   Default    : constant Incr.Lexers.Batch_Lexers.State := 0;
   Apostrophe : constant Incr.Lexers.Batch_Lexers.State := 87;

   Map : Maps.Map;

   --  Our batch lexer return token codes in this order:
   Convert : constant array (Token range 1 .. 107) of Token :=
     (Arrow_Token,
      Double_Dot_Token,
      Double_Star_Token,
      Assignment_Token,
      Inequality_Token,
      Greater_Or_Equal_Token,
      Less_Or_Equal_Token,
      Left_Label_Token,
      Right_Label_Token,
      Box_Token,
      Ampersand_Token,
      Apostrophe_Token,
      Left_Parenthesis_Token,
      Right_Parenthesis_Token,
      Star_Token,
      Plus_Token,
      Comma_Token,
      Hyphen_Token,
      Dot_Token,
      Slash_Token,
      Colon_Token,
      Semicolon_Token,
      Less_Token,
      Equal_Token,
      Greater_Token,
      Vertical_Line_Token,

      Identifier_Token,
      Numeric_Literal_Token,
      Character_Literal_Token,
      String_Literal_Token,
      Comment_Token,
      Space_Token,
      New_Line_Token,
      Error_Token,

      Abort_Token,
      Abs_Token,
      Abstract_Token,
      Accept_Token,
      Access_Token,
      Aliased_Token,
      All_Token,
      And_Token,
      Array_Token,
      At_Token,
      Begin_Token,
      Body_Token,
      Case_Token,
      Constant_Token,
      Declare_Token,
      Delay_Token,
      Delta_Token,
      Digits_Token,
      Do_Token,
      Else_Token,
      Elsif_Token,
      End_Token,
      Entry_Token,
      Exception_Token,
      Exit_Token,
      For_Token,
      Function_Token,
      Generic_Token,
      Goto_Token,
      If_Token,
      In_Token,
      Interface_Token,
      Is_Token,
      Limited_Token,
      Loop_Token,
      Mod_Token,
      New_Token,
      Not_Token,
      Null_Token,
      Of_Token,
      Or_Token,
      Others_Token,
      Out_Token,
      Overriding_Token,
      Package_Token,
      Pragma_Token,
      Private_Token,
      Procedure_Token,
      Protected_Token,
      Raise_Token,
      Range_Token,
      Record_Token,
      Rem_Token,
      Renames_Token,
      Requeue_Token,
      Return_Token,
      Reverse_Token,
      Select_Token,
      Separate_Token,
      Some_Token,
      Subtype_Token,
      Synchronized_Token,
      Tagged_Token,
      Task_Token,
      Terminate_Token,
      Then_Token,
      Type_Token,
      Until_Token,
      Use_Token,
      When_Token,
      While_Token,
      With_Token,
      Xor_Token);

   overriding procedure Get_Token
     (Self   : access Batch_Lexer;
      Result : out Incr.Lexers.Batch_Lexers.Rule_Index)
   is
      use type Incr.Lexers.Batch_Lexers.Rule_Index;
      use type Incr.Lexers.Batch_Lexers.State;
      Start : constant Incr.Lexers.Batch_Lexers.State :=
        Self.Get_Start_Condition;
   begin
      if Start = Apostrophe then
         Self.Set_Start_Condition (Default);
      end if;

      Base_Lexers.Batch_Lexer (Self.all).Get_Token (Result);

      if Result = 34 then
         Result := Vertical_Line_Token;
      elsif Result = 35 then
         Result := Numeric_Literal_Token;
      elsif Result = 36 then
         Result := String_Literal_Token;
      elsif Result > 36 then
         Result := Error_Token;
      elsif Result = 27 then
         declare
            Text   : constant League.Strings.Universal_String :=
              Self.Get_Text.To_Casefold;
            Cursor : constant Maps.Cursor := Map.Find (Text);
         begin
            if Maps.Has_Element (Cursor) then
               Result := Maps.Element (Cursor);

               if Start = Apostrophe and Result /= Range_Token then
                  Result := Identifier_Token;
               end if;
            else
               Result := Identifier_Token;
            end if;
         end;
      elsif Result > 0 then
         Result := Convert (Result);
      end if;

      if Result = Apostrophe_Token then
         Self.Set_Start_Condition (Apostrophe);
      else
         Self.Set_Start_Condition (Default);
      end if;
   end Get_Token;

   function "+" (V : Wide_Wide_String) return League.Strings.Universal_String
     renames League.Strings.To_Universal_String;
begin
   Map.Insert (+"abort", Abort_Token);
   Map.Insert (+"abs", Abs_Token);
   Map.Insert (+"abstract", Abstract_Token);
   Map.Insert (+"accept", Accept_Token);
   Map.Insert (+"access", Access_Token);
   Map.Insert (+"aliased", Aliased_Token);
   Map.Insert (+"all", All_Token);
   Map.Insert (+"and", And_Token);
   Map.Insert (+"array", Array_Token);
   Map.Insert (+"at", At_Token);
   Map.Insert (+"begin", Begin_Token);
   Map.Insert (+"body", Body_Token);
   Map.Insert (+"case", Case_Token);
   Map.Insert (+"constant", Constant_Token);
   Map.Insert (+"declare", Declare_Token);
   Map.Insert (+"delay", Delay_Token);
   Map.Insert (+"delta", Delta_Token);
   Map.Insert (+"digits", Digits_Token);
   Map.Insert (+"do", Do_Token);
   Map.Insert (+"else", Else_Token);
   Map.Insert (+"elsif", Elsif_Token);
   Map.Insert (+"end", End_Token);
   Map.Insert (+"entry", Entry_Token);
   Map.Insert (+"exception", Exception_Token);
   Map.Insert (+"exit", Exit_Token);
   Map.Insert (+"for", For_Token);
   Map.Insert (+"function", Function_Token);
   Map.Insert (+"generic", Generic_Token);
   Map.Insert (+"goto", Goto_Token);
   Map.Insert (+"if", If_Token);
   Map.Insert (+"in", In_Token);
   Map.Insert (+"interface", Interface_Token);
   Map.Insert (+"is", Is_Token);
   Map.Insert (+"limited", Limited_Token);
   Map.Insert (+"loop", Loop_Token);
   Map.Insert (+"mod", Mod_Token);
   Map.Insert (+"new", New_Token);
   Map.Insert (+"not", Not_Token);
   Map.Insert (+"null", Null_Token);
   Map.Insert (+"of", Of_Token);
   Map.Insert (+"or", Or_Token);
   Map.Insert (+"others", Others_Token);
   Map.Insert (+"out", Out_Token);
   Map.Insert (+"overriding", Overriding_Token);
   Map.Insert (+"package", Package_Token);
   Map.Insert (+"pragma", Pragma_Token);
   Map.Insert (+"private", Private_Token);
   Map.Insert (+"procedure", Procedure_Token);
   Map.Insert (+"protected", Protected_Token);
   Map.Insert (+"raise", Raise_Token);
   Map.Insert (+"range", Range_Token);
   Map.Insert (+"record", Record_Token);
   Map.Insert (+"rem", Rem_Token);
   Map.Insert (+"renames", Renames_Token);
   Map.Insert (+"requeue", Requeue_Token);
   Map.Insert (+"return", Return_Token);
   Map.Insert (+"reverse", Reverse_Token);
   Map.Insert (+"select", Select_Token);
   Map.Insert (+"separate", Separate_Token);
   Map.Insert (+"some", Some_Token);
   Map.Insert (+"subtype", Subtype_Token);
   Map.Insert (+"synchronized", Synchronized_Token);
   Map.Insert (+"tagged", Tagged_Token);
   Map.Insert (+"task", Task_Token);
   Map.Insert (+"terminate", Terminate_Token);
   Map.Insert (+"then", Then_Token);
   Map.Insert (+"type", Type_Token);
   Map.Insert (+"until", Until_Token);
   Map.Insert (+"use", Use_Token);
   Map.Insert (+"when", When_Token);
   Map.Insert (+"while", While_Token);
   Map.Insert (+"with", With_Token);
   Map.Insert (+"xor", Xor_Token);
end Ada_LSP.Ada_Lexers;
