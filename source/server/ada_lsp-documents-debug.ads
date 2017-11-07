with Incr.Parsers.Incremental;

package Ada_LSP.Documents.Debug is
   package P renames Incr.Parsers.Incremental.Parser_Data_Providers;

   procedure Dump
     (Self : Document;
      Name : String;
      Data : P.Parser_Data_Provider'Class);
end Ada_LSP.Documents.Debug;
