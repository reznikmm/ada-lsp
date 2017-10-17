with LSP.Messages;
with LSP.Types;

package Cross_References is

   type Database is tagged limited private;

   not overriding procedure Initialize
     (Self   : in out Database;
      Source : LSP.Types.LSP_String);

   not overriding procedure Get_Definition
     (Self   : Database;
      Name   : LSP.Types.LSP_String;
      Result : out LSP.Messages.Location;
      Found  : out Boolean);

   not overriding procedure Get_References
     (Self      : Database;
      Name      : LSP.Types.LSP_String;
      With_Decl : Boolean;
      Result    : in out LSP.Messages.Location_Vectors.Vector);

private

   type Database is tagged limited record
      Source : LSP.Types.LSP_String;
   end record;

end Cross_References;
