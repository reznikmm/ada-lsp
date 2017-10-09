package body LSP.Generic_Optional is

   -----------
   -- Write --
   -----------

   not overriding procedure Write
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : Optional_Type) is
   begin
      if V.Is_Set then
         Element_Type'Write (S, V.Value);
      end if;
   end Write;

end LSP.Generic_Optional;
