package body LSP.Types is

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