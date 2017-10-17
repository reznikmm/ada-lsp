with Ada.Streams.Stream_IO;
with Ada.Containers.Hashed_Maps;

with League.JSON.Arrays;
with League.JSON.Documents;
with League.JSON.Objects;
with League.JSON.Values;
with League.Stream_Element_Vectors;
with League.String_Vectors;
with League.Strings.Hash;

package body Ada_Wellknown is

   function "+" (Text : Wide_Wide_String)
      return League.Strings.Universal_String renames
       League.Strings.To_Universal_String;

   function Read_File (Name : String)
     return League.Stream_Element_Vectors.Stream_Element_Vector;

   package MarkedString_Maps is new Ada.Containers.Hashed_Maps
     (Key_Type        => League.Strings.Universal_String,
      Element_Type    => LSP.Messages.MarkedString_Vectors.Vector,
      Hash            => League.Strings.Hash,
      Equivalent_Keys => League.Strings."=",
      "="             => LSP.Messages.MarkedString_Vectors."=");

   package SignatureInformation_Maps is new Ada.Containers.Hashed_Maps
     (Key_Type        => League.Strings.Universal_String,
      Element_Type    => LSP.Messages.SignatureInformation,
      Hash            => League.Strings.Hash,
      Equivalent_Keys => League.Strings."=",
      "="             => LSP.Messages."=");

   MarkedString_Map : MarkedString_Maps.Map;
   Signatures : SignatureInformation_Maps.Map;
   Attr : LSP.Messages.CompletionItem_Vectors.Vector;

   ---------------------
   -- Attribute_Hover --
   ---------------------

   function Attribute_Hover
     (Name : LSP.Types.LSP_String)
      return LSP.Messages.MarkedString_Vectors.Vector
   is
      Cursor : constant MarkedString_Maps.Cursor :=
        MarkedString_Map.Find (Name.To_Lowercase);
   begin
      if MarkedString_Maps.Has_Element (Cursor) then
         return MarkedString_Maps.Element (Cursor);
      else
         return LSP.Messages.MarkedString_Vectors.Empty_Vector;
      end if;
   end Attribute_Hover;

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
      Hover : constant League.JSON.Objects.JSON_Object :=
        JSON.To_JSON_Object.Value (+"Hover").To_Object;
      Hover_Keys : constant League.String_Vectors.Universal_String_Vector :=
        Hover.Keys;
      Sign : constant League.JSON.Objects.JSON_Object :=
        JSON.To_JSON_Object.Value (+"Signatures").To_Object;
      Sign_Keys : constant League.String_Vectors.Universal_String_Vector :=
        Sign.Keys;
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

      for J in 1 .. Hover_Keys.Length loop
         declare
            Key   : constant League.Strings.Universal_String := Hover_Keys (J);
            List  : constant League.JSON.Arrays.JSON_Array :=
              Hover.Value (Key).To_Array;
            Next  : LSP.Messages.MarkedString_Vectors.Vector;
         begin
            for K in 1 .. List.Length loop
               declare
                  Value  : constant League.JSON.Values.JSON_Value := List (K);
                  Item   : LSP.Messages.MarkedString;
                  Object : League.JSON.Objects.JSON_Object;
               begin
                  if Value.Is_String then
                     Item := (Is_String => True, Value => Value.To_String);
                  else
                     Object := Value.To_Object;
                     Item :=
                       (Is_String => False,
                        language  => Object.Value (+"language").To_String,
                        value     => Object.Value (+"value").To_String);
                  end if;

                  Next.Append (Item);
               end;
            end loop;

            MarkedString_Map.Insert (Key, Next);
         end;
      end loop;

      for J in 1 .. Sign_Keys.Length loop
         declare
            Key    : constant League.Strings.Universal_String := Sign_Keys (J);
            Object : constant League.JSON.Objects.JSON_Object :=
              Sign.Value (Key).To_Object;
            Result : LSP.Messages.SignatureInformation;
            Params : League.JSON.Arrays.JSON_Array;
         begin
            Result.label := Object.Value (+"label").To_String;
            Result.documentation :=
              (True, Object.Value (+"documentation").To_String);
            Params := Object.Value (+"params").To_Array;
            for K in 1 .. Params.Length loop
               declare
                  Value : constant League.JSON.Objects.JSON_Object :=
                    Params (K).To_Object;
                  Item  : LSP.Messages.ParameterInformation;
               begin
                  Item.label := Value.Value (+"label").To_String;
                  Item.documentation :=
                    (True, Value.Value (+"documentation").To_String);

                  Result.parameters.Append (Item);
               end;
            end loop;

            Signatures.Insert (Key, Result);
         end;
      end loop;
   end Initialize;

   -----------------------
   -- Pragma_Signatures --
   -----------------------

   function Pragma_Signatures
     (Name : LSP.Types.LSP_String)
      return LSP.Messages.SignatureInformation_Vectors.Vector
   is
      Cursor : constant SignatureInformation_Maps.Cursor :=
        Signatures.Find (Name.To_Lowercase);
   begin
      if SignatureInformation_Maps.Has_Element (Cursor) then
         return LSP.Messages.SignatureInformation_Vectors.To_Vector
           (SignatureInformation_Maps.Element (Cursor), 1);
      else
         return LSP.Messages.SignatureInformation_Vectors.Empty_Vector;
      end if;
   end Pragma_Signatures;

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
