with League.JSON.Streams;
with League.JSON.Values;
with League.String_Vectors;
with League.Strings;

with LSP.Generic_Optional;

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

   function Assigned (Id : LSP_Number_Or_String) return Boolean;
   --  Check if Id has an empty value

   type Line_Number is new Natural;
   type UTF_16_Index is new Natural;
   type Version_Id is new Natural;

   type Trace_Kinds is (Unspecified, Off, Messages, Verbose);

   package Optional_Numbers is new LSP.Generic_Optional (LSP_Number);
   type Optional_Number is new Optional_Numbers.Optional_Type;

   package Optional_Booleans is new LSP.Generic_Optional (Boolean);
   type Optional_Boolean is new Optional_Booleans.Optional_Type;

   package Optional_Strings is new LSP.Generic_Optional (LSP_String);
   type Optional_String is new Optional_Strings.Optional_Type;

   Optional_False : constant Optional_Boolean := (True, False);
   Optional_True  : constant Optional_Boolean := (True, True);

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

   procedure Read_String
    (Stream : in out League.JSON.Streams.JSON_Stream'Class;
     Key    : League.Strings.Universal_String;
     Item   : out LSP.Types.LSP_String);

   procedure Read_Optional_String
    (Stream : in out League.JSON.Streams.JSON_Stream'Class;
     Key    : League.Strings.Universal_String;
     Item   : out LSP.Types.Optional_String);

   procedure Read_Number_Or_String
    (Stream : in out League.JSON.Streams.JSON_Stream'Class;
     Key    : League.Strings.Universal_String;
     Item   : out LSP.Types.LSP_Number_Or_String);

end LSP.Types;
