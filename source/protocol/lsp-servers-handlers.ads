private package LSP.Servers.Handlers is
   pragma Preelaborate;

   procedure DidChangeConfiguration
    (Stream  : access Ada.Streams.Root_Stream_Type'Class;
     Handler : not null LSP.Message_Handlers.Notification_Handler_Access);

   procedure DidOpenTextDocument
    (Stream  : access Ada.Streams.Root_Stream_Type'Class;
     Handler : not null LSP.Message_Handlers.Notification_Handler_Access);

   procedure DidCloseTextDocument
    (Stream  : access Ada.Streams.Root_Stream_Type'Class;
     Handler : not null LSP.Message_Handlers.Notification_Handler_Access);

   function Do_Completion
    (Stream  : access Ada.Streams.Root_Stream_Type'Class;
     Handler : not null LSP.Message_Handlers.Request_Handler_Access)
      return LSP.Messages.ResponseMessage'Class;

   procedure Do_Exit
    (Stream  : access Ada.Streams.Root_Stream_Type'Class;
     Handler : not null LSP.Message_Handlers.Notification_Handler_Access);

   function Do_Not_Found
    (Stream  : access Ada.Streams.Root_Stream_Type'Class;
     Handler : not null LSP.Message_Handlers.Request_Handler_Access)
      return LSP.Messages.ResponseMessage'Class;

   function Do_Initialize
    (Stream  : access Ada.Streams.Root_Stream_Type'Class;
     Handler : not null LSP.Message_Handlers.Request_Handler_Access)
      return LSP.Messages.ResponseMessage'Class;

   function Do_Shutdown
    (Stream  : access Ada.Streams.Root_Stream_Type'Class;
     Handler : not null LSP.Message_Handlers.Request_Handler_Access)
      return LSP.Messages.ResponseMessage'Class;

   procedure Ignore_Notification
    (Stream  : access Ada.Streams.Root_Stream_Type'Class;
     Handler : not null LSP.Message_Handlers.Notification_Handler_Access);

end LSP.Servers.Handlers;
