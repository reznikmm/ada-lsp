--  Copyright (c) 2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with League.Strings;

with LSP.Types;

with Ada_LSP.Completions;
with Ada_LSP.Documents;

package body Ada_LSP.Handlers is

   function "+" (Text : Wide_Wide_String)
      return League.Strings.Universal_String renames
       League.Strings.To_Universal_String;

   -----------------------
   -- Exit_Notification --
   -----------------------

   overriding procedure Exit_Notification (Self : access Message_Handler) is
   begin
      Self.Server.Stop;
   end Exit_Notification;

   ------------------------
   -- Initialize_Request --
   ------------------------

   overriding procedure Initialize_Request
     (Self     : access Message_Handler;
      Value    : LSP.Messages.InitializeParams;
      Response : in out LSP.Messages.Initialize_Response)
   is
      Root : League.Strings.Universal_String;
      Completion_Characters : LSP.Types.LSP_String_Vector;
   begin
      Completion_Characters.Append (+"'");

      Response.result.capabilities.completionProvider :=
        (Is_Set => True, Value =>
           (resolveProvider   => LSP.Types.Optional_False,
            triggerCharacters => Completion_Characters));
      Response.result.capabilities.documentSymbolProvider :=
        LSP.Types.Optional_True;
      Response.result.capabilities.textDocumentSync :=
        (Is_Set => True, Is_Number => True, Value => LSP.Messages.Incremental);

      if not Value.rootUri.Is_Empty then
         Root := Value.rootUri.Tail_From (8);
      elsif not Value.rootPath.Is_Empty then
         Root := Value.rootPath;
         Root.Prepend ("file://");
      end if;

      Self.Context.Initialize (Root);
   end Initialize_Request;

   --------------------------------------
   -- Text_Document_Completion_Request --
   --------------------------------------

   overriding procedure Text_Document_Completion_Request
    (Self     : access Message_Handler;
     Value    : LSP.Messages.TextDocumentPositionParams;
     Response : in out LSP.Messages.Completion_Response)
   is
      Document : constant Ada_LSP.Documents.Document_Access :=
        Self.Context.Get_Document (Value.textDocument.uri);
      Context : Ada_LSP.Completions.Context;
   begin
      Document.Get_Completion_Context (Value.position, Context);
      Self.Context.Fill_Completions (Context, Response.result);
   end Text_Document_Completion_Request;

   ------------------------------
   -- Text_Document_Did_Change --
   ------------------------------

   overriding procedure Text_Document_Did_Change
     (Self  : access Message_Handler;
      Value : LSP.Messages.DidChangeTextDocumentParams)
   is
      Document : constant Ada_LSP.Documents.Document_Access :=
        Self.Context.Get_Document (Value.textDocument.uri);
      Note     : LSP.Messages.PublishDiagnostics_Notification;
   begin
      Document.Apply_Changes (Value.contentChanges);
      Self.Context.Update_Document (Document);
      Document.Get_Errors (Note.params.diagnostics);

      Note.method := +"textDocument/publishDiagnostics";
      Note.params.uri := Value.textDocument.uri;
      Self.Server.Send_Notification (Note);
   end Text_Document_Did_Change;

   ----------------------------
   -- Text_Document_Did_Open --
   ----------------------------

   overriding procedure Text_Document_Did_Open
     (Self  : access Message_Handler;
      Value : LSP.Messages.DidOpenTextDocumentParams)
   is
   begin
      Self.Context.Load_Document (Value.textDocument);
   end Text_Document_Did_Open;

   ----------------------------------
   -- Text_Document_Symbol_Request --
   ----------------------------------

   overriding procedure Text_Document_Symbol_Request
    (Self     : access Message_Handler;
     Value    : LSP.Messages.DocumentSymbolParams;
     Response : in out LSP.Messages.Symbol_Response)
   is
      Document : constant Ada_LSP.Documents.Document_Access :=
        Self.Context.Get_Document (Value.textDocument.uri);
   begin
      Document.Get_Symbols (Response.result);
   end Text_Document_Symbol_Request;

end Ada_LSP.Handlers;
