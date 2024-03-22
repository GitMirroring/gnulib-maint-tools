#!/bin/sh
. ../init.sh
do_import_test ../gnulib-data/examples/hello-c-gnulib-automakesubdir . "--lib=libgnu --source-base=lib --m4-base=gnulib-m4 --makefile-name=gnulib.mk --automake-subdir --import alloca unistd get_ppid_of"
