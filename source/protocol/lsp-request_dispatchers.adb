package body LSP.Request_Dispatchers is

   --------------
   -- Dispatch --
   --------------

   not overriding function Dispatch
     (Self    : in out Request_Dispatcher;
      Method  : LSP.Types.LSP_String;
      Stream  : access Ada.Streams.Root_Stream_Type'Class;
      Handler : not null LSP.Message_Handlers.Request_Handler_Access)
        return LSP.Messages.ResponseMessage'Class
   is
      Cursor : Maps.Cursor := Self.Map.Find (Method);
   begin
      if not Maps.Has_Element (Cursor) then
         Cursor := Self.Map.Find (League.Strings.Empty_Universal_String);
      end if;

      return Maps.Element (Cursor) (Stream, Handler);
   end Dispatch;

   --------------
   -- Register --
   --------------

   not overriding procedure Register
     (Self   : in out Request_Dispatcher;
      Method : League.Strings.Universal_String;
      Value  : Parameter_Handler_Access) is
   begin
      Self.Map.Insert (Method, Value);
   end Register;

end LSP.Request_Dispatchers;
