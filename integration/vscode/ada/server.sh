#!/bin/bash
ROOT=`dirname $0`/../../..
tee /tmp/in.log | $ROOT/.obj/protocol/lsp_test | tee /tmp/out.log
