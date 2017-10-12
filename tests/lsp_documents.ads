with LSP.Types;

package LSP_Documents is

   type Document is tagged private;

   procedure Initalize
     (Self : out Document;
      Text : LSP.Types.LSP_String);

private

   type Document is tagged record
      Lines : LSP.Types.LSP_String_Vector;
   end record;

end LSP_Documents;
