with Ada.Streams.Stream_IO;

with League.JSON.Arrays;
with League.JSON.Documents;
with League.Stream_Element_Vectors;
with League.Strings;

with LSP.Types;

package body Ada_Wellknown is

   function "+" (Text : Wide_Wide_String)
      return League.Strings.Universal_String renames
       League.Strings.To_Universal_String;

   function Read_File (Name : String)
     return League.Stream_Element_Vectors.Stream_Element_Vector;

   Attr : LSP.Messages.CompletionItem_Vectors.Vector;

   ----------------
   -- Attributes --
   ----------------

   function Attributes return LSP.Messages.CompletionItem_Vectors.Vector is
   begin
      return Attr;
   end Attributes;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
      JSON : constant League.JSON.Documents.JSON_Document :=
        League.JSON.Documents.From_JSON (Read_File ("tests/wellknown.json"));
      Attr_List : constant League.JSON.Arrays.JSON_Array :=
        JSON.To_JSON_Object.Value (+"Attributes").To_Array;
   begin
      for J in 1 .. Attr_List.Length loop
         declare
            function "-" (Name : Wide_Wide_String) return LSP.Types.LSP_String;

            function "-" (Name : Wide_Wide_String)
              return LSP.Types.LSP_String is
            begin
               return Attr_List (J).To_Object.Value (+Name).To_String;
            end "-";

            Item : LSP.Messages.CompletionItem;
         begin
            Item.label := -"label";
            Item.detail := (True, -"detail");
            Item.documentation := (True, -"documentation");
            Item.sortText := (True, -"sortText");
            Item.filterText := (True, -"filterText");
            Item.insertText := (True, -"insertText");

            if Item.insertText.Value.Index ('$') > 0 then
               Item.insertTextFormat := (True, LSP.Messages.Snippet);
            end if;

            Attr.Append (Item);
         end;
      end loop;
   end Initialize;

   ---------------
   -- Read_File --
   ---------------

   function Read_File (Name : String)
     return League.Stream_Element_Vectors.Stream_Element_Vector
   is
      Input  : Ada.Streams.Stream_IO.File_Type;
      Buffer : Ada.Streams.Stream_Element_Array (1 .. 1024);
      Last   : Ada.Streams.Stream_Element_Offset;
      Result : League.Stream_Element_Vectors.Stream_Element_Vector;
   begin
      Ada.Streams.Stream_IO.Open (Input, Ada.Streams.Stream_IO.In_File, Name);
      while not Ada.Streams.Stream_IO.End_Of_File (Input) loop
         Ada.Streams.Stream_IO.Read (Input, Buffer, Last);
         Result.Append (Buffer (1 .. Last));
      end loop;
      return Result;
   end Read_File;

end Ada_Wellknown;
