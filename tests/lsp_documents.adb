with Ada.Characters.Wide_Wide_Latin_1;

with League.Strings;

package body LSP_Documents is

   function "+" (Text : Wide_Wide_String)
      return League.Strings.Universal_String renames
       League.Strings.To_Universal_String;

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

   ------------
   -- Lookup --
   ------------

   not overriding function Lookup
     (Self  : Document;
      Where : LSP.Messages.Position) return Lookup_Result
   is
      use type League.Strings.Universal_String;

      type State_Kinds is (Other, Character, Identifier, Tick);
      Text      : constant LSP.Types.LSP_String := Self.Get_Line (Where.line);
      State     : State_Kinds := Other;
      Attr      : Boolean := False;
      Id_First  : Natural := 0;
      Id_Last   : Natural := 0;
      Is_Pragma : Boolean := False;
      Pragma_Id : League.Strings.Universal_String;
      Param     : Natural := 1;
   begin
      for J in 1 .. Text.Length loop
         case State is
            when Other =>
               if Text (J).To_Wide_Wide_Character = ''' then
                  State := Character;
               elsif Text (J).Is_ID_Start then
                  State := Identifier;
                  Id_First := J;
               end if;
            when Character =>
               if Text (J).To_Wide_Wide_Character = ''' then
                  State := Other;
               end if;
            when Identifier =>
               Id_Last := J;

               if Text (J).To_Wide_Wide_Character = ''' then
                  State := Tick;
                  Id_Last := J - 1;
               elsif not (Text (J).Is_ID_Start or Text (J).Is_ID_Continue) then
                  State := Other;
                  Id_Last := J - 1;

                  if Text.Slice (Id_First, Id_Last) = +"pragma" then
                     Is_Pragma := True;
                  elsif Is_Pragma then
                     Pragma_Id := Text.Slice (Id_First, Id_Last);
                     Is_Pragma := False;
                     Param := 1;
                  end if;
               end if;
            when Tick =>
               if Text (J).Is_ID_Start then
                  Attr := True;
                  State := Identifier;
                  Id_First := J;
               end if;
         end case;

         if Text (J).To_Wide_Wide_Character = ';' then
            Is_Pragma := False;
         elsif Text (J).To_Wide_Wide_Character = ',' then
            Param := Param + 1;
         end if;

         exit when State /= Identifier and J >= Natural (Where.character);

      end loop;

      if Attr then
         return (Attribute_Designator, Text.Slice (Id_First, Id_Last));
      elsif not Pragma_Id.Is_Empty then
         return (Pragma_Name, Pragma_Id, Param);
      else
         return (Kind => None);
      end if;
   end Lookup;

   -------------
   -- Version --
   -------------

   not overriding function Version
     (Self : Document) return LSP.Types.Version_Id is
   begin
      return Self.Version;
   end Version;

end LSP_Documents;
