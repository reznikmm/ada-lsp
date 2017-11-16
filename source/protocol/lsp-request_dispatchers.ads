--  Copyright (c) 2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with Ada.Containers.Hashed_Maps;
with Ada.Streams;

with League.Strings;
private with League.Strings.Hash;

with LSP.Messages;
with LSP.Message_Handlers;
with LSP.Types;

package LSP.Request_Dispatchers is
   pragma Preelaborate;

   type Request_Dispatcher is tagged limited private;

   type Parameter_Handler_Access is access function
    (Stream     : access Ada.Streams.Root_Stream_Type'Class;
     Handler    : not null LSP.Message_Handlers.Request_Handler_Access)
       return LSP.Messages.ResponseMessage'Class;

   not overriding procedure Register
    (Self   : in out Request_Dispatcher;
     Method : League.Strings.Universal_String;
     Value  : Parameter_Handler_Access);

   not overriding function Dispatch
     (Self    : in out Request_Dispatcher;
      Method  : LSP.Types.LSP_String;
      Stream  : access Ada.Streams.Root_Stream_Type'Class;
      Handler : not null LSP.Message_Handlers.Request_Handler_Access)
      return LSP.Messages.ResponseMessage'Class;

private

   package Maps is new Ada.Containers.Hashed_Maps
     (Key_Type        => League.Strings.Universal_String,
      Element_Type    => Parameter_Handler_Access,
      Hash            => League.Strings.Hash,
      Equivalent_Keys => League.Strings."=",
      "="             => "=");

   type Request_Dispatcher is tagged limited record
      Map   : Maps.Map;
      Value : LSP.Message_Handlers.Request_Handler_Access;
   end record;

end LSP.Request_Dispatchers;
