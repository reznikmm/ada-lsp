--  Copyright (c) 2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with Ada.Streams;
generic
   type Element_Type is private;
package LSP.Generic_Optional is
   pragma Preelaborate;

   type Optional_Type (Is_Set : Boolean := False) is record
      case Is_Set is
         when True =>
            Value : Element_Type;
         when False =>
            null;
      end case;
   end record;

   not overriding procedure Read
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : out Optional_Type);

   for Optional_Type'Read use Read;

   not overriding procedure Write
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : Optional_Type);

   for Optional_Type'Write use Write;

end LSP.Generic_Optional;
