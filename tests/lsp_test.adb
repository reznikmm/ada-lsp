with LSP.Messages;
with LSP.Request_Handlers;
with LSP.Servers;
with LSP.Stdio_Streams;
with LSP.Types;

procedure LSP_Test is
   type Request_Handler is new LSP.Request_Handlers.Request_Handler
     with null record;

   overriding procedure Initialize_Request
     (Self     : access Request_Handler;
      Response : in out LSP.Messages.ResponseMessage;
      Id       : LSP.Types.LSP_Number_Or_String;
      Value    : LSP.Messages.InitializeParams);

   overriding procedure Initialize_Request
     (Self     : access Request_Handler;
      Response : in out LSP.Messages.ResponseMessage;
      Id       : LSP.Types.LSP_Number_Or_String;
      Value    : LSP.Messages.InitializeParams) is
   begin
      null;
   end Initialize_Request;

   Handler : aliased Request_Handler;
   Stream  : aliased LSP.Stdio_Streams.Stdio_Stream;
   Server  : LSP.Servers.Server;
begin
   Server.Initialize (Stream'Unchecked_Access, Handler'Unchecked_Access);
   Server.Run;
end LSP_Test;
