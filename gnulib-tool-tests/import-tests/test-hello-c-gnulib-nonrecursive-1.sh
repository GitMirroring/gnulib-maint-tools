#!/bin/sh
. ../init.sh
do_import_test ../gnulib-data/examples/hello-c-gnulib-nonrecursive . "--lib=libgnu --source-base=lib --m4-base=gnulib-m4 --makefile-name=gnulib.mk --import alloca unistd get_ppid_of non-recursive-gnulib-prefix-hack"
