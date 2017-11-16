--  Copyright (c) 2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with Ada.Streams;

package LSP.Stdio_Streams is

   type Stdio_Stream is new Ada.Streams.Root_Stream_Type with null record;

   procedure Read
     (Stream : in out Stdio_Stream;
      Item   : out Ada.Streams.Stream_Element_Array;
      Last   : out Ada.Streams.Stream_Element_Offset);

   procedure Write
     (Stream : in out Stdio_Stream;
      Item   : Ada.Streams.Stream_Element_Array);

end LSP.Stdio_Streams;
