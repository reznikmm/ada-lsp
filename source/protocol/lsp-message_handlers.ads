with LSP.Messages;

package LSP.Message_Handlers is
   pragma Preelaborate;

   type Request_Handler is limited interface;
   type Request_Handler_Access is access all Request_Handler'Class;

   not overriding procedure Initialize_Request
    (Self     : access Request_Handler;
     Value    : LSP.Messages.InitializeParams;
     Response : in out LSP.Messages.Initialize_Response) is null;

   not overriding procedure Shutdown_Request
    (Self     : access Request_Handler;
     Response : in out LSP.Messages.ResponseMessage) is null;

   not overriding procedure Text_Document_Code_Action_Request
    (Self     : access Request_Handler;
     Value    : LSP.Messages.CodeActionParams;
     Response : in out LSP.Messages.CodeAction_Response) is null;

   not overriding procedure Text_Document_Completion_Request
    (Self     : access Request_Handler;
     Value    : LSP.Messages.TextDocumentPositionParams;
     Response : in out LSP.Messages.Completion_Response) is null;

   not overriding procedure Text_Document_Definition_Request
    (Self     : access Request_Handler;
     Value    : LSP.Messages.TextDocumentPositionParams;
     Response : in out LSP.Messages.Location_Response) is null;

   not overriding procedure Text_Document_Hover_Request
    (Self     : access Request_Handler;
     Value    : LSP.Messages.TextDocumentPositionParams;
     Response : in out LSP.Messages.Hover_Response) is null;

   not overriding procedure Text_Document_Highlight_Request
    (Self     : access Request_Handler;
     Value    : LSP.Messages.TextDocumentPositionParams;
     Response : in out LSP.Messages.Highlight_Response) is null;

   not overriding procedure Text_Document_References_Request
    (Self     : access Request_Handler;
     Value    : LSP.Messages.ReferenceParams;
     Response : in out LSP.Messages.Location_Response) is null;

   not overriding procedure Text_Document_Signature_Help_Request
    (Self     : access Request_Handler;
     Value    : LSP.Messages.TextDocumentPositionParams;
     Response : in out LSP.Messages.SignatureHelp_Response) is null;

   not overriding procedure Text_Document_Symbol_Request
    (Self     : access Request_Handler;
     Value    : LSP.Messages.DocumentSymbolParams;
     Response : in out LSP.Messages.Symbol_Response) is null;

   not overriding procedure Workspace_Execute_Command_Request
    (Self     : access Request_Handler;
     Value    : LSP.Messages.ExecuteCommandParams;
     Response : in out LSP.Messages.ExecuteCommand_Response) is null;

   not overriding procedure Workspace_Symbol_Request
    (Self     : access Request_Handler;
     Value    : LSP.Messages.WorkspaceSymbolParams;
     Response : in out LSP.Messages.Symbol_Response) is null;

   type Notification_Handler is limited interface;
   type Notification_Handler_Access is access all Notification_Handler'Class;

   not overriding procedure Workspace_Did_Change_Configuration
    (Self     : access Notification_Handler;
     Value    : LSP.Messages.DidChangeConfigurationParams) is null;

   not overriding procedure Text_Document_Did_Open
     (Self  : access Notification_Handler;
      Value : LSP.Messages.DidOpenTextDocumentParams) is null;

   not overriding procedure Text_Document_Did_Change
     (Self  : access Notification_Handler;
      Value : LSP.Messages.DidChangeTextDocumentParams) is null;

   not overriding procedure Text_Document_Did_Save
     (Self  : access Notification_Handler;
      Value : LSP.Messages.DidSaveTextDocumentParams) is null;

   not overriding procedure Text_Document_Did_Close
     (Self  : access Notification_Handler;
      Value : LSP.Messages.DidCloseTextDocumentParams) is null;

   not overriding procedure Exit_Notification
    (Self : access Notification_Handler) is null;

end LSP.Message_Handlers;
