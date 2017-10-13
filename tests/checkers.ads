with LSP.Types;
with LSP.Messages;

package Checkers is

   type Checker is tagged private;

   not overriding procedure Initialize
     (Self    : in out Checker;
      Project : LSP.Types.LSP_String);

   not overriding procedure Run
     (Self   : in out Checker;
      File   : LSP.Types.LSP_String;
      Result : in out LSP.Messages.Diagnostic_Vectors.Vector);

private

   type Checker is tagged record
      Project : LSP.Types.LSP_String;
   end record;

end Checkers;
