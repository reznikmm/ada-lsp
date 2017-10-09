with Ada.Streams;
generic
   type Element_Type is private;
package LSP.Generic_Optional is
   pragma Pure;

   type Optional_Type (Is_Set : Boolean := False) is record
      case Is_Set is
         when True =>
            Value : Element_Type;
         when False =>
            null;
      end case;
   end record;

   not overriding procedure Write
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : Optional_Type);

   for Optional_Type'Write use Write;

end LSP.Generic_Optional;
