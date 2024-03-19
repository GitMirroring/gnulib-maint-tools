#!/bin/sh
. ../init.sh
run_test_group '
  test-wget2-1.sh
  test-oath-toolkit-1.sh
  test-oath-toolkit-2.sh
  test-oath-toolkit-3.sh
  test-oath-toolkit-4.sh
  test-oath-toolkit-5.sh
  test-coreutils-1.sh
  test-emacs-1.sh
'
