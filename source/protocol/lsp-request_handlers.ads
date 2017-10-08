with LSP.Messages;

package LSP.Request_Handlers is
   pragma Preelaborate;

   type Request_Handler is limited interface;
   type Request_Handler_Access is access all Request_Handler'Class;

   not overriding procedure Initialize_Request
    (Self     : access Request_Handler;
     Value    : LSP.Messages.InitializeParams;
     Response : in out LSP.Messages.Initialize_Response) is null;

end LSP.Request_Handlers;
