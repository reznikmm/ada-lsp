with Ada.Streams;

with LSP.Messages;
with LSP.Request_Handlers;

private with LSP.Request_Dispatchers;

package LSP.Servers is
   pragma Preelaborate;

   type Server is tagged limited private;

   not overriding procedure Initialize
     (Self    : in out Server;
      Stream  : access Ada.Streams.Root_Stream_Type'Class;
      Handler : not null LSP.Request_Handlers.Request_Handler_Access);

   not overriding procedure Send_Notification
     (Self  : in out Server;
      Value : LSP.Messages.NotificationMessage);

   not overriding procedure Run (Self  : in out Server);

private

   type Server is tagged limited record
      Initilized : Boolean;
      --  Mark Server as uninitialized until get 'initalize' request
      Stream     : access Ada.Streams.Root_Stream_Type'Class;
      Dispatcher : aliased LSP.Request_Dispatchers.Request_Dispatcher;
      Handler    : LSP.Request_Handlers.Request_Handler_Access;
   end record;

end LSP.Servers;
