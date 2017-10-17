with Ada.Directories;

package body Cross_References is

   --------------------
   -- Get_Definition --
   --------------------

   not overriding procedure Get_Definition
     (Self   : Database;
      Name   : LSP.Types.LSP_String;
      Result : out LSP.Messages.Location;
      Found  : out Boolean)
   is
      use type LSP.Types.LSP_String;
      Base_Name : constant LSP.Types.LSP_String :=
        Name.To_Lowercase.Split ('.').Join ('-') & ".ads";
   begin
      if Ada.Directories.Exists
        ("source/protocol/" & Base_Name.To_UTF_8_String)
      then
         Found := True;
         Result.uri := Self.Source & Base_Name;
         Result.span := (first | last => (0, 0));
      else
         Found := False;
      end if;
   end Get_Definition;

   ----------------
   -- Initialize --
   ----------------

   not overriding procedure Initialize
     (Self   : in out Database;
      Source : LSP.Types.LSP_String) is
   begin
      Self.Source := Source;
   end Initialize;

end Cross_References;
