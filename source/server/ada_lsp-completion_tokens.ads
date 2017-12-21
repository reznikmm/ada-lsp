--  Copyright (c) 2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with LSP.Messages;

with Ada_LSP.Completions;
limited with Ada_LSP.Contexts;

package Ada_LSP.Completion_Tokens is

   type Completion_Handler
     (Context : not null access Ada_LSP.Contexts.Context) is
       new Ada_LSP.Completions.Handler with null record;

   overriding procedure Fill_Completion_List
     (Self    : Completion_Handler;
      Context : Ada_LSP.Completions.Context'Class;
      Result  : in out LSP.Messages.CompletionList);

end Ada_LSP.Completion_Tokens;
