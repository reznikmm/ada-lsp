with GNAT.IO;

package body LSP.Stdio_Streams is

   ----------
   -- Read --
   ----------

   procedure Read
     (Stream : in out Stdio_Stream;
      Item   : out Ada.Streams.Stream_Element_Array;
      Last   : out Ada.Streams.Stream_Element_Offset)
   is
      pragma Unreferenced (Stream);
      Char : Character;
   begin
      GNAT.IO.Get (Char);
      Last := Item'First;
      Item (Last) := Character'Pos (Char);
   end Read;

   -----------
   -- Write --
   -----------

   procedure Write
     (Stream : in out Stdio_Stream;
      Item   : Ada.Streams.Stream_Element_Array)
   is
      pragma Unreferenced (Stream);
      Char : Character;
   begin
      for J of Item loop
         Char := Character'Val (J);
         GNAT.IO.Put (GNAT.IO.Standard_Output, Char);
      end loop;
   end Write;

end LSP.Stdio_Streams;
