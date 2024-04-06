#!/bin/sh
. ../init.sh
run_test_group '
  test-hello-c-gnulib-1.sh
  test-hello-c-gnulib-automakesubdir-1.sh
  test-hello-c-gnulib-automakesubdir-withtests-1.sh
  test-hello-c-gnulib-conddeps-1.sh
  test-hello-c-gnulib-nonrecursive-1.sh
  test-wget2-1.sh
  test-oath-toolkit-1.sh
  test-oath-toolkit-2.sh
  test-oath-toolkit-3.sh
  test-oath-toolkit-4.sh
  test-oath-toolkit-5.sh
  test-coreutils-1.sh
  test-emacs-1.sh
  test-pspp-1.sh
'
