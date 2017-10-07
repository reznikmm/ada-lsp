with LSP.Messages;
with LSP.Request_Handlers;
with LSP.Types;

pragma Unreferenced (LSP.Types);
pragma Unreferenced (LSP.Messages);

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

begin
   null;
end LSP_Test;
