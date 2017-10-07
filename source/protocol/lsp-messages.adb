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

   procedure Read_Number_Or_String
    (Stream : in out League.JSON.Streams.JSON_Stream'Class;
     Key    : League.Strings.Universal_String;
     Item   : out LSP.Types.LSP_Number_Or_String);

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
     Item   : out LSP.Types.LSP_String);

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
      V : out RequestMessage)
   is
      JS : League.JSON.Streams.JSON_Stream'Class renames
        League.JSON.Streams.JSON_Stream'Class (S.all);
   begin
      JS.Start_Object;
      Read_String (JS, +"jsonrpc", V.jsonrpc);
      Read_String (JS, +"method", V.method);
      Read_Number_Or_String (JS, +"id", V.id);
      JS.Key (+"params");
      RequestMessage'Class (V).Read_Parameters (S);
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
   -- Read_Number_Or_String --
   ---------------------------

   procedure Read_Number_Or_String
    (Stream : in out League.JSON.Streams.JSON_Stream'Class;
     Key    : League.Strings.Universal_String;
     Item   : out LSP.Types.LSP_Number_Or_String)
   is
      Value : League.JSON.Values.JSON_Value;
   begin
      Stream.Key (Key);
      Value := Stream.Read;

      if Value.Is_String then
         Item := (Is_Number => False, String => Value.To_String);
      else
         Item := (Is_Number => True, Number => Integer (Value.To_Integer));
      end if;
   end Read_Number_Or_String;

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
   -----------------
   -- Read_String --
   -----------------

   procedure Read_String
    (Stream : in out League.JSON.Streams.JSON_Stream'Class;
     Key    : League.Strings.Universal_String;
     Item   : out LSP.Types.LSP_String) is
   begin
      Stream.Key (Key);
      Item := Stream.Read.To_String;
   end Read_String;

end LSP.Messages;
