--  Copyright (c) 2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with Incr.Documents;
with Incr.Nodes;
with Incr.Parsers.Incremental;

package Ada_LSP.Ada_Parser_Data is

   package P renames Incr.Parsers.Incremental.Parser_Data_Providers;

   type Provider is abstract new P.Parser_Data_Provider with null record;

   overriding function Actions
     (Self : Provider) return P.Action_Table_Access;

   overriding function Part_Counts
     (Self : Provider) return P.Parts_Count_Table_Access;

   overriding function States
     (Self : Provider) return P.State_Table_Access;

   overriding function Kind_Image
     (Self : Provider;
      Kind : Incr.Nodes.Node_Kind) return Wide_Wide_String;

   not overriding function Is_Defining_Name
     (Self : Provider;
      Kind : Incr.Nodes.Node_Kind) return Boolean is abstract;

   type Node_Factory (Document : Incr.Documents.Document_Access) is
     new P.Node_Factory with null record;

   overriding procedure Create_Node
     (Self     : aliased in out Node_Factory;
      Prod     : P.Production_Index;
      Children : Incr.Nodes.Node_Array;
      Node     : out Incr.Nodes.Node_Access;
      Kind     : out Incr.Nodes.Node_Kind);

private

   type Node_Kind_Array is array (P.Production_Index range <>) of
     Incr.Nodes.Node_Kind;

end Ada_LSP.Ada_Parser_Data;
