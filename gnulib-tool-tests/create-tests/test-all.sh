#!/bin/sh
. ../init.sh
run_test_group '
  test-create-testdir-1.sh
  test-create-testdir-2.sh
  test-create-testdir-3.sh
  test-create-testdir-4.sh
  test-create-megatestdir-1.sh
  test-create-megatestdir-2.sh
'
