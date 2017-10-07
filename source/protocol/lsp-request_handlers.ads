with LSP.Types;
with LSP.Messages;

package LSP.Request_Handlers is
   pragma Preelaborate;

   type Request_Handler is limited interface;
   type Request_Handler_Access is access all Request_Handler'Class;

   not overriding procedure Initialize_Request
     (Self     : access Request_Handler;
      Response : in out LSP.Messages.ResponseMessage;
      Id       : LSP.Types.LSP_Number_Or_String;
      Value    : LSP.Messages.InitializeParams) is null;

end LSP.Request_Handlers;
