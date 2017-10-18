with LSP.Types;
with LSP.Messages;

package LSP_Documents is

   type Document is tagged private;

   not overriding procedure Initalize
     (Self    : out Document;
      Uri     : LSP.Types.LSP_String;
      Text    : LSP.Types.LSP_String;
      Version : LSP.Types.Version_Id);

   not overriding function Get_Line
     (Self : Document;
      Line : LSP.Types.Line_Number) return LSP.Types.LSP_String;

   not overriding function Version
     (Self : Document) return LSP.Types.Version_Id;

   type Lookup_Result_Kinds is
     (None,
      Attribute_Designator,
      Pragma_Name,
      Identifier);

   type Lookup_Result (Kind : Lookup_Result_Kinds := None) is record
      case Kind is
         when Attribute_Designator | Identifier =>
            Value : LSP.Types.LSP_String;
         when Pragma_Name =>
            Name      : LSP.Types.LSP_String;
            Parameter : Natural := 0;  -- Active parameter
         when None =>
            null;
      end case;
   end record;

   not overriding function Lookup
     (Self  : Document;
      Where : LSP.Messages.Position) return Lookup_Result;

   not overriding function All_Symbols
     (Self  : Document;
      Query : LSP.Types.LSP_String)
        return LSP.Messages.SymbolInformation_Vector;

private

   type Document is tagged record
      Uri     : LSP.Types.LSP_String;
      Lines   : LSP.Types.LSP_String_Vector;
      Version : LSP.Types.Version_Id;
   end record;

end LSP_Documents;
