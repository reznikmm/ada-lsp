package body Checkers is

   ----------------
   -- Initialize --
   ----------------

   not overriding procedure Initialize
     (Self    : in out Checker;
      Project : LSP.Types.LSP_String) is
   begin
      Self.Project := Project;
   end Initialize;

   ---------
   -- Run --
   ---------

   not overriding procedure Run
     (Self   : in out Checker;
      File   : LSP.Types.LSP_String;
      Result : in out LSP.Messages.Diagnostic_Vectors.Vector)
   is
   begin
      null;
   end Run;

end Checkers;
