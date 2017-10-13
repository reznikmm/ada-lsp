with League.JSON.Objects;
with League.Strings.Hash;

with LSP.Messages;
with LSP.Message_Handlers;
with LSP.Servers;
with LSP.Stdio_Streams;
with LSP.Types;

with LSP_Documents;
with Ada.Containers.Hashed_Maps;

with Ada_Wellknown;
with Checkers;

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
      Checker   : Checkers.Checker;
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

   overriding procedure Workspace_Did_Change_Configuration
    (Self     : access Message_Handler;
     Value    : LSP.Messages.DidChangeConfigurationParams);

   overriding procedure Text_Document_Code_Action_Request
    (Self     : access Message_Handler;
     Value    : LSP.Messages.CodeActionParams;
     Response : in out LSP.Messages.CodeAction_Response);

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
      Commands              : LSP.Types.LSP_String_Vector;
   begin
      Completion_Characters.Append (+"'");
      Commands.Append (+"Insert_Semicolon");

      Response.result.capabilities.textDocumentSync :=
        (Is_Set => True, Is_Number => True, Value => LSP.Messages.Full);

      Response.result.capabilities.completionProvider :=
        (Is_Set => True, Value =>
           (resolveProvider   => LSP.Types.Optional_False,
            triggerCharacters => Completion_Characters));

      Response.result.capabilities.codeActionProvider :=
        LSP.Types.Optional_True;

      Response.result.capabilities.executeCommandProvider :=
        (commands => Commands);
   end Initialize_Request;

   ---------------------------------------
   -- Text_Document_Code_Action_Request --
   ---------------------------------------

   overriding procedure Text_Document_Code_Action_Request
    (Self     : access Message_Handler;
     Value    : LSP.Messages.CodeActionParams;
     Response : in out LSP.Messages.CodeAction_Response)
   is
      pragma Unreferenced (Self);
      use type League.Strings.Universal_String;
   begin
      for Item of Value.context.diagnostics loop
         if Item.message = +"missing "";""" then
            declare
               Command : LSP.Messages.Command;
            begin
               Command.title := +"Insert semicolon";
               Command.command := +"Insert_Semicolon";
               Response.result.Append (Command);
            end;
         end if;
      end loop;
   end Text_Document_Code_Action_Request;

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

   Server  : LSP.Servers.Server;

   ----------------------------
   -- Text_Document_Did_Save --
   ----------------------------

   overriding procedure Text_Document_Did_Save
     (Self  : access Message_Handler;
      Value : LSP.Messages.DidSaveTextDocumentParams)
   is
      File : constant LSP.Types.LSP_String :=
        Value.textDocument.uri.Tail_From (8);  --  skip 'file://' schema
      Note : LSP.Messages.PublishDiagnostics_Notification;
   begin
      Self.Checker.Run (File, Note.params.diagnostics);

      Note.method := +"textDocument/publishDiagnostics";
      Note.params.uri := Value.textDocument.uri;
      Server.Send_Notification (Note);
   end Text_Document_Did_Save;

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

   ----------------------------------------
   -- Workspace_Did_Change_Configuration --
   ----------------------------------------

   overriding procedure Workspace_Did_Change_Configuration
    (Self     : access Message_Handler;
     Value    : LSP.Messages.DidChangeConfigurationParams)
   is
      Ada : League.JSON.Objects.JSON_Object;
   begin
      if Value.settings.To_Object.Contains (+"ada") then
         Ada := Value.settings.To_Object.Value (+"ada").To_Object;
      end if;

      if Ada.Contains (+"project_file") then
         Self.Checker.Initialize (Ada.Value (+"project_file").To_String);
      end if;
   end Workspace_Did_Change_Configuration;

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
