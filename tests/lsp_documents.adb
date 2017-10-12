with Ada.Characters.Wide_Wide_Latin_1;

package body LSP_Documents is

   --------------
   -- Get_Line --
   --------------

   not overriding function Get_Line
     (Self : Document;
      Line : LSP.Types.Line_Number) return LSP.Types.LSP_String is
   begin
      return Self.Lines.Element (Natural (Line) + 1);
   end Get_Line;

   ---------------
   -- Initalize --
   ---------------

   procedure Initalize
     (Self : out Document;
      Text : LSP.Types.LSP_String) is
   begin
      Self.Lines := Text.Split (Ada.Characters.Wide_Wide_Latin_1.LF);
   end Initalize;

end LSP_Documents;
