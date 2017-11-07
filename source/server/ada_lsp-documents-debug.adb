with Ada.Streams.Stream_IO;

with League.Text_Codecs;
with League.Stream_Element_Vectors;

with XML.SAX.Pretty_Writers;
with XML.SAX.String_Output_Destinations;

with Incr.Debug;

package body Ada_LSP.Documents.Debug is

   ----------
   -- Dump --
   ----------

   procedure Dump
     (Self : Document;
      Name : String;
      Data : P.Parser_Data_Provider'Class)
   is
      Output : Ada.Streams.Stream_IO.File_Type;
      Dest   : aliased XML.SAX.String_Output_Destinations.
        String_Output_Destination;
      Writer : XML.SAX.Pretty_Writers.XML_Pretty_Writer;
      Image  : League.Stream_Element_Vectors.Stream_Element_Vector;
   begin
      Writer.Set_Output_Destination (Dest'Unchecked_Access);
      Writer.Set_Offset (2);
      Incr.Debug.Dump (Self, Data, Writer);
      Image := League.Text_Codecs.Codec_For_Application_Locale.Encode
        (Dest.Get_Text);

      Ada.Streams.Stream_IO.Create (Output, Name => "/tmp/" & Name);
      Ada.Streams.Stream_IO.Write
        (Output, Image.To_Stream_Element_Array);
      Ada.Streams.Stream_IO.Close (Output);
   end Dump;

end Ada_LSP.Documents.Debug;
