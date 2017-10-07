with League.Strings;
with League.String_Vectors;
with League.JSON.Values;

package LSP.Types is
   pragma Preelaborate;

   subtype LSP_Any is League.JSON.Values.JSON_Value;
   subtype LSP_Number is Natural;
   subtype LSP_String is League.Strings.Universal_String;

   subtype LSP_String_Vector is League.String_Vectors.Universal_String_Vector;

   type LSP_Number_Or_String (Is_Number : Boolean := False) is record
      case Is_Number is
         when True =>
            Number : LSP_Number;
         when False =>
            String : LSP_String;
      end case;
   end record;

   type Line_Number is new Natural;
   type UTF_16_Index is new Natural;
   type Version_Id is new Natural;

   type Trace_Kinds is (Unspecified, Off, Messages, Verbose);

   type Optional_Number (Is_Set : Boolean := False) is record
      case Is_Set is
         when True =>
            Value : Natural;
         when False =>
            null;
      end case;
   end record;

   type Optional_Boolean (Is_Set : Boolean := False) is record
      case Is_Set is
         when True =>
            Value : Boolean;
         when False =>
            null;
      end case;
   end record;

   type Optional_String (Is_Set : Boolean := False) is record
      case Is_Set is
         when True =>
            Value : LSP_String;
         when False =>
            null;
      end case;
   end record;

   type MarkedString (Is_String : Boolean := True) is record
      value: LSP_String;

      case Is_String is
         when True =>
            null;
         when False =>
            language: LSP_String;
      end case;
   end record;

   subtype MessageActionItem_Vector is
     League.String_Vectors.Universal_String_Vector;

   type Registration_Option_Kinds is
     (Absent,
                    Text_Document_Registration_Option,
             Text_Document_Change_Registration_Option,
               Text_Document_Save_Registration_Option,
                       Completion_Registration_Option,
                   Signature_Help_Registration_Option,
                        Code_Lens_Registration_Option,
                    Document_Link_Registration_Option,
      Document_On_Type_Formatting_Registration_Option,
                  Execute_Command_Registration_Option);

end LSP.Types;
