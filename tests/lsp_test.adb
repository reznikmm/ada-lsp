with LSP.Messages;
with LSP.Request_Handlers;
with LSP.Servers;
with LSP.Stdio_Streams;

procedure LSP_Test is
   type Request_Handler is new LSP.Request_Handlers.Request_Handler
     with null record;

   overriding procedure Initialize_Request
    (Self     : access Request_Handler;
     Value    : LSP.Messages.InitializeParams;
     Response : in out LSP.Messages.Initialize_Response);

   overriding procedure Initialize_Request
    (Self     : access Request_Handler;
     Value    : LSP.Messages.InitializeParams;
     Response : in out LSP.Messages.Initialize_Response)
   is
      pragma Unreferenced (Self, Value);
   begin
      Response.result.capabilities.hoverProvider := (True, False);
   end Initialize_Request;

   Handler : aliased Request_Handler;
   Stream  : aliased LSP.Stdio_Streams.Stdio_Stream;
   Server  : LSP.Servers.Server;
begin
   Server.Initialize (Stream'Unchecked_Access, Handler'Unchecked_Access);
   Server.Run;
end LSP_Test;
