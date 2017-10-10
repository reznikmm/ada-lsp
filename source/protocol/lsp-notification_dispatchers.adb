package body LSP.Notification_Dispatchers is

   --------------
   -- Dispatch --
   --------------

   not overriding procedure Dispatch
     (Self    : in out Notification_Dispatcher;
      Method  : LSP.Types.LSP_String;
      Stream  : access Ada.Streams.Root_Stream_Type'Class;
      Handler : not null LSP.Request_Handlers.Notification_Handler_Access)
   is
      Cursor : Maps.Cursor := Self.Map.Find (Method);
   begin
      if not Maps.Has_Element (Cursor) then
         Cursor := Self.Map.Find (League.Strings.Empty_Universal_String);
      end if;

      Maps.Element (Cursor) (Stream, Handler);
   end Dispatch;

   --------------
   -- Register --
   --------------

   not overriding procedure Register
     (Self   : in out Notification_Dispatcher;
      Method : League.Strings.Universal_String;
      Value  : Parameter_Handler_Access) is
   begin
      Self.Map.Insert (Method, Value);
   end Register;

end LSP.Notification_Dispatchers;
