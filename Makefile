all:
	gprbuild gnat/lsp_protocol.gpr -p

clean:
	rm -rf .obj

vscode:
	cd integration/vscode/ada; npm install
	@echo Now run:
	@echo code --extensionDevelopmentPath=`pwd`/integration/vscode/ada/ `pwd`
