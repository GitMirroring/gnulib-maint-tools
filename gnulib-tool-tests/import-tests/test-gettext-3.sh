#!/bin/sh
. ../init.sh
do_import_test gettext-20240101 . "`echo '
  --dir=gettext-runtime/libasprintf
  --source-base=gnulib-lib
  --m4-base=gnulib-m4
  --lgpl=2
  --libtool
  --local-dir=gnulib-local
  --import
  alloca
  manywarnings
  vasnprintf
'`"
