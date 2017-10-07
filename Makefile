all:
	gprbuild gnat/lsp_protocol.gpr -p

clean:
	rm -rf .obj

