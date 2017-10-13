with League.Strings.Hash;

with LSP.Messages;
with LSP.Message_Handlers;
with LSP.Servers;
with LSP.Stdio_Streams;
with LSP.Types;

with LSP_Documents;
with Ada.Containers.Hashed_Maps;

with Ada_Wellknown;

procedure LSP_Test is

   function "+" (Text : Wide_Wide_String)
      return League.Strings.Universal_String renames
       League.Strings.To_Universal_String;

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

   overriding procedure Text_Document_Did_Change
     (Self  : access Message_Handler;
      Value : LSP.Messages.DidChangeTextDocumentParams);

   overriding procedure Text_Document_Did_Close
     (Self  : access Message_Handler;
      Value : LSP.Messages.DidCloseTextDocumentParams);

   overriding procedure Text_Document_Did_Save
     (Self  : access Message_Handler;
      Value : LSP.Messages.DidSaveTextDocumentParams);

   overriding procedure Text_Document_Completion_Request
    (Self     : access Message_Handler;
     Value    : LSP.Messages.TextDocumentPositionParams;
     Response : in out LSP.Messages.Completion_Response);

   ------------------------
   -- Initialize_Request --
   ------------------------

   overriding procedure Initialize_Request
    (Self     : access Message_Handler;
     Value    : LSP.Messages.InitializeParams;
     Response : in out LSP.Messages.Initialize_Response)
   is
      pragma Unreferenced (Self, Value);

      Completion_Characters : LSP.Types.LSP_String_Vector;
   begin
      Completion_Characters.Append (+"'");
      Response.result.capabilities.textDocumentSync :=
        (Is_Set => True, Is_Number => True, Value => LSP.Messages.Full);
      Response.result.capabilities.completionProvider :=
        (Is_Set => True, Value =>
           (resolveProvider   => LSP.Types.Optional_False,
            triggerCharacters => Completion_Characters));
   end Initialize_Request;

   --------------------------------------
   -- Text_Document_Completion_Request --
   --------------------------------------

   overriding procedure Text_Document_Completion_Request
    (Self     : access Message_Handler;
     Value    : LSP.Messages.TextDocumentPositionParams;
     Response : in out LSP.Messages.Completion_Response)
   is
      Document : LSP_Documents.Document renames
        Self.Documents (Value.textDocument.uri);
      Position : constant Natural := Natural (Value.position.character);
      Line     : constant LSP.Types.LSP_String := Document.Get_Line
        (Value.position.line);
   begin
      if Position in 1 .. Line.Length
        and then Line (Position).To_Wide_Wide_Character = '''
      then
         Response.result.items.Append (Ada_Wellknown.Attributes);

         --  Remove extra ' after cursor (if any)
         if Position + 1 in 1 .. Line.Length
           and then Line (Position + 1).To_Wide_Wide_Character = '''
         then
            declare
               use type LSP.Types.UTF_16_Index;
               Edit : constant LSP.Messages.TextEdit :=
                 (((Value.position.line, Value.position.character),
                   (Value.position.line, Value.position.character + 1)),
                  others => <>);
            begin
               for Item of Response.result.items loop
                  Item.additionalTextEdits.Append (Edit);
               end loop;
            end;
         end if;
      end if;
   end Text_Document_Completion_Request;

   ------------------------------
   -- Text_Document_Did_Change --
   ------------------------------

   overriding procedure Text_Document_Did_Change
     (Self  : access Message_Handler;
      Value : LSP.Messages.DidChangeTextDocumentParams)
   is
      Document : LSP_Documents.Document;
   begin
      Document.Initalize (Value.contentChanges.Last_Element.text);
      Self.Documents.Replace (Value.textDocument.uri, Document);
   end Text_Document_Did_Change;

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

   ----------------------------
   -- Text_Document_Did_Save --
   ----------------------------

   overriding procedure Text_Document_Did_Save
     (Self  : access Message_Handler;
      Value : LSP.Messages.DidSaveTextDocumentParams) is
   begin
      null;
   end Text_Document_Did_Save;

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
   Ada_Wellknown.Initialize;
   Server.Initialize
     (Stream'Unchecked_Access,
      Handler'Unchecked_Access,
      Handler'Unchecked_Access);
   Server.Run;
end LSP_Test;
