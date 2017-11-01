--  Copyright (c) 2015-2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------


with Ada.Command_Line;

with Anagram.Grammars.Constructors;
with Anagram.Grammars.LR.LALR;
with Anagram.Grammars.LR_Tables;
with Anagram.Grammars.Reader;
with Anagram.Grammars_Convertors;
with Anagram.Grammars_Debug;

with Gen.Write_Parser_Data;

procedure Gen.Driver is
   File : constant String := Ada.Command_Line.Argument (1);
   G : constant Anagram.Grammars.Grammar :=
     Anagram.Grammars.Reader.Read (File);
   Plain : constant Anagram.Grammars.Grammar :=
     Anagram.Grammars_Convertors.Convert (G, False);
   AG : constant Anagram.Grammars.Grammar :=
     Anagram.Grammars.Constructors.To_Augmented (Plain);
   Table : constant Anagram.Grammars.LR_Tables.Table_Access :=
     Anagram.Grammars.LR.LALR.Build (AG, False);
begin
   if Ada.Command_Line.Argument_Count = 1 then
      Gen.Write_Parser_Data (Plain, Table.all);
   elsif Ada.Command_Line.Argument_Count > 2 then
      Anagram.Grammars_Debug.Print_Conflicts (AG, Table.all);
   end if;
end Gen.Driver;
