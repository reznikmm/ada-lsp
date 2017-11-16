--  Copyright (c) 2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with Ada.Streams;

with LSP.Messages;
with LSP.Message_Handlers;
with LSP.Types;

private with LSP.Notification_Dispatchers;
private with LSP.Request_Dispatchers;

private with League.Stream_Element_Vectors;

package LSP.Servers is
   pragma Preelaborate;

   type Server is tagged limited private;

   not overriding procedure Initialize
     (Self         : in out Server;
      Stream       : access Ada.Streams.Root_Stream_Type'Class;
      Request      : not null LSP.Message_Handlers.Request_Handler_Access;
      Notification : not null LSP.Message_Handlers.
        Notification_Handler_Access);

   not overriding procedure Send_Notification
     (Self  : in out Server;
      Value : in out LSP.Messages.NotificationMessage'Class);

   not overriding procedure Run (Self  : in out Server);

   not overriding procedure Stop (Self  : in out Server);
   --  Ask server to stop after processing current message

   not overriding procedure Workspace_Apply_Edit
     (Self     : in out Server;
      Params   : LSP.Messages.ApplyWorkspaceEditParams;
      Applied  : out Boolean;
      Error    : out LSP.Messages.Optional_ResponseError);

private

   type Server is tagged limited record
      Initilized : Boolean;
      Stop       : Boolean := False;
      --  Mark Server as uninitialized until get 'initalize' request
      Stream        : access Ada.Streams.Root_Stream_Type'Class;
      Req_Handler   : LSP.Message_Handlers.Request_Handler_Access;
      Notif_Handler : LSP.Message_Handlers.Notification_Handler_Access;
      Requests      : aliased LSP.Request_Dispatchers.Request_Dispatcher;
      Notifications : aliased LSP.Notification_Dispatchers
        .Notification_Dispatcher;
      Last_Request  : LSP.Types.LSP_Number := 1;
      Vector        : League.Stream_Element_Vectors.Stream_Element_Vector;
   end record;

end LSP.Servers;
