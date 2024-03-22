# Initialization for gnulib-tool tests.

# Copyright (C) 2024 Free Software Foundation, Inc.
#
# This file is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License,
# or (at your option) any later version.
#
# This file is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Using this file in a test
# =========================
#
# The typical skeleton of a test looks like this:
#
#   #!/bin/sh
#   . ./init.sh
#   Execute some commands.
#   Set the exit code 0 for success, or 1 or other for failure.
#   Exit $?

# =============================================================================

# run_test_group 'TESTS'
# runs a group of explicitly named test, all in the current directory.
run_test_group ()
{
  fail=0
  for f in $1; do
    ./$f
    case $? in
      0)  echo "PASS: $f" ;;
      77) echo "SKIP: $f" ;;
      *)  echo "FAIL: $f"; fail=1 ;;
    esac
  done
  exit $fail
}

do_info_test ()
{
  tmp=tmp$$
  $GNULIB_SRCDIR/gnulib-tool --gnulib-dir=../gnulib-data `cat ${0%.sh}.args` >$tmp-out 2>$tmp-err
  rc=$?
  if test $rc != 0; then
    cat $tmp-err >&2
    echo "FAIL: gnulib-tool exited with code $rc." >&2
    exit 1
  fi
  if test -s $tmp-err; then
    cat $tmp-err >&2
    echo "FAIL: gnulib-tool succeeded but printed warnings." >&2
    exit 1
  fi
  expected_output=${0%.sh}.output
  if cmp $expected_output $tmp-out; then
    :
  else
    LC_ALL=C diff -u $expected_output $tmp-out
    echo "FAIL: gnulib-tool's output has unexpected differences." >&2
    exit 1
  fi
  rm -f $tmp-out $tmp-err
  exit 0
}

do_create_test ()
{
  tmp=tmp$$
  $GNULIB_SRCDIR/gnulib-tool --gnulib-dir=../gnulib-data --dir=$tmp-result `cat ${0%.sh}.args` >$tmp-out 2>$tmp-err
  rc=$?
  # Remove .deps dirs, since we cannot check them in as part of the expected result.
  deps_dir=`find $tmp-result -name .deps -type d -print`
  if test -n "$deps_dir"; then
    rmdir $deps_dir
  fi
  if test $rc != 0; then
    cat $tmp-err >&2
    echo "FAIL: gnulib-tool exited with code $rc." >&2
    exit 1
  fi
  expected_result=${0%.sh}.result
  # Exclude files whose contents depends on the GNU Autoconf version, GNU Automake version, or file time stamps.
  if LC_ALL=C diff -r -q --exclude=aclocal.m4 --exclude=configure --exclude=config.h.in --exclude=Makefile.in --exclude=compile --exclude=depcomp --exclude=missing --exclude=test-driver --exclude=do-autobuild $expected_result $tmp-result; then
    :
  else
    echo "FAIL: gnulib-tool's result has unexpected differences." >&2
    exit 1
  fi
  expected_err=${0%.sh}.err
  if cmp $expected_err $tmp-err; then
    :
  else
    LC_ALL=C diff -u $expected_err $tmp-err
    echo "FAIL: gnulib-tool's error output has unexpected differences." >&2
    exit 1
  fi
  expected_out=${0%.sh}.out
  if cmp $expected_out $tmp-out; then
    :
  else
    LC_ALL=C diff -u $expected_out $tmp-out
    echo "FAIL: gnulib-tool's output has unexpected differences." >&2
    exit 1
  fi
  rm -rf $tmp-result $tmp-out $tmp-err
  exit 0
}

# do_import_test SRCDIR CONFIGUREDIR GNULIB_TOOL_ARGS
# runs a test that adds files to a given package.
# SRCDIR             source directory (only the configure.ac, *.m4, Makefile.am,
#                    *.mk, .gitignore files matter)
# CONFIGUREDIR       relative subdirectory of SRCDIR that contains configure.ac
# GNULIB_TOOL_ARGS   arguments to pass to gnulib-tool
do_import_test ()
{
  tmp=tmp$$
  gnulib_dir=`cd ../gnulib-data && pwd`
  mkdir $tmp-result
  (cd "$1" && tar cf - .) | (cd $tmp-result && tar xf -)
  (cd $tmp-result/"$2" && $GNULIB_SRCDIR/gnulib-tool --gnulib-dir="$gnulib_dir" $3) >$tmp-out 2>$tmp-err
  rc=$?
  # Remove empty build-aux dirs, since we cannot check them in as part of the expected result.
  build_aux_dir=`find $tmp-result -name build-aux -type d -empty -print`
  if test -n "$build_aux_dir"; then
    rmdir $build_aux_dir
  fi
  # Remove autom4te.cache directory, since it may depend on the Autoconf version or M4 version.
  rm -rf $tmp-result/"$2"/autom4te.cache
  if test $rc != 0; then
    cat $tmp-err >&2
    echo "FAIL: gnulib-tool exited with code $rc." >&2
    exit 1
  fi
  expected_result=${0%.sh}.result
  if LC_ALL=C diff -r -q $expected_result $tmp-result; then
    :
  else
    echo "FAIL: gnulib-tool's result has unexpected differences." >&2
    exit 1
  fi
  expected_err=${0%.sh}.err
  if cmp $expected_err $tmp-err; then
    :
  else
    LC_ALL=C diff -u $expected_err $tmp-err
    echo "FAIL: gnulib-tool's error output has unexpected differences." >&2
    exit 1
  fi
  expected_out=${0%.sh}.out
  if cmp $expected_out $tmp-out; then
    :
  else
    LC_ALL=C diff -u $expected_out $tmp-out
    echo "FAIL: gnulib-tool's output has unexpected differences." >&2
    exit 1
  fi
  rm -rf $tmp-result $tmp-out $tmp-err
  exit 0
}
