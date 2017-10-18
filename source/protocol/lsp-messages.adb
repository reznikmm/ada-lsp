with League.Holders;
with League.JSON.Arrays;
with League.JSON.Streams;
with League.JSON.Values;

------------------
-- LSP.Messages --
------------------

------------------
-- LSP.Messages --
------------------

package body LSP.Messages is

   function "+" (Text : Wide_Wide_String)
      return League.Strings.Universal_String renames
       League.Strings.To_Universal_String;

   procedure Read_IRI
    (Stream : in out League.JSON.Streams.JSON_Stream'Class;
     Key    : League.Strings.Universal_String;
     Item   : out LSP.Messages.DocumentUri);

   procedure Read_Optional_Boolean
    (Stream : in out League.JSON.Streams.JSON_Stream'Class;
     Key    : League.Strings.Universal_String;
     Item   : out LSP.Types.Optional_Boolean);

   procedure Read_Optional_Number
    (Stream : in out League.JSON.Streams.JSON_Stream'Class;
     Key    : League.Strings.Universal_String;
     Item   : out LSP.Types.Optional_Number);

   procedure Read_Number
    (Stream : in out League.JSON.Streams.JSON_Stream'Class;
     Key    : League.Strings.Universal_String;
     Item   : out LSP.Types.LSP_Number);

   procedure Write_Response_Prexif
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : LSP.Messages.ResponseMessage'Class);

   procedure Write_Request_Prexif
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : LSP.Messages.RequestMessage'Class);

   procedure Write_Number
    (Stream : in out League.JSON.Streams.JSON_Stream'Class;
     Key    : League.Strings.Universal_String;
     Item   : LSP.Types.LSP_Number);

   procedure Write_Optional_Boolean
    (Stream : in out League.JSON.Streams.JSON_Stream'Class;
     Key    : League.Strings.Universal_String;
     Item   : LSP.Types.Optional_Boolean);

   procedure Write_Optional_Number
    (Stream : in out League.JSON.Streams.JSON_Stream'Class;
     Key    : League.Strings.Universal_String;
     Item   : LSP.Types.Optional_Number);

   procedure Write_String
    (Stream : in out League.JSON.Streams.JSON_Stream'Class;
     Key    : League.Strings.Universal_String;
     Item   : LSP.Types.LSP_String);

   procedure Write_Optional_String
    (Stream : in out League.JSON.Streams.JSON_Stream'Class;
     Key    : League.Strings.Universal_String;
     Item   : LSP.Types.Optional_String);

   procedure Write_String_Vector
    (Stream : in out League.JSON.Streams.JSON_Stream'Class;
     Key    : League.Strings.Universal_String;
     Item   : LSP.Types.LSP_String_Vector);

   use type League.Holders.Universal_Integer;
   Error_Map : constant array (ErrorCodes) of League.Holders.Universal_Integer
     :=
     (ParseError           => -32700,
      InvalidRequest       => -32600,
      MethodNotFound       => -32601,
      InvalidParams        => -32602,
      InternalError        => -32603,
      serverErrorStart     => -32099,
      serverErrorEnd       => -32000,
      ServerNotInitialized => -32002,
      UnknownErrorCode     => -32001,
      RequestCancelled     => -32800);

   ----------
   -- Read --
   ----------

   not overriding procedure Read_completion
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : out completion)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      Read_Optional_Boolean
        (JS, +"dynamicRegistration", V.dynamicRegistration);
      Read_Optional_Boolean (JS, +"snippetSupport", V.snippetSupport);
      JS.End_Object;
   end Read_completion;

   ---------------------
   -- Read_Diagnostic --
   ---------------------

   not overriding procedure Read_Diagnostic
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : out Diagnostic)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      JS.Key (+"range");
      Span'Read (S, V.span);
      JS.Key (+"severity");
      Optional_DiagnosticSeverity'Read (S, V.severity);
      LSP.Types.Read_Number_Or_String (JS, +"code", V.code);
      Read_Optional_String (JS, +"source", V.source);
      Read_String (JS, +"message", V.message);
      JS.End_Object;
   end Read_Diagnostic;

   ----------------------------
   -- Read_Diagnostic_Vector --
   ----------------------------

   not overriding procedure Read_Diagnostic_Vector
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : out Diagnostic_Vector)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      V.Clear;
      JS.Start_Array;
      while not JS.End_Of_Array loop
         declare
            Item : Diagnostic;
         begin
            Diagnostic'Read (S, Item);
            V.Append (Item);
         end;
      end loop;
      JS.End_Array;
   end Read_Diagnostic_Vector;

   -----------------------------
   -- Read_ClientCapabilities --
   -----------------------------

   not overriding procedure Read_ClientCapabilities
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : out ClientCapabilities)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      JS.Key (+"workspace");
      WorkspaceClientCapabilities'Read (S, V.workspace);
      JS.Key (+"textDocument");
      TextDocumentClientCapabilities'Read (S, V.textDocument);
      JS.End_Object;
   end Read_ClientCapabilities;

   ----------------------------
   -- Read_CodeActionContext --
   ----------------------------

   not overriding procedure Read_CodeActionContext
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : out CodeActionContext)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      JS.Key (+"diagnostics");
      Diagnostic_Vector'Read (S, V.diagnostics);
      JS.End_Object;
   end Read_CodeActionContext;

   ---------------------------
   -- Read_CodeActionParams --
   ---------------------------

   not overriding procedure Read_CodeActionParams
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : out CodeActionParams)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      JS.Key (+"textDocument");
      TextDocumentIdentifier'Read (S, V.textDocument);
      JS.Key (+"range");
      Span'Read (S, V.span);
      JS.Key (+"context");
      CodeActionContext'Read (S, V.context);
      JS.End_Object;
   end Read_CodeActionParams;

   ----------------------
   -- Write_Diagnostic --
   ----------------------

   not overriding procedure Write_Diagnostic
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : Diagnostic)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      JS.Key (+"range");
      Span'Write (S, V.span);
      JS.Key (+"severity");
      Optional_DiagnosticSeverity'Write (S, V.severity);

      if V.code.Is_Number then
         Write_Number (JS, +"code", V.code.Number);
      elsif not V.code.String.Is_Empty then
         Write_String (JS, +"code", V.code.String);
      end if;
      Write_Optional_String (JS, +"source", V.source);
      Write_String (JS, +"message", V.message);
      JS.End_Object;
   end Write_Diagnostic;

   -----------------------------
   -- Write_Diagnostic_Vector --
   -----------------------------

   not overriding procedure Write_Diagnostic_Vector
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : Diagnostic_Vector)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Array;
      for Item of V loop
         Diagnostic'Write (S, Item);
      end loop;
      JS.End_Array;
   end Write_Diagnostic_Vector;

   ---------------------------------------
   -- Read_DidChangeConfigurationParams --
   ---------------------------------------

   not overriding procedure Read_DidChangeConfigurationParams
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : out DidChangeConfigurationParams)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      JS.Key (+"settings");
      V.settings := JS.Read;
      JS.End_Object;
   end Read_DidChangeConfigurationParams;

   --------------------------------------
   -- Read_DidChangeTextDocumentParams --
   --------------------------------------

   not overriding procedure Read_DidChangeTextDocumentParams
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : out DidChangeTextDocumentParams)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      JS.Key (+"textDocument");
      VersionedTextDocumentIdentifier'Read (S, V.textDocument);
      JS.Key (+"contentChanges");
      TextDocumentContentChangeEvent_Vector'Read (S, V.contentChanges);
      JS.End_Object;
   end Read_DidChangeTextDocumentParams;

   -------------------------------------
   -- Read_DidCloseTextDocumentParams --
   -------------------------------------

   not overriding procedure Read_DidCloseTextDocumentParams
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : out DidCloseTextDocumentParams)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      JS.Key (+"textDocument");
      TextDocumentIdentifier'Read (S, V.textDocument);
      JS.End_Object;
   end Read_DidCloseTextDocumentParams;

   ------------------------------------
   -- Read_DidOpenTextDocumentParams --
   ------------------------------------

   not overriding procedure Read_DidOpenTextDocumentParams
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : out DidOpenTextDocumentParams)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      JS.Key (+"textDocument");
      TextDocumentItem'Read (S, V.textDocument);
      JS.End_Object;
   end Read_DidOpenTextDocumentParams;

   ------------------------------------
   -- Read_DidSaveTextDocumentParams --
   ------------------------------------

   not overriding procedure Read_DidSaveTextDocumentParams
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : out DidSaveTextDocumentParams)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      JS.Key (+"textDocument");
      TextDocumentIdentifier'Read (S, V.textDocument);
      Read_Optional_String (JS, +"text", V.text);
      JS.End_Object;
   end Read_DidSaveTextDocumentParams;

   -------------------------------
   -- Read_DocumentSymbolParams --
   -------------------------------

   not overriding procedure Read_DocumentSymbolParams
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : out DocumentSymbolParams)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      JS.Key (+"textDocument");
      TextDocumentIdentifier'Read (S, V.textDocument);
      JS.End_Object;
   end Read_DocumentSymbolParams;

   ---------------------------
   -- Read_TextDocumentEdit --
   ---------------------------

   not overriding procedure Read_TextDocumentEdit
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : out TextDocumentEdit)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      JS.Key (+"textDocument");
      VersionedTextDocumentIdentifier'Read (S, V.textDocument);
      JS.Key (+"edits");
      TextEdit_Vector'Read (S, V.edits);
      JS.End_Object;
   end Read_TextDocumentEdit;

   ---------------------------------
   -- Read_TextDocumentIdentifier --
   ---------------------------------

   not overriding procedure Read_TextDocumentIdentifier
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : out TextDocumentIdentifier)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      JS.Key (+"uri");
      DocumentUri'Read (S, V.uri);
      JS.End_Object;
   end Read_TextDocumentIdentifier;

   ---------------------------
   -- Read_TextDocumentItem --
   ---------------------------

   not overriding procedure Read_TextDocumentItem
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : out TextDocumentItem)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      Read_IRI (JS, +"uri", V.uri);
      Read_String (JS, +"languageId", V.languageId);
      Read_Number (JS, +"version", LSP.Types.LSP_Number (V.version));
      Read_String (JS, +"text", V.text);
      JS.End_Object;
   end Read_TextDocumentItem;

   -------------------------------------
   -- Read_TextDocumentPositionParams --
   -------------------------------------

   not overriding procedure Read_TextDocumentPositionParams
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : out TextDocumentPositionParams)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      JS.Key (+"textDocument");
      TextDocumentIdentifier'Read (S, V.textDocument);
      JS.Key (+"position");
      Position'Read (S, V.position);
      JS.End_Object;
   end Read_TextDocumentPositionParams;

   -------------------
   -- Read_TextEdit --
   -------------------

   not overriding procedure Read_TextEdit
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : out TextEdit)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      JS.Key (+"range");
      Span'Read (S, V.span);
      Read_String (JS, +"newText", V.newText);
      JS.End_Object;
   end Read_TextEdit;

   --------------------------
   -- Read_TextEdit_Vector --
   --------------------------

   not overriding procedure Read_TextEdit_Vector
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : out TextEdit_Vector)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Array;
      while not JS.End_Of_Array loop
         declare
            Item : TextEdit;
         begin
            TextEdit'Read (S, Item);
            V.Append (Item);
         end;
      end loop;
      JS.End_Array;
   end Read_TextEdit_Vector;

   ------------------------------
   -- Read_dynamicRegistration --
   ------------------------------

   not overriding procedure Read_dynamicRegistration
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : out dynamicRegistration)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      Read_Optional_Boolean
        (JS, +"dynamicRegistration", Optional_Boolean (V));
      JS.End_Object;
   end Read_dynamicRegistration;

   -------------------------------
   -- Read_ExecuteCommandParams --
   -------------------------------

   not overriding procedure Read_ExecuteCommandParams
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : out ExecuteCommandParams)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      Read_String (JS, +"command", V.command);
      JS.Key (+"arguments");
      V.arguments := JS.Read;
      JS.End_Object;
   end Read_ExecuteCommandParams;

   ---------------------------
   -- Read_InitializeParams --
   ---------------------------

   procedure Read_InitializeParams
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : out InitializeParams)
   is
      use type League.Strings.Universal_String;
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
      Trace : LSP.Types.Optional_String;
   begin
      JS.Start_Object;
      Read_Optional_Number (JS, +"processId", V.processId);
      Read_String (JS, +"rootPath", V.rootPath);
      Read_IRI (JS, +"rootUri", V.rootUri);
      JS.Key (+"capabilities");
      LSP.Messages.ClientCapabilities'Read (S, V.capabilities);
      Read_Optional_String (JS, +"trace", Trace);

      if not Trace.Is_Set then
         V.trace := LSP.Types.Unspecified;
      elsif Trace.Value = +"off" then
         V.trace := LSP.Types.Off;
      elsif Trace.Value = +"messages" then
         V.trace := LSP.Types.Messages;
      elsif Trace.Value = +"verbose" then
         V.trace := LSP.Types.Verbose;
      end if;

      JS.End_Object;
   end Read_InitializeParams;

   --------------------------
   -- Read_synchronization --
   --------------------------

   not overriding procedure Read_synchronization
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : out synchronization)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      Read_Optional_Boolean
        (JS, +"dynamicRegistration", V.dynamicRegistration);
      Read_Optional_Boolean (JS, +"willSave", V.willSave);
      Read_Optional_Boolean (JS, +"willSaveWaitUntil", V.willSaveWaitUntil);
      Read_Optional_Boolean (JS, +"didSave", V.didSave);
      JS.End_Object;
   end Read_synchronization;

   -----------------------------------------
   -- Read_TextDocumentClientCapabilities --
   -----------------------------------------

   not overriding procedure Read_TextDocumentClientCapabilities
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : out TextDocumentClientCapabilities)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      JS.Key (+"synchronization");
      synchronization'Read (S, V.synchronization);
      JS.Key (+"completion");
      completion'Read (S, V.completion);
      JS.Key (+"hover");
      dynamicRegistration'Read (S, V.hover);
      JS.Key (+"signatureHelp");
      dynamicRegistration'Read (S, V.signatureHelp);
      JS.Key (+"references");
      dynamicRegistration'Read (S, V.references);
      JS.Key (+"documentHighlight");
      dynamicRegistration'Read (S, V.documentHighlight);
      JS.Key (+"documentSymbol");
      dynamicRegistration'Read (S, V.documentSymbol);
      JS.Key (+"formatting");
      dynamicRegistration'Read (S, V.formatting);
      JS.Key (+"rangeFormatting");
      dynamicRegistration'Read (S, V.rangeFormatting);
      JS.Key (+"onTypeFormatting");
      dynamicRegistration'Read (S, V.onTypeFormatting);
      JS.Key (+"definition");
      dynamicRegistration'Read (S, V.definition);
      JS.Key (+"codeAction");
      dynamicRegistration'Read (S, V.codeAction);
      JS.Key (+"codeLens");
      dynamicRegistration'Read (S, V.codeLens);
      JS.Key (+"documentLink");
      dynamicRegistration'Read (S, V.documentLink);
      JS.Key (+"rename");
      dynamicRegistration'Read (S, V.rename);
      JS.End_Object;
   end Read_TextDocumentClientCapabilities;

   -----------------------------------------
   -- Read_TextDocumentContentChangeEvent --
   -----------------------------------------

   not overriding procedure Read_TextDocumentContentChangeEvent
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : out TextDocumentContentChangeEvent)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      JS.Key (+"range");
      Optional_Span'Read (S, V.span);
      Read_Optional_Number (JS, +"rangeLength", V.rangeLength);
      Read_String (JS, +"text", V.text);
      JS.End_Object;
   end Read_TextDocumentContentChangeEvent;

   ------------------------------------------------
   -- Read_TextDocumentContentChangeEvent_Vector --
   ------------------------------------------------

   not overriding procedure Read_TextDocumentContentChangeEvent_Vector
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : out TextDocumentContentChangeEvent_Vector)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      V.Clear;
      JS.Start_Array;
      while not JS.End_Of_Array loop
         declare
            Item : TextDocumentContentChangeEvent;
         begin
            TextDocumentContentChangeEvent'Read (S, Item);
            V.Append (Item);
         end;
      end loop;
      JS.End_Array;
   end Read_TextDocumentContentChangeEvent_Vector;

   ------------------------------------------
   -- Read_VersionedTextDocumentIdentifier --
   ------------------------------------------

   not overriding procedure Read_VersionedTextDocumentIdentifier
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : out VersionedTextDocumentIdentifier)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      JS.Key (+"uri");
      DocumentUri'Read (S, V.uri);
      Read_Number (JS, +"version", LSP_Number (V.version));
      JS.End_Object;
   end Read_VersionedTextDocumentIdentifier;

   --------------------------------------
   -- Read_WorkspaceClientCapabilities --
   --------------------------------------

   not overriding procedure Read_WorkspaceClientCapabilities
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : out WorkspaceClientCapabilities)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      Read_Optional_Boolean (JS, +"applyEdit", V.applyEdit);
      Read_Optional_Boolean (JS, +"workspaceEdit", V.workspaceEdit);
      JS.Key (+"didChangeConfiguration");
      dynamicRegistration'Read (S, V.didChangeConfiguration);
      JS.Key (+"didChangeWatchedFiles");
      dynamicRegistration'Read (S, V.didChangeWatchedFiles);
      JS.Key (+"symbol");
      dynamicRegistration'Read (S, V.symbol);
      JS.Key (+"executeCommand");
      dynamicRegistration'Read (S, V.executeCommand);
      JS.End_Object;
   end Read_WorkspaceClientCapabilities;

   --------------
   -- Read_IRI --
   --------------

   procedure Read_IRI
    (Stream : in out League.JSON.Streams.JSON_Stream'Class;
     Key    : League.Strings.Universal_String;
     Item   : out LSP.Messages.DocumentUri)
   is
      Value : League.JSON.Values.JSON_Value;
   begin
      Stream.Key (Key);
      Value := Stream.Read;

      if Value.Is_Null then
         Item.Clear;
      else
         --  Item := League.IRIs.From_Universal_String (Stream.Read.To_String);
         Item := Stream.Read.To_String;
      end if;
   end Read_IRI;

   -----------------
   -- Read_Number --
   -----------------

   procedure Read_Number
    (Stream : in out League.JSON.Streams.JSON_Stream'Class;
     Key    : League.Strings.Universal_String;
     Item   : out LSP.Types.LSP_Number) is
   begin
      Stream.Key (Key);
      Item := LSP.Types.LSP_Number (Stream.Read.To_Integer);
   end Read_Number;

   ---------------------------
   -- Read_Optional_Boolean --
   ---------------------------

   procedure Read_Optional_Boolean
    (Stream : in out League.JSON.Streams.JSON_Stream'Class;
     Key    : League.Strings.Universal_String;
     Item   : out LSP.Types.Optional_Boolean)
   is
      Value : League.JSON.Values.JSON_Value;
   begin
      Stream.Key (Key);
      Value := Stream.Read;

      if Value.Is_Null then
         Item := (Is_Set => False);
      else
         Item := (Is_Set => True, Value => Value.To_Boolean);
      end if;
   end Read_Optional_Boolean;

   --------------------------
   -- Read_Optional_Number --
   --------------------------

   procedure Read_Optional_Number
    (Stream : in out League.JSON.Streams.JSON_Stream'Class;
     Key    : League.Strings.Universal_String;
     Item   : out LSP.Types.Optional_Number)
   is
      Value : League.JSON.Values.JSON_Value;
   begin
      Stream.Key (Key);
      Value := Stream.Read;

      if Value.Is_Null then
         Item := (Is_Set => False);
      else
         Item := (Is_Set => True, Value => Integer (Value.To_Integer));
      end if;
   end Read_Optional_Number;

   -------------------
   -- Read_Position --
   -------------------

   not overriding procedure Read_Position
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : out Position)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      Read_Number (JS, +"line", LSP_Number (V.line));
      Read_Number (JS, +"character", LSP_Number (V.character));
      JS.End_Object;
   end Read_Position;

   ---------------------------
   -- Read_ReferenceContext --
   ---------------------------

   not overriding procedure Read_ReferenceContext
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : out ReferenceContext)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      JS.Key (+"includeDeclaration");
      V.includeDeclaration := JS.Read.To_Boolean;
      JS.End_Object;
   end Read_ReferenceContext;

   --------------------------
   -- Read_ReferenceParams --
   --------------------------

   not overriding procedure Read_ReferenceParams
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : out ReferenceParams)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      JS.Key (+"textDocument");
      TextDocumentIdentifier'Read (S, V.textDocument);
      JS.Key (+"position");
      Position'Read (S, V.position);
      JS.Key (+"context");
      ReferenceContext'Read (S, V.context);
      JS.End_Object;
   end Read_ReferenceParams;

   ------------------------
   -- Read_ResponseError --
   ------------------------

   not overriding procedure Read_ResponseError
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : out ResponseError)
   is
      Code : League.Holders.Universal_Integer;
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      JS.Key (+"code");
      Code := JS.Read.To_Integer;

      for J in Error_Map'Range loop
         if Error_Map (J) = Code then
            V.code := J;
            exit;
         end if;
      end loop;

      Read_String (JS, +"message", V.message);
      JS.Key (+"data");
      V.data := JS.Read;

      JS.End_Object;
   end Read_ResponseError;

   ---------------
   -- Read_Span --
   ---------------

   not overriding procedure Read_Span
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : out Span)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      JS.Key (+"start");
      Position'Read (S, V.first);
      JS.Key (+"end");
      Position'Read (S, V.last);
      JS.End_Object;
   end Read_Span;

   ---------------------------
   -- Write_CodeLensOptions --
   ---------------------------

   not overriding procedure Write_CodeLensOptions
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : CodeLensOptions)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      Write_Optional_Boolean (JS, +"resolveProvider", V.resolveProvider);
      JS.End_Object;
   end Write_CodeLensOptions;

   -------------------
   -- Write_Command --
   -------------------

   not overriding procedure Write_Command
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : Command)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      if V.command.Is_Empty then
         return;
      end if;

      JS.Start_Object;
      Write_String (JS, +"title", V.title);
      Write_String (JS, +"command", V.command);
      if not V.arguments.Is_Empty then
         JS.Key (+"arguments");
         JS.Write (V.arguments);
      end if;
      JS.End_Object;
   end Write_Command;

   --------------------------------------
   -- Write_ApplyWorkspaceEdit_Request --
   --------------------------------------

   not overriding procedure Write_ApplyWorkspaceEdit_Request
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : ApplyWorkspaceEdit_Request)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      Write_Request_Prexif (S, V);
      Write_String (JS, +"method", V.method);
      JS.Key (+"params");
      ApplyWorkspaceEditParams'Write (S, V.params);
      JS.End_Object;
   end Write_ApplyWorkspaceEdit_Request;

   ------------------------------------
   -- Write_ApplyWorkspaceEditParams --
   ------------------------------------

   not overriding procedure Write_ApplyWorkspaceEditParams
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : ApplyWorkspaceEditParams)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      JS.Key (+"edit");
      WorkspaceEdit'Write (S, V.edit);
      JS.End_Object;
   end Write_ApplyWorkspaceEditParams;

   -------------------------------
   -- Write_CodeAction_Response --
   -------------------------------

   not overriding procedure Write_CodeAction_Response
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : CodeAction_Response)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      Write_Response_Prexif (S, V);
      JS.Key (+"result");
      if V.result.Is_Empty then
         JS.Write (League.JSON.Arrays.Empty_JSON_Array.To_JSON_Value);
      else
         Command_Vector'Write (S, V.result);
      end if;
      JS.End_Object;
   end Write_CodeAction_Response;

   --------------------------
   -- Write_Command_Vector --
   --------------------------

   not overriding procedure Write_Command_Vector
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : Command_Vector)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Array;
      for Item of V loop
         Command'Write (S, Item);
      end loop;
      JS.End_Array;
   end Write_Command_Vector;

   -------------------------------
   -- Write_Completion_Response --
   -------------------------------

   not overriding procedure Write_Completion_Response
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : Completion_Response)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      Write_Response_Prexif (S, V);
      JS.Key (+"result");
      CompletionList'Write (S, V.result);
      JS.End_Object;
   end Write_Completion_Response;

   --------------------------
   -- Write_CompletionItem --
   --------------------------

   not overriding procedure Write_CompletionItem
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : CompletionItem)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      Write_String (JS, +"label", V.label);
      JS.Key (+"kind");
      Optional_CompletionItemKind'Write (S, V.kind);
      Write_Optional_String (JS, +"detail", V.detail);
      Write_Optional_String (JS, +"documentation", V.documentation);
      Write_Optional_String (JS, +"sortText", V.sortText);
      Write_Optional_String (JS, +"filterText", V.filterText);
      Write_Optional_String (JS, +"insertText", V.insertText);
      JS.Key (+"insertTextFormat");
      Optional_InsertTextFormat'Write (S, V.insertTextFormat);
      JS.Key (+"textEdit");
      Optional_TextEdit'Write (S, V.textEdit);
      JS.Key (+"additionalTextEdits");
      TextEdit_Vector'Write (S, V.additionalTextEdits);

      if not V.commitCharacters.Is_Empty then
         Write_String_Vector (JS, +"commitCharacters", V.commitCharacters);
      end if;

      JS.Key (+"command");
      Command'Write (S, V.command);
      JS.End_Object;
   end Write_CompletionItem;

   ------------------------------
   -- Write_CompletionItemKind --
   ------------------------------

   not overriding procedure Write_CompletionItemKind
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : CompletionItemKind)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Write
        (League.JSON.Values.To_JSON_Value
           (League.Holders.Universal_Integer
                (CompletionItemKind'Pos (V)) + 1));
   end Write_CompletionItemKind;

   --------------------------
   -- Write_CompletionList --
   --------------------------

   not overriding procedure Write_CompletionList
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : CompletionList)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      Write_Optional_Boolean (JS, +"isIncomplete", (True, V.isIncomplete));
      JS.Key (+"items");
      JS.Start_Array;

      for Item of V.items loop
         CompletionItem'Write (S, Item);
      end loop;

      JS.End_Array;
      JS.End_Object;
   end Write_CompletionList;

   -----------------------------
   -- Write_CompletionOptions --
   -----------------------------

   not overriding procedure Write_CompletionOptions
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : CompletionOptions)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      Write_Optional_Boolean (JS, +"resolveProvider", V.resolveProvider);
      Write_String_Vector (JS, +"triggerCharacters", V.triggerCharacters);
      JS.End_Object;
   end Write_CompletionOptions;

   ------------------------------
   -- Write_DiagnosticSeverity --
   ------------------------------

   not overriding procedure Write_DiagnosticSeverity
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : DiagnosticSeverity)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Write
        (League.JSON.Values.To_JSON_Value
           (League.Holders.Universal_Integer
                (DiagnosticSeverity'Pos (V)) + 1));
   end Write_DiagnosticSeverity;

   -------------------------------
   -- Write_DocumentLinkOptions --
   -------------------------------

   not overriding procedure Write_DocumentLinkOptions
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : DocumentLinkOptions)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      Write_Optional_Boolean (JS, +"resolveProvider", V.resolveProvider);
      JS.End_Object;
   end Write_DocumentLinkOptions;

   -------------------------------------------
   -- Write_DocumentOnTypeFormattingOptions --
   -------------------------------------------

   not overriding procedure Write_DocumentOnTypeFormattingOptions
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : DocumentOnTypeFormattingOptions)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      Write_String (JS, +"firstTriggerCharacter", V.firstTriggerCharacter);
      Write_String_Vector
        (JS, +"moreTriggerCharacter", V.moreTriggerCharacter);
      JS.End_Object;
   end Write_DocumentOnTypeFormattingOptions;

   -----------------------------------
   -- Write_DocumentSymbol_Response --
   -----------------------------------

   not overriding procedure Write_DocumentSymbol_Response
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : DocumentSymbol_Response)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      Write_Response_Prexif (S, V);
      JS.Key (+"result");
      SymbolInformation_Vector'Write (S, V.result);
      JS.End_Object;
   end Write_DocumentSymbol_Response;

   -----------------------------------
   -- Write_ExecuteCommand_Response --
   -----------------------------------

   not overriding procedure Write_ExecuteCommand_Response
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : ExecuteCommand_Response)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      Write_Response_Prexif (S, V);
      JS.Key (+"result");
      JS.Write (League.JSON.Values.Null_JSON_Value);
      JS.End_Object;
   end Write_ExecuteCommand_Response;

   ---------------------------------
   -- Write_ExecuteCommandOptions --
   ---------------------------------

   not overriding procedure Write_ExecuteCommandOptions
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : ExecuteCommandOptions)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      Write_String_Vector (JS, +"commands", V.commands);
      JS.End_Object;
   end Write_ExecuteCommandOptions;

   -----------------
   -- Write_Hover --
   -----------------

   not overriding procedure Write_Hover
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : Hover)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      JS.Key (+"contents");

      if V.contents.Is_Empty then
         JS.Write (League.JSON.Arrays.Empty_JSON_Array.To_JSON_Value);
      else
         JS.Start_Array;
         for Item of V.contents loop
            MarkedString'Write (S, Item);
         end loop;
         JS.End_Array;
      end if;

      JS.Key (+"range");
      Optional_Span'Write (S, V.Span);
      JS.End_Object;
   end Write_Hover;

   --------------------------
   -- Write_Hover_Response --
   --------------------------

   not overriding procedure Write_Hover_Response
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : Hover_Response)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      Write_Response_Prexif (S, V);
      JS.Key (+"result");
      Hover'Write (S, V.result);
      JS.End_Object;
   end Write_Hover_Response;

   -------------------------------
   -- Write_Initialize_Response --
   -------------------------------

   not overriding procedure Write_Initialize_Response
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : Initialize_Response)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      Write_Response_Prexif (S, V);
      JS.Key (+"result");
      InitializeResult'Write (S, V.result);
      JS.End_Object;
   end Write_Initialize_Response;

   ----------------------------
   -- Write_InitializeResult --
   ----------------------------

   not overriding procedure Write_InitializeResult
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : InitializeResult)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      JS.Key (+"capabilities");
      ServerCapabilities'Write (S, V.capabilities);
      JS.End_Object;
   end Write_InitializeResult;

   ----------------------------
   -- Write_InsertTextFormat --
   ----------------------------

   not overriding procedure Write_InsertTextFormat
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : InsertTextFormat)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Write
        (League.JSON.Values.To_JSON_Value
           (League.Holders.Universal_Integer
                (InsertTextFormat'Pos (V)) + 1));
   end Write_InsertTextFormat;

   --------------------
   -- Write_Location --
   --------------------

   not overriding procedure Write_Location
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : Location)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      JS.Key (+"uri");
      DocumentUri'Write (S, V.uri);
      JS.Key (+"range");
      Span'Write (S, V.span);
      JS.End_Object;
   end Write_Location;

   -----------------------------
   -- Write_Location_Response --
   -----------------------------

   not overriding procedure Write_Location_Response
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : Location_Response)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      Write_Response_Prexif (S, V);
      JS.Key (+"result");
      if V.result.Is_Empty then
         JS.Write (League.JSON.Arrays.Empty_JSON_Array.To_JSON_Value);
      else
         JS.Start_Array;
         for Item of V.result loop
            Location'Write (S, Item);
         end loop;
         JS.End_Array;
      end if;
      JS.End_Object;
   end Write_Location_Response;

   ------------------------
   -- Write_MarkedString --
   ------------------------

   not overriding procedure Write_MarkedString
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : MarkedString)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      if V.Is_String then
         JS.Write (League.JSON.Values.To_JSON_Value (V.value));
      else
         JS.Start_Object;
         Write_String (JS, +"language", V.language);
         Write_String (JS, +"value", V.value);
         JS.End_Object;
      end if;
   end Write_MarkedString;

   ------------------
   -- Write_Number --
   ------------------

   procedure Write_Number
    (Stream : in out League.JSON.Streams.JSON_Stream'Class;
     Key    : League.Strings.Universal_String;
     Item   : LSP.Types.LSP_Number) is
   begin
      Stream.Key (Key);
      Stream.Write
        (League.JSON.Values.To_JSON_Value
           (League.Holders.Universal_Integer (Item)));
   end Write_Number;

   ----------------------------
   -- Write_Optional_Boolean --
   ----------------------------

   procedure Write_Optional_Boolean
    (Stream : in out League.JSON.Streams.JSON_Stream'Class;
     Key    : League.Strings.Universal_String;
     Item   : LSP.Types.Optional_Boolean) is
   begin
      if Item.Is_Set then
         Stream.Key (Key);
         Stream.Write (League.JSON.Values.To_JSON_Value (Item.Value));
      end if;
   end Write_Optional_Boolean;

   ---------------------------
   -- Write_Optional_Number --
   ---------------------------

   procedure Write_Optional_Number
    (Stream : in out League.JSON.Streams.JSON_Stream'Class;
     Key    : League.Strings.Universal_String;
     Item   : LSP.Types.Optional_Number) is
   begin
      if Item.Is_Set then
         Write_Number (Stream, Key, Item.Value);
      end if;
   end Write_Optional_Number;

   ---------------------------
   -- Write_Optional_String --
   ---------------------------

   procedure Write_Optional_String
    (Stream : in out League.JSON.Streams.JSON_Stream'Class;
     Key    : League.Strings.Universal_String;
     Item   : LSP.Types.Optional_String) is
   begin
      if Item.Is_Set then
         Write_String (Stream, Key, Item.Value);
      end if;
   end Write_Optional_String;

   --------------------------------------------
   -- Write_Optional_TextDocumentSyncOptions --
   --------------------------------------------

   not overriding procedure Write_Optional_TextDocumentSyncOptions
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : Optional_TextDocumentSyncOptions) is
   begin
      if not V.Is_Set then
         return;
      elsif V.Is_Number then
         TextDocumentSyncKind'Write (S, V.Value);
      else
         TextDocumentSyncOptions'Write (S, V.Options);
      end if;
   end Write_Optional_TextDocumentSyncOptions;

   --------------------------------
   -- Write_ParameterInformation --
   --------------------------------

   not overriding procedure Write_ParameterInformation
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : ParameterInformation)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      Write_String (JS, +"label", V.label);
      Write_Optional_String (JS, +"documentation", V.documentation);
      JS.End_Object;
   end Write_ParameterInformation;

   --------------------
   -- Write_Position --
   --------------------

   not overriding procedure Write_Position
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : Position)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      Write_Number (JS, +"line", LSP_Number (V.line));
      Write_Number (JS, +"character", LSP_Number (V.character));
      JS.End_Object;
   end Write_Position;

   --------------------------
   -- Write_Request_Prexif --
   --------------------------

   procedure Write_Request_Prexif
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : LSP.Messages.RequestMessage'Class)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      Write_String (JS, +"jsonrpc", V.jsonrpc);

      if V.id.Is_Number then
         Write_Number (JS, +"id", V.id.Number);
      elsif not V.id.String.Is_Empty then
         Write_String (JS, +"id", V.id.String);
      end if;
   end Write_Request_Prexif;

   --------------------
   -- Write_Response --
   --------------------

   procedure Write_Response_Prexif
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : LSP.Messages.ResponseMessage'Class)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      Write_String (JS, +"jsonrpc", V.jsonrpc);

      if V.id.Is_Number then
         Write_Number (JS, +"id", V.id.Number);
      elsif not V.id.String.Is_Empty then
         Write_String (JS, +"id", V.id.String);
      end if;

      JS.Key (+"error");
      Optional_ResponseError'Write (S, V.error);
   end Write_Response_Prexif;

   -------------------------
   -- Write_ResponseError --
   -------------------------

   not overriding procedure Write_ResponseError
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : ResponseError)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      JS.Key (+"code");
      JS.Write (League.JSON.Values.To_JSON_Value (Error_Map (V.code)));
      Write_String (JS, +"message", V.message);

      if not V.data.Is_Empty and not V.data.Is_Empty then
         JS.Key (+"data");
         JS.Write (V.data);
      end if;

      JS.End_Object;
   end Write_ResponseError;

   ---------------------------
   -- Write_ResponseMessage --
   ---------------------------

   not overriding procedure Write_ResponseMessage
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : ResponseMessage)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      Write_Response_Prexif (S, V);
      JS.End_Object;
   end Write_ResponseMessage;

   -------------------------------------------
   -- Write_PublishDiagnostics_Notification --
   -------------------------------------------

   not overriding procedure Write_PublishDiagnostics_Notification
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : PublishDiagnostics_Notification)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      Write_String (JS, +"jsonrpc", V.jsonrpc);
      Write_String (JS, +"method", V.method);
      JS.Key (+"params");
      PublishDiagnosticsParams'Write (S, V.params);
      JS.End_Object;
   end Write_PublishDiagnostics_Notification;

   ------------------------------------
   -- Write_PublishDiagnosticsParams --
   ------------------------------------

   not overriding procedure Write_PublishDiagnosticsParams
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : PublishDiagnosticsParams)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      JS.Key (+"uri");
      DocumentUri'Write (S, V.uri);
      JS.Key (+"diagnostics");

      if V.diagnostics.Is_Empty then
         JS.Write (League.JSON.Arrays.Empty_JSON_Array.To_JSON_Value);
      else
         Diagnostic_Vector'Write (S, V.diagnostics);
      end if;

      JS.End_Object;
   end Write_PublishDiagnosticsParams;

   ------------------------------
   -- Write_ServerCapabilities --
   ------------------------------

   not overriding procedure Write_ServerCapabilities
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : ServerCapabilities)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      JS.Key (+"textDocumentSync");
      Optional_TextDocumentSyncOptions'Write (S, V.textDocumentSync);
      Write_Optional_Boolean (JS, +"hoverProvider", V.hoverProvider);
      JS.Key (+"completionProvider");
      Optional_CompletionOptions'Write (S, V.completionProvider);
      JS.Key (+"signatureHelpProvider");
      Optional_SignatureHelpOptions'Write (S, V.signatureHelpProvider);
      Write_Optional_Boolean (JS, +"definitionProvider", V.definitionProvider);
      Write_Optional_Boolean (JS, +"referencesProvider", V.referencesProvider);
      Write_Optional_Boolean
        (JS, +"documentHighlightProvider", V.documentHighlightProvider);
      Write_Optional_Boolean
        (JS, +"documentSymbolProvider", V.documentSymbolProvider);
      Write_Optional_Boolean
        (JS, +"workspaceSymbolProvider", V.workspaceSymbolProvider);
      Write_Optional_Boolean (JS, +"codeActionProvider", V.codeActionProvider);
      Write_Optional_Boolean
        (JS, +"documentFormattingProvider", V.documentFormattingProvider);
      Write_Optional_Boolean
        (JS,
         +"documentRangeFormattingProvider",
         V.documentRangeFormattingProvider);
      JS.Key (+"documentOnTypeFormattingProvider");
      Optional_DocumentOnTypeFormattingOptions'Write
        (S, V.documentOnTypeFormattingProvider);
      Write_Optional_Boolean (JS, +"renameProvider", V.renameProvider);
      JS.Key (+"documentLinkProvider");
      DocumentLinkOptions'Write (S, V.documentLinkProvider);
      JS.Key (+"executeCommandProvider");
      ExecuteCommandOptions'Write (S, V.executeCommandProvider);
      JS.End_Object;
   end Write_ServerCapabilities;

   -------------------------
   -- Write_SignatureHelp --
   -------------------------

   not overriding procedure Write_SignatureHelp
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : SignatureHelp)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;

      JS.Key (+"signatures");
      if V.signatures.Is_Empty then
         JS.Write (League.JSON.Arrays.Empty_JSON_Array.To_JSON_Value);
      else
         JS.Start_Array;
         for Item of V.signatures loop
            SignatureInformation'Write (S, Item);
         end loop;
         JS.End_Array;
      end if;

      Write_Optional_Number (JS, +"activeSignature", V.activeSignature);
      Write_Optional_Number (JS, +"activeParameter", V.activeParameter);
      JS.End_Object;
   end Write_SignatureHelp;

   ----------------------------------
   -- Write_SignatureHelp_Response --
   ----------------------------------

   not overriding procedure Write_SignatureHelp_Response
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : SignatureHelp_Response)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      Write_Response_Prexif (S, V);
      JS.Key (+"result");
      SignatureHelp'Write (S, V.result);
      JS.End_Object;
   end Write_SignatureHelp_Response;

   --------------------------------
   -- Write_SignatureHelpOptions --
   --------------------------------

   not overriding procedure Write_SignatureHelpOptions
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : SignatureHelpOptions)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      Write_String_Vector (JS, +"triggerCharacters", V.triggerCharacters);
      JS.End_Object;
   end Write_SignatureHelpOptions;

   --------------------------------
   -- Write_SignatureInformation --
   --------------------------------

   not overriding procedure Write_SignatureInformation
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : SignatureInformation)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      Write_String (JS, +"label", V.label);
      Write_Optional_String (JS, +"documentation", V.documentation);

      JS.Key (+"parameters");

      if V.parameters.Is_Empty then
         JS.Write (League.JSON.Arrays.Empty_JSON_Array.To_JSON_Value);
      else
         JS.Start_Array;
         for Item of V.parameters loop
            ParameterInformation'Write (S, Item);
         end loop;
         JS.End_Array;
      end if;

      JS.End_Object;
   end Write_SignatureInformation;

   ----------------
   -- Write_Span --
   ----------------

   not overriding procedure Write_Span
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : Span)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      JS.Key (+"start");
      Position'Write (S, V.first);
      JS.Key (+"end");
      Position'Write (S, V.last);
      JS.End_Object;
   end Write_Span;

   ------------------
   -- Write_String --
   ------------------

   procedure Write_String
    (Stream : in out League.JSON.Streams.JSON_Stream'Class;
     Key    : League.Strings.Universal_String;
     Item   : LSP.Types.LSP_String) is
   begin
      Stream.Key (Key);
      Stream.Write (League.JSON.Values.To_JSON_Value (Item));
   end Write_String;

   -------------------------
   -- Write_String_Vector --
   -------------------------

   procedure Write_String_Vector
    (Stream : in out League.JSON.Streams.JSON_Stream'Class;
     Key    : League.Strings.Universal_String;
     Item   : LSP.Types.LSP_String_Vector) is
   begin
      Stream.Key (Key);
      Stream.Start_Array;

      for J in 1 .. Item.Length loop
         Stream.Write (League.JSON.Values.To_JSON_Value (Item.Element (J)));
      end loop;

      Stream.End_Array;
   end Write_String_Vector;

   -----------------------------
   -- Write_SymbolInformation --
   -----------------------------

   not overriding procedure Write_SymbolInformation
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : SymbolInformation)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      Write_String (JS, +"name", V.name);
      JS.Key (+"kind");
      JS.Write
        (League.JSON.Values.To_JSON_Value
           (League.Holders.Universal_Integer
                (SymbolKind'Pos (V.kind)) + 1));

      JS.Key (+"location");
      Location'Write (S, V.location);
      JS.Key (+"edits");
      Write_Optional_String (JS, +"containerName", V.containerName);
      JS.End_Object;
   end Write_SymbolInformation;

   ------------------------------------
   -- Write_SymbolInformation_Vector --
   ------------------------------------

   not overriding procedure Write_SymbolInformation_Vector
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : SymbolInformation_Vector)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      if V.Is_Empty then
         JS.Write (League.JSON.Arrays.Empty_JSON_Array.To_JSON_Value);
      else
         JS.Start_Array;
         for Item of V loop
            SymbolInformation'Write (S, Item);
         end loop;
         JS.End_Array;
      end if;
   end Write_SymbolInformation_Vector;

   ----------------------------
   -- Write_TextDocumentEdit --
   ----------------------------

   not overriding procedure Write_TextDocumentEdit
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : TextDocumentEdit)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      JS.Key (+"textDocument");
      VersionedTextDocumentIdentifier'Write (S, V.textDocument);
      JS.Key (+"edits");
      TextEdit_Vector'Write (S, V.edits);
      JS.End_Object;
   end Write_TextDocumentEdit;

   --------------------------------
   -- Write_TextDocumentSyncKind --
   --------------------------------

   not overriding procedure Write_TextDocumentSyncKind
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : TextDocumentSyncKind)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);

      Map : constant array (TextDocumentSyncKind) of
        League.Holders.Universal_Integer :=
          (None => 0, Full => 1, Incremental => 2);
   begin
      JS.Write (League.JSON.Values.To_JSON_Value (Map (V)));
   end Write_TextDocumentSyncKind;

   -----------------------------------
   -- Write_TextDocumentSyncOptions --
   -----------------------------------

   not overriding procedure Write_TextDocumentSyncOptions
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : TextDocumentSyncOptions)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      Write_Optional_Boolean (JS, +"openClose", V.openClose);
      JS.Key (+"change");
      Optional_TextDocumentSyncKind'Write (S, V.change);
      Write_Optional_Boolean (JS, +"willSave", V.willSave);
      Write_Optional_Boolean (JS, +"willSaveWaitUntil", V.willSaveWaitUntil);
      Write_Optional_Boolean (JS, +"save", V.save);
      JS.End_Object;
   end Write_TextDocumentSyncOptions;

   --------------------
   -- Write_TextEdit --
   --------------------

   not overriding procedure Write_TextEdit
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : TextEdit)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      JS.Key (+"range");
      Span'Write (S, V.span);
      Write_String (JS, +"newText", V.newText);
      JS.End_Object;
   end Write_TextEdit;

   ---------------------------
   -- Write_TextEdit_Vector --
   ---------------------------

   not overriding procedure Write_TextEdit_Vector
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : TextEdit_Vector)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Array;
      for Item of V loop
         TextEdit'Write (S, Item);
      end loop;
      JS.End_Array;
   end Write_TextEdit_Vector;

   -------------------------------------------
   -- Write_VersionedTextDocumentIdentifier --
   -------------------------------------------

   not overriding procedure Write_VersionedTextDocumentIdentifier
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : VersionedTextDocumentIdentifier)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      JS.Key (+"uri");
      DocumentUri'Write (S, V.uri);
      Write_Number (JS, +"version", LSP_Number (V.version));
      JS.End_Object;
   end Write_VersionedTextDocumentIdentifier;

   -------------------------
   -- Write_WorkspaceEdit --
   -------------------------

   not overriding procedure Write_WorkspaceEdit
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : WorkspaceEdit)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      if V.documentChanges.Is_Empty then
         JS.Key (+"changes");
         JS.Start_Object;
         for Cursor in V.changes.Iterate loop
            JS.Key (TextDocumentEdit_Maps.Key (Cursor));
            JS.Start_Array;
            for Edit of V.changes (Cursor) loop
               TextEdit'Write (S, Edit);
            end loop;
            JS.End_Array;
         end loop;
         JS.End_Object;
      else
         JS.Key (+"documentChanges");
         if V.documentChanges.Is_Empty then
            JS.Write (League.JSON.Arrays.Empty_JSON_Array.To_JSON_Value);
         else
            JS.Start_Array;
            for Edit of V.documentChanges loop
               TextDocumentEdit'Write (S, Edit);
            end loop;
            JS.End_Array;
         end if;
      end if;
      JS.End_Object;
   end Write_WorkspaceEdit;

end LSP.Messages;
