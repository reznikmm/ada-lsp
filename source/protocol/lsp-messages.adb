with League.Holders;
with League.JSON.Streams;
with League.JSON.Values;

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

   procedure Read_Optional_String
    (Stream : in out League.JSON.Streams.JSON_Stream'Class;
     Key    : League.Strings.Universal_String;
     Item   : out LSP.Types.Optional_String);

   procedure Read_String
    (Stream : in out League.JSON.Streams.JSON_Stream'Class;
     Key    : League.Strings.Universal_String;
     Item   : out LSP.Types.LSP_String) renames LSP.Types.Read_String;

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

   procedure Write_String_Vector
    (Stream : in out League.JSON.Streams.JSON_Stream'Class;
     Key    : League.Strings.Universal_String;
     Item   : LSP.Types.LSP_String_Vector);

   ----------
   -- Read --
   ----------

   not overriding procedure Read
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : out completion)
   is
      use type League.Strings.Universal_String;
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      Read_Optional_Boolean
        (JS, +"dynamicRegistration", V.dynamicRegistration);
      Read_Optional_Boolean (JS, +"snippetSupport", V.snippetSupport);
      JS.End_Object;
   end Read;

   ----------
   -- Read --
   ----------

   not overriding procedure Read
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : out ClientCapabilities)
   is
      use type League.Strings.Universal_String;
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      JS.Key (+"workspace");
      WorkspaceClientCapabilities'Read (S, V.workspace);
      JS.Key (+"textDocument");
      TextDocumentClientCapabilities'Read (S, V.textDocument);
      JS.End_Object;
   end Read;

   ----------
   -- Read --
   ----------

   not overriding procedure Read
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : out dynamicRegistration)
   is
      use type League.Strings.Universal_String;
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      Read_Optional_Boolean
        (JS, +"dynamicRegistration", Optional_Boolean (V));
      JS.End_Object;
   end Read;

   ----------
   -- Read --
   ----------

   procedure Read
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
   end Read;

   ----------
   -- Read --
   ----------

   not overriding procedure Read
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
   end Read;

   ----------
   -- Read --
   ----------

   not overriding procedure Read
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
   end Read;

   ----------
   -- Read --
   ----------

   not overriding procedure Read
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
   end Read;

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
         Item := League.IRIs.From_Universal_String (Stream.Read.To_String);
      end if;
   end Read_IRI;

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

   --------------------------
   -- Read_Optional_String --
   --------------------------

   procedure Read_Optional_String
    (Stream : in out League.JSON.Streams.JSON_Stream'Class;
     Key    : League.Strings.Universal_String;
     Item   : out LSP.Types.Optional_String)
   is
      Value : League.JSON.Values.JSON_Value;
   begin
      Stream.Key (Key);
      Value := Stream.Read;

      if Value.Is_Null then
         Item := (Is_Set => False);
      else
         Item := (Is_Set => True, Value => Value.To_String);
      end if;
   end Read_Optional_String;

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
      Write_String (JS, +"jsonrpc", V.jsonrpc);

      if V.id.Is_Number then
         Write_Number (JS, +"id", V.id.Number);
      elsif not V.id.String.Is_Empty then
         Write_String (JS, +"id", V.id.String);
      end if;

      JS.Key (+"error");
      Optional_ResponseError'Write (S, V.error);
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
         Stream.Key (Key);
         Write_Number (Stream, Key, Item.Value);
      end if;
   end Write_Optional_Number;

   --------------------------------------------
   -- Write_Optional_TextDocumentSyncOptions --
   --------------------------------------------

   not overriding procedure Write_Optional_TextDocumentSyncOptions
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : Optional_TextDocumentSyncOptions)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      if not V.Is_Set then
         return;
      elsif V.Is_Number then
         JS.Write
           (League.JSON.Values.To_JSON_Value
              (League.Holders.Universal_Integer (V.Value)));
      else
         TextDocumentSyncOptions'Write (S, V.Options);
      end if;
   end Write_Optional_TextDocumentSyncOptions;

   -------------------------
   -- Write_ResponseError --
   -------------------------

   not overriding procedure Write_ResponseError
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : ResponseError)
   is
      use type League.Holders.Universal_Integer;

      Map : constant array (ErrorCodes) of League.Holders.Universal_Integer :=
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

      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      JS.Key (+"code");
      JS.Write (League.JSON.Values.To_JSON_Value (Map (V.code)));
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
      Write_String (JS, +"jsonrpc", V.jsonrpc);

      if V.id.Is_Number then
         Write_Number (JS, +"id", V.id.Number);
      elsif not V.id.String.Is_Empty then
         Write_String (JS, +"id", V.id.String);
      end if;

      JS.Key (+"error");
      Optional_ResponseError'Write (S, V.error);
      JS.End_Object;
   end Write_ResponseMessage;

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
      Optional_CompletionOptions'Write (S, V.completionProvider);
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
      Optional_DocumentOnTypeFormattingOptions'Write
        (S, V.documentOnTypeFormattingProvider);
      Write_Optional_Boolean (JS, +"renameProvider", V.renameProvider);
      DocumentLinkOptions'Write (S, V.documentLinkProvider);
      ExecuteCommandOptions'Write (S, V.executeCommandProvider);
      JS.End_Object;
   end Write_ServerCapabilities;

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
      Write_Optional_Number (JS, +"change", V.change);
      Write_Optional_Boolean (JS, +"willSave", V.willSave);
      Write_Optional_Boolean (JS, +"willSaveWaitUntil", V.willSaveWaitUntil);
      Write_Optional_Boolean (JS, +"save", V.save);
      JS.End_Object;
   end Write_TextDocumentSyncOptions;

end LSP.Messages;
