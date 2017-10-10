with Ada.Characters.Latin_1;

with League.JSON.Arrays;
with League.JSON.Documents;
with League.JSON.Objects;
with League.JSON.Streams;
with League.JSON.Values;
with League.Stream_Element_Vectors;
with League.Strings;

with LSP.Types;

package body LSP.Servers is

   New_Line : constant String :=
     (Ada.Characters.Latin_1.CR, Ada.Characters.Latin_1.LF);

   function "+" (Text : Wide_Wide_String)
      return League.Strings.Universal_String renames
       League.Strings.To_Universal_String;

   function Do_Not_Found
    (Stream  : access Ada.Streams.Root_Stream_Type'Class;
     Handler : not null LSP.Message_Handlers.Request_Handler_Access)
      return LSP.Messages.ResponseMessage'Class;

   function Do_Initialize
    (Stream  : access Ada.Streams.Root_Stream_Type'Class;
     Handler : not null LSP.Message_Handlers.Request_Handler_Access)
      return LSP.Messages.ResponseMessage'Class;

   procedure Process_Message_From_Stream
    (Self       : in out Server'Class;
     Dispatcher : access LSP.Request_Dispatchers.Request_Dispatcher;
     Handler    : LSP.Message_Handlers.Request_Handler_Access;
     Stream     : access Ada.Streams.Root_Stream_Type'Class);

   procedure Read_Number_Or_String
    (Stream : in out League.JSON.Streams.JSON_Stream'Class;
     Key    : League.Strings.Universal_String;
     Item   : out LSP.Types.LSP_Number_Or_String);

   function To_Element_Vector
    (Stream : in out League.JSON.Streams.JSON_Stream)
      return League.Stream_Element_Vectors.Stream_Element_Vector;

   procedure Write_JSON_RPC
     (Stream : access Ada.Streams.Root_Stream_Type'Class;
      Vector : League.Stream_Element_Vectors.Stream_Element_Vector);

   ------------------
   -- Do_Not_Found --
   ------------------

   function Do_Not_Found
    (Stream  : access Ada.Streams.Root_Stream_Type'Class;
     Handler : not null LSP.Message_Handlers.Request_Handler_Access)
       return LSP.Messages.ResponseMessage'Class
   is
      pragma Unreferenced (Stream, Handler);

   begin
      return Response : LSP.Messages.ResponseMessage do
         Response.error :=
           (Is_Set => True,
            Value  => (code    => LSP.Messages.MethodNotFound,
                       message => +"No such method",
                       others  => <>));
      end return;
   end Do_Not_Found;

   -------------------
   -- Do_Initialize --
   -------------------

   function Do_Initialize
    (Stream  : access Ada.Streams.Root_Stream_Type'Class;
     Handler : not null LSP.Message_Handlers.Request_Handler_Access)
       return LSP.Messages.ResponseMessage'Class
   is
      Params   : LSP.Messages.InitializeParams;
      Response : LSP.Messages.Initialize_Response;
   begin
      LSP.Messages.InitializeParams'Read (Stream, Params);
      Handler.Initialize_Request
        (Response => Response,
         Value    => Params);

      return Response;
   end Do_Initialize;

   ----------------
   -- Initialize --
   ----------------

   not overriding procedure Initialize
     (Self    : in out Server;
      Stream  : access Ada.Streams.Root_Stream_Type'Class;
      Handler : not null LSP.Message_Handlers.Request_Handler_Access)
   is
      type Request is record
         Name   : League.Strings.Universal_String;
         Action : LSP.Request_Dispatchers.Parameter_Handler_Access;
      end record;

      Request_List : constant array (Positive range <>) of Request :=
        ((+"initialize", Do_Initialize'Access),
         (+"shutdown", Do_Not_Found'Access),
         (+"textDocument/willSaveWaitUntil", Do_Not_Found'Access),
         (+"textDocument/completion", Do_Not_Found'Access),
         (+"completionItem/resolve", Do_Not_Found'Access),
         (+"textDocument/hover", Do_Not_Found'Access),
         (+"textDocument/signatureHelp", Do_Not_Found'Access),
         (+"textDocument/definition", Do_Not_Found'Access),
         (+"textDocument/references", Do_Not_Found'Access),
         (+"textDocument/documentHighlight", Do_Not_Found'Access),
         (+"textDocument/documentSymbol", Do_Not_Found'Access),
         (+"workspace/symbol", Do_Not_Found'Access),
         (+"textDocument/codeAction", Do_Not_Found'Access),
         (+"textDocument/codeLens", Do_Not_Found'Access),
         (+"codeLens/resolve", Do_Not_Found'Access),
         (+"textDocument/documentLink", Do_Not_Found'Access),
         (+"documentLink/resolve", Do_Not_Found'Access),
         (+"textDocument/formatting", Do_Not_Found'Access),
         (+"textDocument/rangeFormatting", Do_Not_Found'Access),
         (+"textDocument/onTypeFormatting", Do_Not_Found'Access),
         (+"textDocument/rename", Do_Not_Found'Access),
         (+"workspace/executeCommand", Do_Not_Found'Access),
         (+"", Do_Not_Found'Access));

   begin
      Self.Stream := Stream;
      Self.Handler := Handler;
      Self.Initilized := False;  --  Block request until 'initialize' request

      for Request of Request_List loop
         Self.Dispatcher.Register (Request.Name, Request.Action);
      end loop;
   end Initialize;

   ---------------------------------
   -- Process_Message_From_Stream --
   ---------------------------------

   procedure Process_Message_From_Stream
    (Self       : in out Server'Class;
     Dispatcher : access LSP.Request_Dispatchers.Request_Dispatcher;
     Handler    : LSP.Message_Handlers.Request_Handler_Access;
     Stream     : access Ada.Streams.Root_Stream_Type'Class)
   is
      use type League.Strings.Universal_String;
      procedure Send_Not_Initialized
        (Request_Id : LSP.Types.LSP_Number_Or_String);

      procedure Send_Response
        (Response   : in out LSP.Messages.ResponseMessage'Class;
         Request_Id : LSP.Types.LSP_Number_Or_String);

      procedure Send_Response
        (Response   : in out LSP.Messages.ResponseMessage'Class;
         Request_Id : LSP.Types.LSP_Number_Or_String)
      is
         Out_Stream : aliased League.JSON.Streams.JSON_Stream;
         Output     : League.Stream_Element_Vectors.Stream_Element_Vector;
      begin
         Response.jsonrpc := +"2.0";
         Response.id := Request_Id;
         LSP.Messages.ResponseMessage'Class'Write
           (Out_Stream'Access, Response);
         Output := To_Element_Vector (Out_Stream);
         Write_JSON_RPC (Self.Stream, Output);
      end Send_Response;

      --------------------------
      -- Send_Not_Initialized --
      --------------------------

      procedure Send_Not_Initialized
        (Request_Id : LSP.Types.LSP_Number_Or_String)
      is
         Response : LSP.Messages.ResponseMessage;
      begin
         Response.error :=
           (Is_Set => True,
            Value  => (code    => LSP.Messages.MethodNotFound,
                       message => +"No such method",
                       others  => <>));
         Send_Response (Response, Request_Id);
      end Send_Not_Initialized;

      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (Stream.all);

      Request_Id : LSP.Types.LSP_Number_Or_String;
      Version    : LSP.Types.LSP_String;
      Method     : LSP.Types.LSP_String;
   begin
      JS.Start_Object;
      LSP.Types.Read_String (JS, +"jsonrpc", Version);
      LSP.Types.Read_String (JS, +"method", Method);
      Read_Number_Or_String (JS, +"id", Request_Id);
      JS.Key (+"params");

      if not Self.Initilized then
         if LSP.Types.Assigned (Request_Id) then
            if Method /= +"initialize" then
               Send_Not_Initialized (Request_Id);
            else
               Self.Initilized := True;
            end if;
         end if;
      end if;

      declare
         Out_Stream : aliased League.JSON.Streams.JSON_Stream;
         Output     : League.Stream_Element_Vectors.Stream_Element_Vector;
         Response   : LSP.Messages.ResponseMessage'Class :=
           Dispatcher.Dispatch
             (Method  => Method,
              Stream  => Stream,
              Handler => Handler);
      begin
         Response.jsonrpc := +"2.0";
         Response.id := Request_Id;
         LSP.Messages.ResponseMessage'Class'Write
           (Out_Stream'Access, Response);
         Output := To_Element_Vector (Out_Stream);
         Write_JSON_RPC (Self.Stream, Output);
      end;
   end Process_Message_From_Stream;

   ---------------------------
   -- Read_Number_Or_String --
   ---------------------------

   procedure Read_Number_Or_String
    (Stream : in out League.JSON.Streams.JSON_Stream'Class;
     Key    : League.Strings.Universal_String;
     Item   : out LSP.Types.LSP_Number_Or_String)
   is
      Value : League.JSON.Values.JSON_Value;
   begin
      Stream.Key (Key);
      Value := Stream.Read;

      if Value.Is_Empty then
         Item := (Is_Number => False,
                  String    => League.Strings.Empty_Universal_String);
      elsif Value.Is_String then
         Item := (Is_Number => False, String => Value.To_String);
      else
         Item := (Is_Number => True, Number => Integer (Value.To_Integer));
      end if;
   end Read_Number_Or_String;

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
         In_Stream      : aliased League.JSON.Streams.JSON_Stream;
         Document       : League.JSON.Documents.JSON_Document;
         JSON_Object    : League.JSON.Objects.JSON_Object;
         JSON_Array     : League.JSON.Arrays.JSON_Array;
      begin
         Document := League.JSON.Documents.From_JSON (Vector);
         JSON_Object := Document.To_JSON_Object;
         JSON_Array.Append (JSON_Object.To_JSON_Value);
         In_Stream.Set_JSON_Document (JSON_Array.To_JSON_Document);

         Self.Process_Message_From_Stream
           (Dispatcher => Self.Dispatcher'Access,
            Handler    => Self.Handler,
            Stream     => In_Stream'Access);
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
      while not Self.Stop loop
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
      Element_Vector : League.Stream_Element_Vectors.Stream_Element_Vector;
   begin
      LSP.Messages.NotificationMessage'Write (JSON_Stream'Access, Value);
      Element_Vector := To_Element_Vector (JSON_Stream);
      Write_JSON_RPC (Self.Stream, Element_Vector);
   end Send_Notification;

   ----------
   -- Stop --
   ----------

   not overriding procedure Stop (Self  : in out Server) is
   begin
      Self.Stop := True;
   end Stop;

   -----------------------
   -- To_Element_Vector --
   -----------------------

   function To_Element_Vector
    (Stream : in out League.JSON.Streams.JSON_Stream)
      return League.Stream_Element_Vectors.Stream_Element_Vector
   is
      Document    : constant League.JSON.Documents.JSON_Document :=
        Stream.Get_JSON_Document;
      JSON_Array  : constant League.JSON.Arrays.JSON_Array :=
        Document.To_JSON_Array;
      JSON_Object : constant League.JSON.Objects.JSON_Object :=
        JSON_Array.First_Element.To_Object;
   begin
      return JSON_Object.To_JSON_Document.To_JSON;
   end To_Element_Vector;

   --------------------
   -- Write_JSON_RPC --
   --------------------

   procedure Write_JSON_RPC
     (Stream : access Ada.Streams.Root_Stream_Type'Class;
      Vector : League.Stream_Element_Vectors.Stream_Element_Vector)
   is
      Image  : constant String := Ada.Streams.Stream_Element_Count'Image
        (Vector.Length);
      Header : constant String := "Content-Length:" & Image
        & New_Line & New_Line;
   begin
      String'Write (Stream, Header);
      Stream.Write (Vector.To_Stream_Element_Array);
   end Write_JSON_RPC;

end LSP.Servers;
