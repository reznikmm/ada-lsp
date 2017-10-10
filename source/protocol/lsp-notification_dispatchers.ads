private with Ada.Containers.Hashed_Maps;
with Ada.Streams;

with League.Strings;
private with League.Strings.Hash;

with LSP.Request_Handlers;
with LSP.Types;

package LSP.Notification_Dispatchers is
   pragma Preelaborate;

   type Notification_Dispatcher is tagged limited private;

   type Parameter_Handler_Access is access procedure
    (Stream  : access Ada.Streams.Root_Stream_Type'Class;
     Handler : not null LSP.Request_Handlers.Notification_Handler_Access);

   not overriding procedure Register
    (Self   : in out Notification_Dispatcher;
     Method : League.Strings.Universal_String;
     Value  : Parameter_Handler_Access);

   not overriding procedure Dispatch
     (Self    : in out Notification_Dispatcher;
      Method  : LSP.Types.LSP_String;
      Stream  : access Ada.Streams.Root_Stream_Type'Class;
      Handler : not null LSP.Request_Handlers.Notification_Handler_Access);

private

   package Maps is new Ada.Containers.Hashed_Maps
     (Key_Type        => League.Strings.Universal_String,
      Element_Type    => Parameter_Handler_Access,
      Hash            => League.Strings.Hash,
      Equivalent_Keys => League.Strings."=",
      "="             => "=");

   type Notification_Dispatcher is tagged limited record
      Map   : Maps.Map;
      Value : LSP.Request_Handlers.Notification_Handler_Access;
   end record;

end LSP.Notification_Dispatchers;
