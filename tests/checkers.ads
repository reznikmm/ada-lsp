--  Copyright (c) 2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

private with GNAT.OS_Lib;

private with League.Regexps;

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
      Result : in out LSP.Messages.Diagnostic_Vector);

private

   type Checker is tagged record
      Project : LSP.Types.LSP_String;
      Pattern : League.Regexps.Regexp_Pattern;
      Compiler : GNAT.OS_Lib.String_Access;
   end record;

end Checkers;
