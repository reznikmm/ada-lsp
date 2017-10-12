with League.Strings;

package body LSP.Servers.Handlers is

   function "+" (Text : Wide_Wide_String)
      return League.Strings.Universal_String renames
       League.Strings.To_Universal_String;

   ----------------------------
   -- DidChangeConfiguration --
   ----------------------------

   procedure DidChangeConfiguration
    (Stream  : access Ada.Streams.Root_Stream_Type'Class;
     Handler : not null LSP.Message_Handlers.Notification_Handler_Access)
   is
      Params : LSP.Messages.DidChangeConfigurationParams;
   begin
      LSP.Messages.DidChangeConfigurationParams'Read (Stream, Params);

      Handler.Workspace_Did_Change_Configuration_Request (Params);
   end DidChangeConfiguration;

   ---------------------------
   -- DidChangeTextDocument --
   ---------------------------

   procedure DidChangeTextDocument
    (Stream  : access Ada.Streams.Root_Stream_Type'Class;
     Handler : not null LSP.Message_Handlers.Notification_Handler_Access)
   is
      Params : LSP.Messages.DidChangeTextDocumentParams;
   begin
      LSP.Messages.DidChangeTextDocumentParams'Read (Stream, Params);

      Handler.Text_Document_Did_Change (Params);
   end DidChangeTextDocument;

   --------------------------
   -- DidCloseTextDocument --
   --------------------------

   procedure DidCloseTextDocument
    (Stream  : access Ada.Streams.Root_Stream_Type'Class;
     Handler : not null LSP.Message_Handlers.Notification_Handler_Access)
   is
      Params : LSP.Messages.DidCloseTextDocumentParams;
   begin
      LSP.Messages.DidCloseTextDocumentParams'Read (Stream, Params);

      Handler.Text_Document_Did_Close (Params);
   end DidCloseTextDocument;

   -------------------------
   -- DidOpenTextDocument --
   -------------------------

   procedure DidOpenTextDocument
    (Stream  : access Ada.Streams.Root_Stream_Type'Class;
     Handler : not null LSP.Message_Handlers.Notification_Handler_Access)
   is
      Params : LSP.Messages.DidOpenTextDocumentParams;
   begin
      LSP.Messages.DidOpenTextDocumentParams'Read (Stream, Params);

      Handler.Text_Document_Did_Open (Params);
   end DidOpenTextDocument;

   -------------------
   -- Do_Completion --
   -------------------

   function Do_Completion
    (Stream  : access Ada.Streams.Root_Stream_Type'Class;
     Handler : not null LSP.Message_Handlers.Request_Handler_Access)
      return LSP.Messages.ResponseMessage'Class
   is
      Params   : LSP.Messages.TextDocumentPositionParams;
      Response : LSP.Messages.Completion_Response;
   begin
      LSP.Messages.TextDocumentPositionParams'Read (Stream, Params);
      Handler.Text_Document_Completion_Request
        (Response => Response,
         Value    => Params);

      return Response;
   end Do_Completion;

   -------------
   -- Do_Exit --
   -------------

   procedure Do_Exit
    (Stream  : access Ada.Streams.Root_Stream_Type'Class;
     Handler : not null LSP.Message_Handlers.Notification_Handler_Access)
   is
      pragma Unreferenced (Stream);
   begin
      Handler.Exit_Notification;
   end Do_Exit;

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

   -----------------
   -- Do_Shutdown --
   -----------------

   function Do_Shutdown
    (Stream  : access Ada.Streams.Root_Stream_Type'Class;
     Handler : not null LSP.Message_Handlers.Request_Handler_Access)
      return LSP.Messages.ResponseMessage'Class
   is
      pragma Unreferenced (Stream);
      Response : LSP.Messages.ResponseMessage;
   begin
      Handler.Shutdown_Request (Response);

      return Response;
   end Do_Shutdown;

   -------------------------
   -- Ignore_Notification --
   -------------------------

   procedure Ignore_Notification
    (Stream  : access Ada.Streams.Root_Stream_Type'Class;
     Handler : not null LSP.Message_Handlers.Notification_Handler_Access) is
   begin
      null;
   end Ignore_Notification;

end LSP.Servers.Handlers;
