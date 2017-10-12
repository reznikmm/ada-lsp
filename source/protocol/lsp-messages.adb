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

   procedure Read_Number
    (Stream : in out League.JSON.Streams.JSON_Stream'Class;
     Key    : League.Strings.Universal_String;
     Item   : out LSP.Types.LSP_Number);

   procedure Write_Response_Prexif
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : LSP.Messages.ResponseMessage'Class);

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
   pragma Unreferenced (Write_Optional_Number);

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

   ----------
   -- Read --
   ----------

   not overriding procedure Read_completion
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
   end Read_completion;

   -----------------------------
   -- Read_ClientCapabilities --
   -----------------------------

   not overriding procedure Read_ClientCapabilities
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
   end Read_ClientCapabilities;

   ---------------------------------------
   -- Read_DidChangeConfigurationParams --
   ---------------------------------------

   not overriding procedure Read_DidChangeConfigurationParams
     (S : access Ada.Streams.Root_Stream_Type'Class;
      V : out DidChangeConfigurationParams)
   is
      use type League.Strings.Universal_String;
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      JS.Key (+"settings");
      V.settings := JS.Read;
      JS.End_Object;
   end Read_DidChangeConfigurationParams;

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

   ------------------------------
   -- Read_dynamicRegistration --
   ------------------------------

   not overriding procedure Read_dynamicRegistration
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
   end Read_dynamicRegistration;

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
      JS.End_Object;
   end Write_Command;

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
      TextEdit'Write (S, V.textEdit);

      if not V.additionalTextEdits.Is_Empty then
         JS.Key (+"additionalTextEdits");
         JS.Start_Array;
         for Item of V.additionalTextEdits loop
            TextEdit'Write (S, Item);
         end loop;
         JS.End_Array;
      end if;

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
      use type League.Holders.Universal_Integer;
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
      use type League.Holders.Universal_Integer;
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Write
        (League.JSON.Values.To_JSON_Value
           (League.Holders.Universal_Integer
                (InsertTextFormat'Pos (V)) + 1));
   end Write_InsertTextFormat;

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
      Write_Response_Prexif (S, V);
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

end LSP.Messages;
