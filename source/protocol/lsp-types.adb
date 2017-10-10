package body LSP.Types is

   --------------
   -- Assigned --
   --------------

   function Assigned (Id : LSP_Number_Or_String) return Boolean is
   begin
      return not Id.Is_Number and then Id.String.Is_Empty;
   end Assigned;

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
