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
     (Self    : out Document;
      Text    : LSP.Types.LSP_String;
      Version : LSP.Types.Version_Id) is
   begin
      Self.Lines := Text.Split (Ada.Characters.Wide_Wide_Latin_1.LF);
      Self.Version := Version;
   end Initalize;

   -------------
   -- Version --
   -------------

   not overriding function Version
     (Self : Document) return LSP.Types.Version_Id is
   begin
      return Self.Version;
   end Version;

end LSP_Documents;
