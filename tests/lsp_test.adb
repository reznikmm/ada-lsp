with League.Strings.Hash;

with LSP.Messages;
with LSP.Message_Handlers;
with LSP.Servers;
with LSP.Stdio_Streams;

with LSP_Documents;
with Ada.Containers.Hashed_Maps;

procedure LSP_Test is

   package Document_Maps is new Ada.Containers.Hashed_Maps
     (Key_Type        => LSP.Messages.DocumentUri,
      Element_Type    => LSP_Documents.Document,
      Hash            => League.Strings.Hash,
      Equivalent_Keys => League.Strings."=",
      "="             => LSP_Documents."=");

   type Message_Handler is new LSP.Message_Handlers.Request_Handler
     and LSP.Message_Handlers.Notification_Handler with record
      Documents : Document_Maps.Map;
   end record;

   overriding procedure Initialize_Request
    (Self     : access Message_Handler;
     Value    : LSP.Messages.InitializeParams;
     Response : in out LSP.Messages.Initialize_Response);

   overriding procedure Exit_Notification
    (Self : access Message_Handler);

   overriding procedure Text_Document_Did_Open
     (Self  : access Message_Handler;
      Value : LSP.Messages.DidOpenTextDocumentParams);

   overriding procedure Text_Document_Did_Close
     (Self  : access Message_Handler;
      Value : LSP.Messages.DidCloseTextDocumentParams);

   ------------------------
   -- Initialize_Request --
   ------------------------

   overriding procedure Initialize_Request
    (Self     : access Message_Handler;
     Value    : LSP.Messages.InitializeParams;
     Response : in out LSP.Messages.Initialize_Response)
   is
      pragma Unreferenced (Self, Value);
   begin
      Response.result.capabilities.textDocumentSync :=
        (Is_Set => True, Is_Number => True, Value => LSP.Messages.Full);
   end Initialize_Request;

   -----------------------------
   -- Text_Document_Did_Close --
   -----------------------------

   overriding procedure Text_Document_Did_Close
     (Self  : access Message_Handler;
      Value : LSP.Messages.DidCloseTextDocumentParams) is
   begin
      Self.Documents.Delete (Value.textDocument.uri);
   end Text_Document_Did_Close;

   ----------------------------
   -- Text_Document_Did_Open --
   ----------------------------

   overriding procedure Text_Document_Did_Open
     (Self  : access Message_Handler;
      Value : LSP.Messages.DidOpenTextDocumentParams)
   is
      Document : LSP_Documents.Document;
   begin
      Document.Initalize (Value.textDocument.text);
      Self.Documents.Include (Value.textDocument.uri, Document);
   end Text_Document_Did_Open;

   Server  : LSP.Servers.Server;

   -----------------------
   -- Exit_Notification --
   -----------------------

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
   Server.Initialize
     (Stream'Unchecked_Access,
      Handler'Unchecked_Access,
      Handler'Unchecked_Access);
   Server.Run;
end LSP_Test;
