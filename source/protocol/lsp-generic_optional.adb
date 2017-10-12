with League.JSON.Streams;
with League.JSON.Values;

package body LSP.Generic_Optional is

   ----------
   -- Read --
   ----------

   not overriding procedure Read
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : out Optional_Type)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);

      Value : constant League.JSON.Values.JSON_Value := JS.Read;
   begin
      if Value.Is_Empty then
         V := (Is_Set => False);
      else
         V := (Is_Set => True, Value => <>);
         Element_Type'Read (S, V.Value);
      end if;
   end Read;

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
