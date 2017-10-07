ORIG=/tmp/origin.md
NEW=/tmp/new.md
sed -n '/^```typescript/,/^```$/p' ../doc/protocol.md > $ORIG
#sed -n '/^   --```typescript/,/^   --```$/p' ../src/lsp-messages.ads \
#	| sed -e 's/^   --//' > $NEW

#diff -u $ORIG $NEW

