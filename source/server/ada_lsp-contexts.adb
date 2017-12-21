--  Copyright (c) 2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with Incr.Version_Trees;
with Ada_LSP.Completion_Tokens;

package body Ada_LSP.Contexts is

   type Version_Tree_Access is access all Incr.Version_Trees.Version_Tree;

   ----------------------------
   -- Add_Completion_Handler --
   ----------------------------

   not overriding procedure Add_Completion_Handler
     (Self  : in out Context;
      Value : not null Ada_LSP.Completions.Handler_Access) is
   begin
      Self.Completions.Append (Value);
   end Add_Completion_Handler;

   ----------------------
   -- Fill_Completions --
   ----------------------

   not overriding procedure Fill_Completions
     (Self    : Context;
      Context : Ada_LSP.Completions.Context'Class;
      Result  : in out LSP.Messages.CompletionList) is
   begin
      for J of Self.Completions loop
         J.Fill_Completion_List (Context, Result);
      end loop;
   end Fill_Completions;

   ------------------
   -- Get_Document --
   ------------------

   not overriding function Get_Document
     (Self : Context;
      URI  : LSP.Messages.DocumentUri)
        return Ada_LSP.Documents.Document_Access is
   begin
      return Self.Documents (URI);
   end Get_Document;

   ------------------------------
   -- Get_Parser_Data_Provider --
   ------------------------------

   not overriding function Get_Parser_Data_Provider
     (Self : Context) return Ada_LSP.Ada_Parser_Data.Provider_Access is
   begin
      return Self.Provider'Unchecked_Access;
   end Get_Parser_Data_Provider;

   ----------------
   -- Initialize --
   ----------------

   not overriding procedure Initialize
     (Self : in out Context;
      Root : League.Strings.Universal_String)
   is
      function Starts_With (Left, Right : Wide_Wide_String) return Boolean;

      -----------------
      -- Starts_With --
      -----------------

      function Starts_With (Left, Right : Wide_Wide_String) return Boolean is
      begin
         return Left'Length >= Right'Length and then
           Left (Left'First .. Left'First + Right'Length - 1) = Right;
      end Starts_With;
   begin
      for J in Self.Provider.Is_Defining_Name'Range loop
         Self.Provider.Is_Defining_Name (J) :=
           Starts_With (Self.Provider.Kind_Image (J), "defining");
      end loop;

      Self.Root := Root;
      Self.Incr_Lexer.Set_Batch_Lexer (Self.Batch_Lexer'Unchecked_Access);
      Self.Add_Completion_Handler
        (new Ada_LSP.Completion_Tokens.Completion_Handler
               (Self'Unchecked_Access));
   end Initialize;

   ----------------------
   -- Is_Defining_Name --
   ----------------------

   overriding function Is_Defining_Name
     (Self : Provider;
      Kind : Incr.Nodes.Node_Kind) return Boolean is
   begin
      return Kind in Self.Is_Defining_Name'Range
        and then Self.Is_Defining_Name (Kind);
   end Is_Defining_Name;

   -------------------
   -- Load_Document --
   -------------------

   not overriding procedure Load_Document
     (Self  : in out Context;
      Item  : LSP.Messages.TextDocumentItem)
   is
      History : constant Version_Tree_Access :=
        new Incr.Version_Trees.Version_Tree;
      Object : constant Ada_LSP.Documents.Document_Access :=
        new Ada_LSP.Documents.Document (History);
   begin
      Object.Initialize (Item);
      Object.Update
        (Self.Incr_Parser,
         Self.Incr_Lexer'Unchecked_Access,
         Self.Provider'Unchecked_Access);
      Self.Documents.Insert (Item.uri, Object);
   end Load_Document;

   ---------------------
   -- Update_Document --
   ---------------------

   not overriding procedure Update_Document
     (Self : in out Context;
      Item : not null Ada_LSP.Documents.Document_Access) is
   begin
      Item.Update
        (Self.Incr_Parser,
         Self.Incr_Lexer'Unchecked_Access,
         Self.Provider'Unchecked_Access);
   end Update_Document;

end Ada_LSP.Contexts;
