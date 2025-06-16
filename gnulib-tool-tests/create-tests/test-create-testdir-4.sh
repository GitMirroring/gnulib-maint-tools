#!/bin/sh
. ../init.sh
do_create_test "--create-testdir --with-c++-tests --without-privileged-tests --avoid=config-h --avoid=non-recursive-gnulib-prefix-hack --avoid=timevar --avoid=mountlist --avoid=lib-ignore"
