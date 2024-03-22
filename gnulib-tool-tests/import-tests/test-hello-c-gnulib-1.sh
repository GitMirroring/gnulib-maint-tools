#!/bin/sh
. ../init.sh
do_import_test ../gnulib-data/examples/hello-c-gnulib . "--lib=libgnu --source-base=lib --m4-base=gnulib-m4 --tests-base=tests --with-tests --import unistd get_ppid_of"
