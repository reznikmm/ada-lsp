--  Copyright (c) 2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with League.Strings;

package body Ada_LSP.Handlers is

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
   begin
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

end Ada_LSP.Handlers;
