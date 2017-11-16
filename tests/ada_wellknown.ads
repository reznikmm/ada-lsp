--  Copyright (c) 2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with LSP.Messages;
with LSP.Types;

package Ada_Wellknown is

   procedure Initialize;

   function Attributes return LSP.Messages.CompletionItem_Vectors.Vector;

   function Attribute_Hover
     (Name : LSP.Types.LSP_String)
      return LSP.Messages.MarkedString_Vectors.Vector;

   function Pragma_Signatures
     (Name : LSP.Types.LSP_String)
      return LSP.Messages.SignatureInformation_Vectors.Vector;

end Ada_Wellknown;
