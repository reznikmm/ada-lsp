with Ada.Characters.Wide_Wide_Latin_1;

package body LSP_Documents is

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
