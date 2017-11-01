--  Copyright (c) 2015-2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with Ada.Wide_Wide_Text_IO;
with Ada.Characters.Wide_Wide_Latin_1;

with Ada_Pretty;
with League.Strings;

with Anagram.Grammars.LR;
with Anagram.Grammars.LR_Tables;

procedure Gen.Write_Parser_Data
  (Plain : Anagram.Grammars.Grammar;
   Table : Anagram.Grammars.LR_Tables.Table)
is

   function "+" (Text : Wide_Wide_String)
                 return League.Strings.Universal_String
                 renames League.Strings.To_Universal_String;

   function AD_Init return Ada_Pretty.Node_Access;
   function SD_Init return Ada_Pretty.Node_Access;
   function CD_Init return Ada_Pretty.Node_Access;
   function NT_Init return Ada_Pretty.Node_Access;
   function Name_Case return Ada_Pretty.Node_Access;
   function To_Kind
     (Index : Anagram.Grammars.Non_Terminal_Index) return Natural;

   F : aliased Ada_Pretty.Factory;
   LF : constant Wide_Wide_Character := Ada.Characters.Wide_Wide_Latin_1.LF;

   -------------
   -- AD_Init --
   -------------

   function AD_Init return Ada_Pretty.Node_Access is
      use Anagram.Grammars.LR_Tables;
      List   : Ada_Pretty.Node_Access;
      List_2 : Ada_Pretty.Node_Access;
   begin
      for State in 1 .. Last_State (Table) loop
         for Term in 0 .. Plain.Last_Terminal loop
            declare
               Item : Ada_Pretty.Node_Access;
               S    : constant Anagram.Grammars.LR.State_Count :=
                 Shift (Table, State, Term);
               R    : constant Reduce_Iterator := Reduce (Table, State, Term);
            begin
               if Term in 0 and Finish (Table, State) then
                  Item := F.New_Name (+"F");
               elsif S not in 0 then
                  Item := F.New_Parentheses
                    (F.New_List
                       ((F.New_Component_Association
                          (Value => F.New_Name (+"S")),
                        F.New_Component_Association
                          (Value => F.New_Literal (Natural (S))))));
               elsif not Is_Empty (R) then
                  Item := F.New_Parentheses
                    (F.New_List
                       ((F.New_Component_Association
                          (Value => F.New_Name (+"R")),
                        F.New_Component_Association
                          (Value => F.New_Literal
                               (Natural (Production (R)))))));
               else
                  Item := F.New_Name (+"E");
               end if;

               List_2 := F.New_List
                 (List_2, F.New_Component_Association (Value   => Item));
            end;
         end loop;

         for NT in 1 .. Plain.Last_Non_Terminal loop
            declare
               Item : Ada_Pretty.Node_Access;
               S    : constant Anagram.Grammars.LR.State_Count :=
                 Shift (Table, State, NT);
               R    : constant Reduce_Iterator := Reduce (Table, State, NT);
            begin
               if S not in 0 then
                  Item := F.New_Parentheses
                    (F.New_List
                       ((F.New_Component_Association
                          (Value => F.New_Name (+"S")),
                        F.New_Component_Association
                          (Value => F.New_Literal (Natural (S))))));
               elsif not Is_Empty (R) then
                  Item := F.New_Parentheses
                    (F.New_List
                       ((F.New_Component_Association
                          (Value => F.New_Name (+"R")),
                        F.New_Component_Association
                          (Value => F.New_Literal
                               (Natural (Production (R)))))));
               else
                  Item := F.New_Name (+"E");
               end if;

               List_2 := F.New_List
                 (List_2, F.New_Component_Association (Value   => Item));
            end;
         end loop;

         List := F.New_List
           (List,
            F.New_Component_Association
              (Choices => F.New_Literal (Natural (State)),
               Value   => F.New_Parentheses (List_2)));
         List_2 := null;
      end loop;

      return F.New_Parentheses (List);
   end AD_Init;

   -------------
   -- CD_Init --
   -------------

   function CD_Init return Ada_Pretty.Node_Access is
      use type Anagram.Grammars.Part_Count;
      List   : Ada_Pretty.Node_Access;
   begin
      for Prod of Plain.Production loop
         List := F.New_List
           (List,
            F.New_Component_Association
              (Choices => F.New_Literal (Natural (Prod.Index)),
               Value   => F.New_Literal
                 (Natural (Prod.Last - Prod.First + 1))));
      end loop;

      return F.New_Parentheses (List);
   end CD_Init;

   ---------------
   -- Name_Case --
   ---------------

   function Name_Case return Ada_Pretty.Node_Access is
      List : Ada_Pretty.Node_Access := F.New_Case_Path
        (Choice => F.New_Literal (0),
         List   => F.New_Return (F.New_String_Literal (+"EOF")));
   begin
      for Term in 1 .. Plain.Last_Terminal loop
         List := F.New_List
           (List,
            F.New_Case_Path
              (Choice => F.New_Literal (Natural (Term)),
               List   => F.New_Return
                 (F.New_String_Literal (Plain.Terminal (Term).Image))));
      end loop;

      for NT in 1 .. Plain.Last_Non_Terminal loop
         List := F.New_List
           (List,
            F.New_Case_Path
              (Choice => F.New_Literal (To_Kind (NT)),
               List   => F.New_Return
                 (F.New_String_Literal (Plain.Non_Terminal (NT).Name))));
      end loop;

      List := F.New_List
        (List,
         F.New_Case_Path
           (Choice => F.New_Name (+"others"),
            List   => F.New_Return (F.New_String_Literal (+"unknown"))));

      return List;
   end Name_Case;

   -------------
   -- NT_Init --
   -------------

   function NT_Init return Ada_Pretty.Node_Access is
      List   : Ada_Pretty.Node_Access;
   begin
      for NT of Plain.Non_Terminal loop
         List := F.New_List
           (List,
            F.New_Component_Association
              (Choices => F.New_List
                   (F.New_Literal (Natural (NT.First)),
                    F.New_Infix (+"..", F.New_Literal (Natural (NT.Last)))),
               Value => F.New_Literal (To_Kind (NT.Index))));
      end loop;

      return F.New_Parentheses (List);
   end NT_Init;

   -------------
   -- SD_Init --
   -------------

   function SD_Init return Ada_Pretty.Node_Access is
      use Anagram.Grammars.LR_Tables;
      List   : Ada_Pretty.Node_Access;
      List_2 : Ada_Pretty.Node_Access;
   begin
      for State in 1 .. Last_State (Table) loop
         for NT in 1 .. Plain.Last_Non_Terminal loop
            declare
               S : constant Anagram.Grammars.LR.State_Count :=
                 Shift (Table, State, NT);
            begin
               List_2 := F.New_List
                 (List_2,
                  F.New_Component_Association
                    (Choices => F.New_Literal (To_Kind (NT)),
                     Value   => F.New_Literal (Natural (S))));
            end;
         end loop;

         List := F.New_List
           (List,
            F.New_Component_Association
              (Choices => F.New_Literal (Natural (State)),
               Value   => F.New_Parentheses (List_2)));
         List_2 := null;
      end loop;

      return F.New_Parentheses (List);
   end SD_Init;

   -------------
   -- To_Kind --
   -------------

   function To_Kind
     (Index : Anagram.Grammars.Non_Terminal_Index) return Natural is
   begin
      return Positive (Plain.Last_Terminal) + Positive (Index);
   end To_Kind;

   Clause : constant Ada_Pretty.Node_Access := F.New_With
     (F.New_Selected_Name (+"Incr.Nodes.Joints"));

   Name : constant Ada_Pretty.Node_Access :=
     F.New_Selected_Name (+"Ada_LSP.Ada_Parser_Data");

   Rename_List : constant Ada_Pretty.Node_Access :=
     F.New_List
       ((F.New_Variable
          (Name            => F.New_Name (+"S"),
           Type_Definition => F.New_Selected_Name (+"P.Action_Kinds"),
           Initialization  => F.New_Selected_Name (+"P.Shift"),
           Is_Constant     => True),
        F.New_Variable
          (Name            => F.New_Name (+"R"),
           Type_Definition => F.New_Selected_Name (+"P.Action_Kinds"),
           Initialization  => F.New_Selected_Name (+"P.Reduce"),
           Is_Constant     => True),
        F.New_Variable
          (Name            => F.New_Name (+"E"),
           Type_Definition => F.New_Selected_Name (+"P.Action"),
           Initialization  => F.New_Parentheses
             (F.New_Component_Association
                  (Choices => F.New_Name (+"Kind"),
                   Value   => F.New_Selected_Name (+"P.Error"))),
           Is_Constant     => True),
        F.New_Variable
          (Name            => F.New_Name (+"F"),
           Type_Definition => F.New_Selected_Name (+"P.Action"),
           Initialization  => F.New_Parentheses
             (F.New_Component_Association
                  (Choices => F.New_Name (+"Kind"),
                   Value   => F.New_Selected_Name (+"P.Finish"))),
           Is_Constant     => True)));

   Action_Data : constant Ada_Pretty.Node_Access :=
     F.New_Variable
       (Name            => F.New_Name (+"Action_Data"),
        Type_Definition => F.New_Selected_Name (+"P.Action_Table"),
        Initialization  => AD_Init,
        Is_Constant     => True,
        Is_Aliased      => True);

   State_Data : constant Ada_Pretty.Node_Access :=
     F.New_Variable
       (Name            => F.New_Name (+"State_Data"),
        Type_Definition => F.New_Selected_Name (+"P.State_Table"),
        Initialization  => SD_Init,
        Is_Constant     => True,
        Is_Aliased      => True);

   Count_Data : constant Ada_Pretty.Node_Access :=
     F.New_Variable
       (Name            => F.New_Name (+"Count_Data"),
        Type_Definition => F.New_Selected_Name (+"P.Parts_Count_Table"),
        Initialization  => CD_Init,
        Is_Constant     => True,
        Is_Aliased      => True);

   NT : constant Ada_Pretty.Node_Access :=
     F.New_Variable
       (Name            => F.New_Name (+"NT"),
        Type_Definition => F.New_Name (+"Node_Kind_Array"),
        Initialization  => NT_Init,
        Is_Constant     => True);

   Self : constant Ada_Pretty.Node_Access :=
     F.New_Parameter
       (Name            => F.New_Name (+"Self"),
        Type_Definition => F.New_Name (+"Provider"));

   Self_Unreferenced : constant Ada_Pretty.Node_Access :=
     F.New_Pragma
       (Name      => F.New_Name (+"Unreferenced"),
        Arguments => F.New_Name (+"Self"));

   Actions : constant Ada_Pretty.Node_Access :=
     F.New_Subprogram_Body
       (F.New_Subprogram_Specification
          (Is_Overriding => True,
           Name          => F.New_Name (+"Actions"),
           Parameters    => Self,
           Result        => F.New_Selected_Name (+"P.Action_Table_Access")),
        Declarations => Self_Unreferenced,
        Statements => F.New_Return (F.New_Name (+"Action_Data'Access")));

   Kind_Image : constant Ada_Pretty.Node_Access :=
     F.New_Subprogram_Body
       (F.New_Subprogram_Specification
          (Is_Overriding => True,
           Name          => F.New_Name (+"Kind_Image"),
           Parameters    => F.New_List
             (Self,
              F.New_Parameter
                (Name            => F.New_Name (+"Kind"),
                 Type_Definition =>
                   F.New_Selected_Name (+"Incr.Nodes.Node_Kind"))),
           Result        => F.New_Name
                               (+"Wide_Wide_String")),
        Declarations => Self_Unreferenced,
        Statements => F.New_Case
          (Expression => F.New_Name (+"Kind"),
           List       => Name_Case));

   Part_Counts : constant Ada_Pretty.Node_Access :=
     F.New_Subprogram_Body
       (F.New_Subprogram_Specification
          (Is_Overriding => True,
           Name          => F.New_Name (+"Part_Counts"),
           Parameters    => Self,
           Result        => F.New_Selected_Name
                               (+"P.Parts_Count_Table_Access")),
        Declarations => Self_Unreferenced,
        Statements => F.New_Return (F.New_Name (+"Count_Data'Access")));

   States : constant Ada_Pretty.Node_Access :=
     F.New_Subprogram_Body
       (F.New_Subprogram_Specification
          (Is_Overriding => True,
           Name          => F.New_Name (+"States"),
           Parameters    => Self,
           Result        => F.New_Selected_Name
                               (+"P.State_Table_Access")),
        Declarations => Self_Unreferenced,
        Statements => F.New_Return (F.New_Name (+"State_Data'Access")));

   Joint_Access : constant Ada_Pretty.Node_Access := F.New_Selected_Name
     (+"Incr.Nodes.Joints.Joint_Access");

   Statements : constant Ada_Pretty.Node_Access :=
     F.New_List
       ((
        F.New_Assignment
          (Left  => F.New_Name (+"Kind"),
           Right => F.New_Apply
             (Prefix    => F.New_Name (+"NT"),
              Arguments => F.New_Name (+"Prod"))),
        F.New_Assignment
          (Left  => F.New_Name (+"Result"),
           Right => F.New_Apply
             (Prefix    => F.New_Selected_Name
                  (+"new Incr.Nodes.Joints.Joint"),
              Arguments => F.New_List
                (F.New_Argument_Association
                   (F.New_Selected_Name (+"Self.Document")),
                 F.New_Argument_Association
                   (F.New_Name (+"Children'Length"))))),
        F.New_Statement
          (F.New_Apply
             (Prefix    => F.New_Selected_Name
                  (+"Incr.Nodes.Joints.Constructors.Initialize"),
              Arguments => F.New_List
                ((F.New_Argument_Association
                     (F.New_Selected_Name (+"Result.all")),
                  F.New_Argument_Association
                      (F.New_Selected_Name (+"Kind")),
                 F.New_Argument_Association
                     (F.New_Selected_Name (+"Children")))))),
        F.New_Assignment
          (Left  => F.New_Name (+"Node"),
           Right => F.New_Apply
             (Prefix    => F.New_Selected_Name (+"Incr.Nodes.Node_Access"),
              Arguments => F.New_Name (+"Result")))
        ));

   Create_Node : constant Ada_Pretty.Node_Access :=
     F.New_Subprogram_Body
       (F.New_Subprogram_Specification
          (Is_Overriding => True,
           Name          => F.New_Name (+"Create_Node"),
           Parameters    => F.New_List
             ((F.New_Parameter
              (Name            => F.New_Name (+"Self"),
               Type_Definition => F.New_Name (+"Node_Factory"),
               Is_In           => True,
               Is_Out          => True,
               Is_Aliased      => True),
              F.New_Parameter
                (Name            => F.New_Name (+"Prod"),
                 Type_Definition => F.New_Selected_Name
                   (+"P.Production_Index")),
              F.New_Parameter
                (Name            => F.New_Name (+"Children"),
                 Type_Definition => F.New_Selected_Name
                   (+"Incr.Nodes.Node_Array")),
              F.New_Parameter
                (Name            => F.New_Name (+"Node"),
                 Type_Definition => F.New_Selected_Name
                   (+"Incr.Nodes.Node_Access"),
                 Is_Out         => True),
              F.New_Parameter
                (Name            => F.New_Name (+"Kind"),
                 Type_Definition => F.New_Selected_Name
                   (+"Incr.Nodes.Node_Kind"),
                 Is_Out         => True)))),
        Declarations => F.New_Variable
          (Name            => F.New_Name (+"Result"),
           Type_Definition => Joint_Access),
        Statements => Statements);

   Tables : constant Ada_Pretty.Node_Access :=
     F.New_List
       ((F.New_Pragma (F.New_Name (+"Page")),
        Action_Data, State_Data, Count_Data, NT,
        Actions, Kind_Image, Part_Counts, States, Create_Node));

   List : constant Ada_Pretty.Node_Access := F.New_List (Rename_List, Tables);

   Root : constant Ada_Pretty.Node_Access :=
     F.New_Package_Body (Name, List);

   Unit : constant Ada_Pretty.Node_Access :=
     F.New_Compilation_Unit (Root, Clause);
begin
   Ada.Wide_Wide_Text_IO.Put_Line
     (F.To_Text (Unit).Join (LF).To_Wide_Wide_String);
end Gen.Write_Parser_Data;
