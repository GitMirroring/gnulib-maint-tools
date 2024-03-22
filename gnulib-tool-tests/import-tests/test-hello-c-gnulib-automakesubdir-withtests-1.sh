#!/bin/sh
. ../init.sh
do_import_test ../gnulib-data/examples/hello-c-gnulib-automakesubdir-withtests . "--lib=libgnu --source-base=lib --m4-base=gnulib-m4 --tests-base=tests --with-tests --makefile-name=gnulib.mk --tests-makefile-name=Makefile.am --automake-subdir --import unistd get_ppid_of"
