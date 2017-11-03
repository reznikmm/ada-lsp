--  Copyright (c) 2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with Incr.Version_Trees;

package body Ada_LSP.Contexts is

   type Version_Tree_Access is access all Incr.Version_Trees.Version_Tree;

   ------------------
   -- Get_Document --
   ------------------

   not overriding function Get_Document
     (Self : Context;
      URI  : LSP.Messages.DocumentUri) return Document_Access is
   begin
      return Self.Documents (URI);
   end Get_Document;

   ----------------
   -- Initialize --
   ----------------

   not overriding procedure Initialize
     (Self : in out Context;
      Root : League.Strings.Universal_String) is
   begin
      Self.Root := Root;
      Self.Incr_Lexer.Set_Batch_Lexer (Self.Batch_Lexer'Unchecked_Access);
   end Initialize;

   -------------------
   -- Load_Document --
   -------------------

   not overriding procedure Load_Document
     (Self  : in out Context;
      Item  : LSP.Messages.TextDocumentItem)
   is
      History : constant Version_Tree_Access :=
        new Incr.Version_Trees.Version_Tree;
      Object : constant Document_Access :=
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
      Item : not null Document_Access) is
   begin
      Item.Update
        (Self.Incr_Parser,
         Self.Incr_Lexer'Unchecked_Access,
         Self.Provider'Unchecked_Access);
   end Update_Document;

end Ada_LSP.Contexts;
