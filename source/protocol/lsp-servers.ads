with Ada.Streams;

with LSP.Messages;
with LSP.Message_Handlers;

private with LSP.Notification_Dispatchers;
private with LSP.Request_Dispatchers;

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
   end record;

end LSP.Servers;
