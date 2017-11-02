--  Copyright (c) 2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with LSP.Message_Handlers;
with LSP.Messages;
with LSP.Servers;

with Ada_LSP.Contexts;

package Ada_LSP.Handlers is

   type Message_Handler
     (Server  : access LSP.Servers.Server;
      Context : access Ada_LSP.Contexts.Context) is
   limited new LSP.Message_Handlers.Request_Handler
     and LSP.Message_Handlers.Notification_Handler with private;

private

   type Message_Handler
     (Server : access LSP.Servers.Server;
      Context : access Ada_LSP.Contexts.Context)
   is limited new LSP.Message_Handlers.Request_Handler
     and LSP.Message_Handlers.Notification_Handler with record
      null;
   end record;

   overriding procedure Exit_Notification
    (Self : access Message_Handler);

   overriding procedure Initialize_Request
    (Self     : access Message_Handler;
     Value    : LSP.Messages.InitializeParams;
     Response : in out LSP.Messages.Initialize_Response);

   overriding procedure Text_Document_Did_Open
     (Self  : access Message_Handler;
      Value : LSP.Messages.DidOpenTextDocumentParams);

end Ada_LSP.Handlers;
