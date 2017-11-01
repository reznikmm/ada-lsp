--  Copyright (c) 2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with LSP.Servers;
with LSP.Stdio_Streams;

with Ada_LSP.Contexts;
with Ada_LSP.Handlers;

procedure Ada_LSP.Driver is

   Server  : aliased LSP.Servers.Server;
   Stream  : aliased LSP.Stdio_Streams.Stdio_Stream;
   Context : aliased Ada_LSP.Contexts.Context;
   Handler : aliased Ada_LSP.Handlers.Message_Handler
     (Server'Access, Context'Access);
begin
   Server.Initialize
     (Stream'Unchecked_Access,
      Handler'Unchecked_Access,
      Handler'Unchecked_Access);
   Server.Run;
end Ada_LSP.Driver;
