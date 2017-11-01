all: source/generated/ada_lsp-ada_lexers-tables.adb \
     source/generated/ada_lsp-ada_parser_data.adb
	gprbuild -P gnat/lsp_protocol.gpr -p
	gprbuild -P gnat/ada_lsp.gpr -p

clean:
	rm -rf .obj

vscode:
	cd integration/vscode/ada; npm install
	@echo Now run:
	@echo code --extensionDevelopmentPath=`pwd`/integration/vscode/ada/ `pwd`

source/generated/ada_lsp-ada_lexers-tables.adb: source/server/ada.uaflex
	cd source/generated;\
	uaflex --types Types --scanner Ada_LSP.Ada_Lexers \
	 --handler Handlers --tokens Nodes.Tokens ../server/ada.uaflex; \
	rm types.ads handlers.ads ada_lsp-ada_lexers-on_accept.adb

source/generated/ada_lsp-ada_parser_data.adb: source/server/ada-lalr.ag \
                                              | .obj/gen-driver 
	.obj/gen-driver $< > $@

.obj/gen-driver:
	gprbuild -P gnat/generator.gpr -p
