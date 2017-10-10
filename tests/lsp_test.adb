with LSP.Messages;
with LSP.Message_Handlers;
with LSP.Servers;
with LSP.Stdio_Streams;

procedure LSP_Test is
   type Message_Handler is new LSP.Message_Handlers.Request_Handler
     and LSP.Message_Handlers.Notification_Handler
       with null record;

   overriding procedure Initialize_Request
    (Self     : access Message_Handler;
     Value    : LSP.Messages.InitializeParams;
     Response : in out LSP.Messages.Initialize_Response);

   overriding procedure Exit_Notification
    (Self : access Message_Handler);

   overriding procedure Initialize_Request
    (Self     : access Message_Handler;
     Value    : LSP.Messages.InitializeParams;
     Response : in out LSP.Messages.Initialize_Response)
   is
      pragma Unreferenced (Self, Value);
   begin
      Response.result.capabilities.hoverProvider := (True, False);
   end Initialize_Request;

   Server  : LSP.Servers.Server;

   overriding procedure Exit_Notification
     (Self : access Message_Handler)
   is
      pragma Unreferenced (Self);
   begin
      Server.Stop;
   end Exit_Notification;

   Handler : aliased Message_Handler;
   Stream  : aliased LSP.Stdio_Streams.Stdio_Stream;
begin
   Server.Initialize (Stream'Unchecked_Access, Handler'Unchecked_Access);
   Server.Run;
end LSP_Test;
