with LSP.Types;

package LSP_Documents is

   type Document is tagged private;

   not overriding procedure Initalize
     (Self    : out Document;
      Text    : LSP.Types.LSP_String;
      Version : LSP.Types.Version_Id);

   not overriding function Get_Line
     (Self : Document;
      Line : LSP.Types.Line_Number) return LSP.Types.LSP_String;

   not overriding function Version
     (Self : Document) return LSP.Types.Version_Id;

private

   type Document is tagged record
      Lines   : LSP.Types.LSP_String_Vector;
      Version : LSP.Types.Version_Id;
   end record;

end LSP_Documents;
