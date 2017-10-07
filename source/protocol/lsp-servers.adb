with Ada.Characters.Latin_1;

with League.JSON.Arrays;
with League.JSON.Documents;
with League.JSON.Objects;
with League.JSON.Streams;
with League.Stream_Element_Vectors;
with League.Strings;

with LSP.Types;

package body LSP.Servers is

   New_Line : constant String :=
     (Ada.Characters.Latin_1.CR, Ada.Characters.Latin_1.LF);

   function "+" (Text : Wide_Wide_String)
      return League.Strings.Universal_String renames
       League.Strings.To_Universal_String;

   procedure Do_Initialize
     (Stream     : access Ada.Streams.Root_Stream_Type'Class;
     Handler    : not null LSP.Request_Handlers.Request_Handler_Access;
      Request_Id : LSP.Types.LSP_Number_Or_String);

   package Requests is
      type RequestMessage is new LSP.Messages.RequestMessage with record
         Dispatcher : access LSP.Request_Dispatchers.Request_Dispatcher;
         Handler    : LSP.Request_Handlers.Request_Handler_Access;
      end record;

      overriding procedure Read_Parameters
        (Self   : RequestMessage;
         Stream : access Ada.Streams.Root_Stream_Type'Class);
   end Requests;

   package body Requests is

      overriding procedure Read_Parameters
       (Self   : RequestMessage;
        Stream : access Ada.Streams.Root_Stream_Type'Class) is
      begin
         Self.Dispatcher.Dispatch
           (Request => Self,
            Stream  => Stream,
            Handler => Self.Handler);
      end Read_Parameters;
   end Requests;

   -------------------
   -- Do_Initialize --
   -------------------

   procedure Do_Initialize
    (Stream     : access Ada.Streams.Root_Stream_Type'Class;
     Handler    : not null LSP.Request_Handlers.Request_Handler_Access;
     Request_Id : LSP.Types.LSP_Number_Or_String)
   is
      Params : LSP.Messages.InitializeParams;
      Response : LSP.Messages.ResponseMessage;
   begin
      LSP.Messages.InitializeParams'Read (Stream, Params);
      Handler.Initialize_Request
        (Response => Response,
         Id       => Request_Id,
         Value    => Params);
   end Do_Initialize;

   ----------------
   -- Initialize --
   ----------------

   not overriding procedure Initialize
     (Self    : in out Server;
      Stream  : access Ada.Streams.Root_Stream_Type'Class;
      Handler : not null LSP.Request_Handlers.Request_Handler_Access) is
   begin
      Self.Stream := Stream;
      Self.Handler := Handler;
      Self.Dispatcher.Register (+"initialize", Do_Initialize'Access);
   end Initialize;

   ---------
   -- Run --
   ---------

   not overriding procedure Run (Self  : in out Server) is
      use type Ada.Streams.Stream_Element_Count;

      procedure Parse_Header
        (Length : out Ada.Streams.Stream_Element_Count;
         Vector : in out League.Stream_Element_Vectors.Stream_Element_Vector);
      procedure Parse_JSON
        (Vector : League.Stream_Element_Vectors.Stream_Element_Vector);
      procedure Parse_Line
        (Line   : String;
         Length : in out Ada.Streams.Stream_Element_Count);

      ------------------
      -- Parse_Header --
      ------------------

      procedure Parse_Header
        (Length : out Ada.Streams.Stream_Element_Count;
         Vector : in out League.Stream_Element_Vectors.Stream_Element_Vector)
      is
         Buffer : Ada.Streams.Stream_Element_Array (1 .. 512);
         Last   : Ada.Streams.Stream_Element_Count := Vector.Length;
         Line   : String (1 .. 80) := (others => ' ');
         Char   : Character;
         Index  : Natural := 0;
         Empty  : Boolean := False;  --  We've just seen CR, LF
      begin
         if Last > 0 then
            Buffer (1 .. Last) := Vector.To_Stream_Element_Array;
            Vector.Clear;
         end if;

         Length := 0;

         loop
            for J in 1 .. Last loop
               Char := Character'Val (Buffer (J));

               if Char not in Ada.Characters.Latin_1.CR
                                | Ada.Characters.Latin_1.LF
               then
                  Empty := False;
               end if;

               if Index = Line'Last then
                  --  Too long line drop it keeping last character
                  Line (1) := Line (Line'Last);
                  Index := 2;
               else
                  Index := Index + 1;
               end if;

               Line (Index) := Char;

               if Index > 1 and then Line (Index - 1 .. Index) = New_Line then
                  if Empty then
                     Vector.Append (Buffer (J + 1 .. Last));
                     return;
                  end if;

                  Empty := True;
                  Parse_Line (Line (1 .. Index - 2), Length);
               end if;
            end loop;

            Self.Stream.Read (Buffer, Last);
         end loop;
      end Parse_Header;

      ----------------
      -- Parse_JSON --
      ----------------

      procedure Parse_JSON
        (Vector : League.Stream_Element_Vectors.Stream_Element_Vector)
      is
         JSON_Stream    : aliased League.JSON.Streams.JSON_Stream;
         Document       : League.JSON.Documents.JSON_Document;
         JSON_Object    : League.JSON.Objects.JSON_Object;
         JSON_Array     : League.JSON.Arrays.JSON_Array;
         Request        : Requests.RequestMessage :=
           (Dispatcher => Self.Dispatcher'Unchecked_Access,
            Handler    => Self.Handler,
            others     => <>);
      begin
         Document := League.JSON.Documents.From_JSON (Vector);
         JSON_Object := Document.To_JSON_Object;
         JSON_Array.Append (JSON_Object.To_JSON_Value);
         JSON_Stream.Set_JSON_Document (JSON_Array.To_JSON_Document);

         LSP.Messages.RequestMessage'Read
           (JSON_Stream'Access,
            LSP.Messages.RequestMessage (Request));
      end Parse_JSON;

      ----------------
      -- Parse_Line --
      ----------------

      procedure Parse_Line
        (Line   : String;
         Length : in out Ada.Streams.Stream_Element_Count)
      is
         Content_Length : constant String := "Content-Length:";
      begin
         if Line'Length > Content_Length'Length and then
           Line (Content_Length'Range) = Content_Length
         then
            Length := Ada.Streams.Stream_Element_Count'Value
              (Line (Content_Length'Length + 2 - Line'First .. Line'Last));
         end if;
      end Parse_Line;

      Vector : League.Stream_Element_Vectors.Stream_Element_Vector;
      Length : Ada.Streams.Stream_Element_Count := 0;
      Buffer : Ada.Streams.Stream_Element_Array (1 .. 512);
      Last   : Ada.Streams.Stream_Element_Count;
   begin
      loop
         Parse_Header (Length, Vector);
         Last := Vector.Length;
         Buffer (1 .. Last) := Vector.To_Stream_Element_Array;
         Vector.Clear;

         loop
            if Last <= Length then
               Vector.Append (Buffer (1 .. Last));
               Length := Length - Last;
               Last := 0;
            else
               Vector.Append (Buffer (1 .. Length));
               Last := Last - Length;
               Buffer (1 .. Last) := Buffer (Length + 1 .. Length + Last);
               Length := 0;
            end if;

            if Length = 0 then
               Parse_JSON (Vector);
               Vector.Clear;
               Vector.Append (Buffer (1 .. Last));
               exit;
            else
               Self.Stream.Read (Buffer, Last);
            end if;
         end loop;
      end loop;
   end Run;

   -----------------------
   -- Send_Notification --
   -----------------------

   not overriding procedure Send_Notification
     (Self  : in out Server;
      Value : LSP.Messages.NotificationMessage)
   is
      JSON_Stream    : aliased League.JSON.Streams.JSON_Stream;
      Document       : League.JSON.Documents.JSON_Document;
      Element_Vector : League.Stream_Element_Vectors.Stream_Element_Vector;
   begin
      LSP.Messages.NotificationMessage'Write (JSON_Stream'Access, Value);
      Document := JSON_Stream.Get_JSON_Document;
      Element_Vector := Document.To_JSON;

      declare
         Image  : constant String := Ada.Streams.Stream_Element_Count'Image
           (Element_Vector.Length);
         Header : constant String := "Content-Length:" & Image
           & New_Line & New_Line;
      begin
         String'Write (Self.Stream, Header);
         Self.Stream.Write (Element_Vector.To_Stream_Element_Array);
      end;
   end Send_Notification;

end LSP.Servers;
