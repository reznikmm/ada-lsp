ada-lsp
=======

[![Build Status](https://travis-ci.org/reznikmm/ada-lsp.svg?branch=master)](https://travis-ci.org/reznikmm/ada-lsp)
[![reuse compliant](https://img.shields.io/badge/reuse-compliant-green.svg)](https://reuse.software/)

> Language Server Protocol for Ada

The goal of this project is to provide implementation of Language Server
Protocol ([LSP](https://github.com/Microsoft/language-server-protocol))
for Ada.

> The Language Server protocol is used between a tool (the client) and
> a language smartness provider (the server) to integrate features like
> auto complete, goto definition, find all references and alike into
> the tool.

## Install

Run:
```
git clone https://github.com/reznikmm/ada-lsp.git
cd ada-lsp
make
```

### Dependencies

The dependency is
* [Matreshka](https://github.com/reznikmm/matreshka) - latest trunk,
  (at least 2017-10-13). AMF isn't requred/used.
  See [Installation guide](http://forge.ada-ru.org/matreshka/wiki/Guide)

* [increment](https://github.com/reznikmm/increment)
  an incremental analysis library.
* [Ada Pretty Printer](https://github.com/reznikmm/ada-pretty) library.
* [Anagram](https://github.com/reznikmm/anagram) - parser generation Ada
  library .

* [Node.js](https://nodejs.org) - to prepare VS Code extension
* [VS Code](https://code.visualstudio.com) - to test the protocol binding

### Status of the project

Ada *binding* of the protocol is (mostly) implemented, but only from server's
point of view.
There is a 'demo' to check how *the binding* works.
The Ada Language Server **isn't implemented yet**.

## Usage
### Running a Demo

The demo let you see common usage of LSP for Ada and explore protocol messages.

Prepare Ada extension and run VS code:
```
make vscode
code --extensionDevelopmentPath=`pwd`/integration/vscode/ada/ `pwd`
```

* Open source/protocol/lsp.ads
* Open Output Console `Ctrl-J` and look for 'Ada Language Server' logs.
* Print `X'` play with completion, press `Ctrl+Space` to see/hide the
documentation.
Select `S'Adjacent` to paste a snippet.
* Move the mouse over `Adjacent`, tooltip will appear with Markdown inside.
* Undo your changes and remove semicolon and save file.
The editor will be populated with diagnostics.
A bulb on the left side represent a CodeAction to correct the error.
Click on it and fix the error.
* Print `pragma Assert (` - signature help appears. Print `X, "Ops"` and see
how parameter description changes after comma.
* Open context menu on `LSP` identifier and click `Find all references`.
Two references will be displayed.
* Open lst-types.ads. Open context menu on `Generic_Optional` on the line
```ada
with LSP.Generic_Optional;
```
* Press `Go to definition`. Corresponding file will be opened.
* Press `Ctrl+Shft+O` and see list of local symbols.
* Press `Ctrl+T` and see list of global symbols.

## Maintainer

[@MaximReznik](https://github.com/reznikmm).

## Contribute

Feel free to dive in!
[Open an issue](https://github.com/reznikmm/ada-lsp/issues/new) or submit PRs.

## License

[MIT](LICENSE) © Maxim Reznik
