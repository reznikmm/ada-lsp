--  Copyright (c) 2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

package body LSP.Types is

   --------------
   -- Assigned --
   --------------

   function Assigned (Id : LSP_Number_Or_String) return Boolean is
   begin
      return Id.Is_Number or else not Id.String.Is_Empty;
   end Assigned;

   ---------------------------
   -- Read_Number_Or_String --
   ---------------------------

   procedure Read_Number_Or_String
    (Stream : in out League.JSON.Streams.JSON_Stream'Class;
     Key    : League.Strings.Universal_String;
     Item   : out LSP.Types.LSP_Number_Or_String)
   is
      Value : League.JSON.Values.JSON_Value;
   begin
      Stream.Key (Key);
      Value := Stream.Read;

      if Value.Is_Empty then
         Item := (Is_Number => False,
                  String    => League.Strings.Empty_Universal_String);
      elsif Value.Is_String then
         Item := (Is_Number => False, String => Value.To_String);
      else
         Item := (Is_Number => True, Number => Integer (Value.To_Integer));
      end if;
   end Read_Number_Or_String;

   --------------------------
   -- Read_Optional_String --
   --------------------------

   procedure Read_Optional_String
    (Stream : in out League.JSON.Streams.JSON_Stream'Class;
     Key    : League.Strings.Universal_String;
     Item   : out LSP.Types.Optional_String)
   is
      Value : League.JSON.Values.JSON_Value;
   begin
      Stream.Key (Key);
      Value := Stream.Read;

      if Value.Is_Empty or Value.Is_Null then
         Item := (Is_Set => False);
      else
         Item := (Is_Set => True, Value => Value.To_String);
      end if;
   end Read_Optional_String;

   -----------------
   -- Read_String --
   -----------------

   procedure Read_String
    (Stream : in out League.JSON.Streams.JSON_Stream'Class;
     Key    : League.Strings.Universal_String;
     Item   : out LSP.Types.LSP_String) is
   begin
      Stream.Key (Key);
      Item := Stream.Read.To_String;
   end Read_String;

end LSP.Types;
