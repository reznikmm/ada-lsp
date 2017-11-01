--  Copyright (c) 2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with Incr.Lexers.Batch_Lexers.Generic_Lexers;
with Matreshka.Internals.Unicode;

package Ada_LSP.Ada_Lexers is

   subtype Token is Incr.Lexers.Batch_Lexers.Rule_Index;

   Abort_Token : constant Token := 1;
   Abs_Token : constant Token := 2;
   Abstract_Token : constant Token := 3;
   Accept_Token : constant Token := 4;
   Access_Token : constant Token := 5;
   Aliased_Token : constant Token := 6;
   All_Token : constant Token := 7;
   Ampersand_Token : constant Token := 8;
   And_Token : constant Token := 9;
   Apostrophe_Token : constant Token := 10;
   Array_Token : constant Token := 11;
   Arrow_Token : constant Token := 12;
   Assignment_Token : constant Token := 13;
   At_Token : constant Token := 14;
   Begin_Token : constant Token := 15;
   Body_Token : constant Token := 16;
   Box_Token : constant Token := 17;
   Case_Token : constant Token := 18;
   Character_Literal_Token : constant Token := 19;
   Colon_Token : constant Token := 20;
   Comma_Token : constant Token := 21;
   Comment_Token : constant Token := 22;
   Constant_Token : constant Token := 23;
   Declare_Token : constant Token := 24;
   Delay_Token : constant Token := 25;
   Delta_Token : constant Token := 26;
   Digits_Token : constant Token := 27;
   Do_Token : constant Token := 28;
   Dot_Token : constant Token := 29;
   Double_Dot_Token : constant Token := 30;
   Double_Star_Token : constant Token := 31;
   Else_Token : constant Token := 32;
   Elsif_Token : constant Token := 33;
   End_Token : constant Token := 34;
   Entry_Token : constant Token := 35;
   Equal_Token : constant Token := 36;
   Error_Token : constant Token := 37;
   Exception_Token : constant Token := 38;
   Exit_Token : constant Token := 39;
   For_Token : constant Token := 40;
   Function_Token : constant Token := 41;
   Generic_Token : constant Token := 42;
   Goto_Token : constant Token := 43;
   Greater_Or_Equal_Token : constant Token := 44;
   Greater_Token : constant Token := 45;
   Hyphen_Token : constant Token := 46;
   Identifier_Token : constant Token := 47;
   If_Token : constant Token := 48;
   In_Token : constant Token := 49;
   Inequality_Token : constant Token := 50;
   Interface_Token : constant Token := 51;
   Is_Token : constant Token := 52;
   Left_Label_Token : constant Token := 53;
   Left_Parenthesis_Token : constant Token := 54;
   Less_Or_Equal_Token : constant Token := 55;
   Less_Token : constant Token := 56;
   Limited_Token : constant Token := 57;
   Loop_Token : constant Token := 58;
   Mod_Token : constant Token := 59;
   New_Line_Token : constant Token := 60;
   New_Token : constant Token := 61;
   Not_Token : constant Token := 62;
   Null_Token : constant Token := 63;
   Numeric_Literal_Token : constant Token := 64;
   Of_Token : constant Token := 65;
   Or_Token : constant Token := 66;
   Others_Token : constant Token := 67;
   Out_Token : constant Token := 68;
   Overriding_Token : constant Token := 69;
   Package_Token : constant Token := 70;
   Plus_Token : constant Token := 71;
   Pragma_Token : constant Token := 72;
   Private_Token : constant Token := 73;
   Procedure_Token : constant Token := 74;
   Protected_Token : constant Token := 75;
   Raise_Token : constant Token := 76;
   Range_Token : constant Token := 77;
   Record_Token : constant Token := 78;
   Rem_Token : constant Token := 79;
   Renames_Token : constant Token := 80;
   Requeue_Token : constant Token := 81;
   Return_Token : constant Token := 82;
   Reverse_Token : constant Token := 83;
   Right_Label_Token : constant Token := 84;
   Right_Parenthesis_Token : constant Token := 85;
   Select_Token : constant Token := 86;
   Semicolon_Token : constant Token := 87;
   Separate_Token : constant Token := 88;
   Slash_Token : constant Token := 89;
   Some_Token : constant Token := 90;
   Space_Token : constant Token := 91;
   Star_Token : constant Token := 92;
   String_Literal_Token : constant Token := 93;
   Subtype_Token : constant Token := 94;
   Synchronized_Token : constant Token := 95;
   Tagged_Token : constant Token := 96;
   Task_Token : constant Token := 97;
   Terminate_Token : constant Token := 98;
   Then_Token : constant Token := 99;
   Type_Token : constant Token := 100;
   Until_Token : constant Token := 101;
   Use_Token : constant Token := 102;
   Vertical_Line_Token : constant Token := 103;
   When_Token : constant Token := 104;
   While_Token : constant Token := 105;
   With_Token : constant Token := 106;
   Xor_Token : constant Token := 107;


   type Batch_Lexer is new Incr.Lexers.Batch_Lexers.Batch_Lexer with private;

   overriding procedure Get_Token
     (Self   : access Batch_Lexer;
      Result : out Incr.Lexers.Batch_Lexers.Rule_Index);

private

   package Tables is
      use Incr.Lexers.Batch_Lexers;

      function To_Class (Value : Matreshka.Internals.Unicode.Code_Point)
        return Character_Class;
      pragma Inline (To_Class);

      function Switch (S : State; Class : Character_Class) return State;
      pragma Inline (Switch);

      function Rule (S : State) return Rule_Index;
      pragma Inline (Rule);

   end Tables;

   package Base_Lexers is new Incr.Lexers.Batch_Lexers.Generic_Lexers
     (To_Class     => Tables.To_Class,
      Switch       => Tables.Switch,
      Rule         => Tables.Rule,
      First_Final  => 34,
      Last_Looping => 64,
      Error_State  => 86);

   type Batch_Lexer is new Base_Lexers.Batch_Lexer with null record;

end Ada_LSP.Ada_Lexers;
