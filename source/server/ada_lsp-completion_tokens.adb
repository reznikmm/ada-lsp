--  Copyright (c) 2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with Ada.Containers.Doubly_Linked_Lists;

with League.Strings;

with Incr.Nodes.Tokens;
with Incr.Parsers.Incremental;
with Incr.Version_Trees;

with Ada_LSP.Ada_Parser_Data;
with Ada_LSP.Contexts;
with Ada_LSP.Documents;

package body Ada_LSP.Completion_Tokens is

   function "+" (Text : Wide_Wide_String)
      return League.Strings.Universal_String renames
       League.Strings.To_Universal_String;

   package Node_Lists is new Ada.Containers.Doubly_Linked_Lists
     (Incr.Nodes.Node_Access, Incr.Nodes."=");

   --------------------------
   -- Fill_Completion_List --
   --------------------------

   overriding procedure Fill_Completion_List
     (Self    : Completion_Handler;
      Context : Ada_LSP.Completions.Context'Class;
      Result  : in out LSP.Messages.CompletionList)
   is
      use Incr.Parsers.Incremental.Parser_Data_Providers;
--      use type Incr.Nodes.Node_Access;

      Provider  : constant Ada_LSP.Ada_Parser_Data.Provider_Access :=
        Self.Context.Get_Parser_Data_Provider;
      Next_Action : constant Action_Table_Access := Provider.Actions;
      Next_State  : constant State_Table_Access := Provider.States;
      State   : Parser_State := 1;
      Token   : constant Incr.Nodes.Tokens.Token_Access := Context.Token;
      Doc     : constant Ada_LSP.Documents.Constant_Document_Access :=
        Context.Document;
      Start   : constant Incr.Nodes.Node_Access :=
        Incr.Nodes.Node_Access (Doc.Start_Of_Stream);
      Now     : constant Incr.Version_Trees.Version := Doc.History.Changing;
      List    : Node_Lists.List;
      Subtree : Incr.Nodes.Node_Access := Token.Previous_Subtree (Now);
   begin
      while Subtree not in Start | null loop
         List.Prepend (Subtree);
         Subtree := Subtree.Previous_Subtree (Now);
      end loop;

      for Node of List loop
         State := Next_State (State, Node.Kind);
      end loop;

      for J in Incr.Nodes.Node_Kind'(1) .. 108 loop
         if Next_Action (State, J).Kind /= Error then
            declare
               Item : LSP.Messages.CompletionItem;
            begin
               Item.label := +Provider.Kind_Image (J);
               Item.kind := (True, LSP.Messages.Keyword);
               Result.items.Append (Item);
            end;
         end if;
      end loop;
   end Fill_Completion_List;

end Ada_LSP.Completion_Tokens;
