with Ada.Directories;

with League.Strings;

package body Cross_References is

   function "+" (Text : Wide_Wide_String)
      return League.Strings.Universal_String renames
       League.Strings.To_Universal_String;

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

   --------------------
   -- Get_References --
   --------------------

   not overriding procedure Get_References
     (Self      : Database;
      Name      : LSP.Types.LSP_String;
      With_Decl : Boolean;
      Result    : in out LSP.Messages.Location_Vectors.Vector)
   is
      pragma Unreferenced (With_Decl);
      use type League.Strings.Universal_String;
      Item : LSP.Messages.Location;
   begin
      if Name = +"LSP" then
         Item.uri := Self.Source & "/lsp.ads";
         Item.span := ((0, 8), (0, 11));
         Result.Append (Item);
         Item.span := ((2, 4), (2, 7));
         Result.Append (Item);
      end if;
   end Get_References;

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
