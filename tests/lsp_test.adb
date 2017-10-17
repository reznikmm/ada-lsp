with League.JSON.Objects;
with League.JSON.Streams;
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
with Cross_References;

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

   type Message_Handler (Server  : access LSP.Servers.Server) is limited
     new LSP.Message_Handlers.Request_Handler
     and LSP.Message_Handlers.Notification_Handler with record
      Documents : Document_Maps.Map;
      Checker   : Checkers.Checker;
      XRef      : Cross_References.Database;
   end record;

   overriding procedure Initialize_Request
    (Self     : access Message_Handler;
     Value    : LSP.Messages.InitializeParams;
     Response : in out LSP.Messages.Initialize_Response);

   overriding procedure Exit_Notification
    (Self : access Message_Handler);

   overriding procedure Text_Document_Definition_Request
    (Self     : access Message_Handler;
     Value    : LSP.Messages.TextDocumentPositionParams;
     Response : in out LSP.Messages.Definition_Response);

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

   overriding procedure Workspace_Execute_Command_Request
    (Self     : access Message_Handler;
     Value    : LSP.Messages.ExecuteCommandParams;
     Response : in out LSP.Messages.ExecuteCommand_Response);

   overriding procedure Text_Document_Code_Action_Request
    (Self     : access Message_Handler;
     Value    : LSP.Messages.CodeActionParams;
     Response : in out LSP.Messages.CodeAction_Response);

   overriding procedure Text_Document_Hover_Request
    (Self     : access Message_Handler;
     Value    : LSP.Messages.TextDocumentPositionParams;
     Response : in out LSP.Messages.Hover_Response);

   overriding procedure Text_Document_Signature_Help_Request
    (Self     : access Message_Handler;
     Value    : LSP.Messages.TextDocumentPositionParams;
     Response : in out LSP.Messages.SignatureHelp_Response);

   ------------------------
   -- Initialize_Request --
   ------------------------

   overriding procedure Initialize_Request
    (Self     : access Message_Handler;
     Value    : LSP.Messages.InitializeParams;
     Response : in out LSP.Messages.Initialize_Response)
   is
      use type LSP.Types.LSP_String;

      Completion_Characters : LSP.Types.LSP_String_Vector;
      Commands              : LSP.Types.LSP_String_Vector;
      Signature_Keys        : LSP.Types.LSP_String_Vector;
   begin
      Self.XRef.Initialize (Value.rootUri & "/source/protocol/");
      Completion_Characters.Append (+"'");
      Commands.Append (+"Text_Edit");
      Signature_Keys.Append (+"(");
      Signature_Keys.Append (+",");

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

      Response.result.capabilities.hoverProvider := LSP.Types.Optional_True;
      Response.result.capabilities.signatureHelpProvider :=
        (True, (triggerCharacters => Signature_Keys));
      Response.result.capabilities.definitionProvider :=
        LSP.Types.Optional_True;
   end Initialize_Request;

   ---------------------------------------
   -- Text_Document_Code_Action_Request --
   ---------------------------------------

   overriding procedure Text_Document_Code_Action_Request
    (Self     : access Message_Handler;
     Value    : LSP.Messages.CodeActionParams;
     Response : in out LSP.Messages.CodeAction_Response)
   is
      use type League.Strings.Universal_String;
   begin
      for Item of Value.context.diagnostics loop
         if Item.message = +"missing "";""" then
            declare
               Edit      : LSP.Messages.TextDocumentEdit;
               Command   : LSP.Messages.Command;
               JS        : aliased League.JSON.Streams.JSON_Stream;
               Insert    : constant LSP.Messages.TextEdit :=
                 (Value.span, +";");
            begin
               Edit.textDocument :=
                 (Value.textDocument with
                  version => Self.Documents (Value.textDocument.uri).Version);
               Edit.edits.Append (Insert);
               LSP.Messages.TextDocumentEdit'Write (JS'Access, Edit);
               Command.title := +"Insert semicolon";
               Command.command := +"Text_Edit";
               Command.arguments :=
                 JS.Get_JSON_Document.To_JSON_Array.To_JSON_Value;
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

   --------------------------------------
   -- Text_Document_Definition_Request --
   --------------------------------------

   overriding procedure Text_Document_Definition_Request
    (Self     : access Message_Handler;
     Value    : LSP.Messages.TextDocumentPositionParams;
     Response : in out LSP.Messages.Definition_Response)
   is
      Document : LSP_Documents.Document renames
        Self.Documents (Value.textDocument.uri);
      Lookup : constant LSP_Documents.Lookup_Result :=
        Document.Lookup (Value.position);
      Result : LSP.Messages.Location;
      Found  : Boolean := False;
   begin
      case Lookup.Kind is
         when LSP_Documents.Identifier =>
            Self.XRef.Get_Definition (Lookup.Value, Result, Found);

            if Found then
               Response.result.Append (Result);
            end if;
         when others =>
            null;
      end case;
   end Text_Document_Definition_Request;

   ------------------------------
   -- Text_Document_Did_Change --
   ------------------------------

   overriding procedure Text_Document_Did_Change
     (Self  : access Message_Handler;
      Value : LSP.Messages.DidChangeTextDocumentParams)
   is
      Document : LSP_Documents.Document;
   begin
      Document.Initalize
        (Value.contentChanges.Last_Element.text,
         Value.textDocument.version);
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
      Document.Initalize
        (Value.textDocument.text,
         Value.textDocument.version);
      Self.Documents.Include (Value.textDocument.uri, Document);
   end Text_Document_Did_Open;

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
      Self.Server.Send_Notification (Note);
   end Text_Document_Did_Save;

   -----------------------
   -- Exit_Notification --
   -----------------------

   overriding procedure Exit_Notification (Self : access Message_Handler) is
   begin
      Self.Server.Stop;
   end Exit_Notification;

   ---------------------------------
   -- Text_Document_Hover_Request --
   ---------------------------------

   overriding procedure Text_Document_Hover_Request
    (Self     : access Message_Handler;
     Value    : LSP.Messages.TextDocumentPositionParams;
     Response : in out LSP.Messages.Hover_Response)
   is
      Document : LSP_Documents.Document renames
        Self.Documents (Value.textDocument.uri);
      Lookup : constant LSP_Documents.Lookup_Result :=
        Document.Lookup (Value.position);
   begin
      case Lookup.Kind is
         when LSP_Documents.Attribute_Designator =>
            Response.result.contents.Append
              (Ada_Wellknown.Attribute_Hover (Lookup.Value));
         when LSP_Documents.None
            | LSP_Documents.Pragma_Name
            | LSP_Documents.Identifier =>
            null;
      end case;
   end Text_Document_Hover_Request;

   ------------------------------------------
   -- Text_Document_Signature_Help_Request --
   ------------------------------------------

   overriding procedure Text_Document_Signature_Help_Request
    (Self     : access Message_Handler;
     Value    : LSP.Messages.TextDocumentPositionParams;
     Response : in out LSP.Messages.SignatureHelp_Response)
   is
      Document : LSP_Documents.Document renames
        Self.Documents (Value.textDocument.uri);
      Lookup : constant LSP_Documents.Lookup_Result :=
        Document.Lookup (Value.position);
   begin
      case Lookup.Kind is
         when LSP_Documents.Pragma_Name =>
            Response.result.signatures.Append
              (Ada_Wellknown.Pragma_Signatures (Lookup.Name));

            if not Response.result.signatures.Is_Empty then
               if Lookup.Parameter > 0 then
                  Response.result.activeParameter :=
                    (True, Lookup.Parameter - 1);
               end if;
               Response.result.activeSignature := (True, 0);
            end if;
         when LSP_Documents.Attribute_Designator
            | LSP_Documents.Identifier
            | LSP_Documents.None =>
            null;
      end case;
   end Text_Document_Signature_Help_Request;

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

   ---------------------------------------
   -- Workspace_Execute_Command_Request --
   ---------------------------------------

   overriding procedure Workspace_Execute_Command_Request
    (Self     : access Message_Handler;
     Value    : LSP.Messages.ExecuteCommandParams;
     Response : in out LSP.Messages.ExecuteCommand_Response)
   is
      use type League.Strings.Universal_String;
      pragma Unreferenced (Response);
      Params  : LSP.Messages.ApplyWorkspaceEditParams;
      Applied : Boolean;
      Error   : LSP.Messages.Optional_ResponseError;
   begin
      if Value.command = +"Text_Edit" then
         declare
            JS        : aliased League.JSON.Streams.JSON_Stream;
            Edit      : LSP.Messages.TextDocumentEdit;
         begin
            JS.Set_JSON_Document (Value.arguments.To_Array.To_JSON_Document);
            LSP.Messages.TextDocumentEdit'Read (JS'Access, Edit);
            Params.edit.documentChanges.Append (Edit);
            Self.Server.Workspace_Apply_Edit (Params, Applied, Error);
         end;
      end if;
   end Workspace_Execute_Command_Request;

   Server  : aliased LSP.Servers.Server;
   Handler : aliased Message_Handler (Server'Access);
   Stream  : aliased LSP.Stdio_Streams.Stdio_Stream;
begin
   Ada_Wellknown.Initialize;
   Server.Initialize
     (Stream'Unchecked_Access,
      Handler'Unchecked_Access,
      Handler'Unchecked_Access);
   Server.Run;
end LSP_Test;
