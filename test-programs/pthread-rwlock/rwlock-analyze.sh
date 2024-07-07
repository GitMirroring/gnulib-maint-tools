#!/bin/sh
# Usage: rwlock-analyze.sh rwlock-PLATFORM-output

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

file="$1"

# Notes:

# n=1 all are trivial:
# R1 => R1
# W1 => W1

# n=2 all are trivial:
# R1 R2 => R1 R2
# R1 W2 => R1 W2
# W1 R2 => W1 R2
# W1 W2 => W1 W2

# These are mandatory behaviour of rwlocks:
# R1 R2 ... R(i-1) ... => R1 R2 ... R(i-1) ...
# because the R2 ... R(i-1) succeed while R1 is still being held.

unexpected=`grep '^R1 .*=> ' $file | grep -v '^R1 .*=> R1'; \
            grep '^R1 R2 .*=> ' $file | grep -v '^R1 R2 .*=> R1 R2'; \
            grep '^R1 R2 R3 .*=> ' $file | grep -v '^R1 R2 R3 .*=> R1 R2 R3'; \
            grep '^R1 R2 R3 R4 .*=> ' $file | grep -v '^R1 R2 R3 R4 .*=> R1 R2 R3 R4'; \
            grep '^R1 R2 R3 R4 R5 .*=> ' $file | grep -v '^R1 R2 R3 R4 R5 .*=> R1 R2 R3 R4 R5'`
if test -n "$unexpected"; then
  echo "!! UNEXPECTED !!"
  echo "$unexpected"
fi

deterministic=true

echo "  When releasing the last reader lock:"

# These are the lines that matter:
# R1 W2 R3 => R1 ...
# R1 W2 W3 => R1 ...
# R1 W2 R3 R4 => R1 ...
# R1 W2 R3 W4 => R1 ...
# R1 W2 W3 R4 => R1 ...
# R1 W2 W3 W4 => R1 ...
# R1 W2 R3 R4 R5 => R1 ...
# R1 W2 R3 R4 W5 => R1 ...
# R1 W2 R3 W4 R5 => R1 ...
# R1 W2 R3 W4 W5 => R1 ...
# R1 W2 W3 R4 R5 => R1 ...
# R1 W2 W3 R4 W5 => R1 ...
# R1 W2 W3 W4 R5 => R1 ...
# R1 W2 W3 W4 W5 => R1 ...

prefers_readers_1=false
prefers_writers_1=false
if    grep '^R1 W2 R3 => R1 W2' $file >/dev/null \
   && grep '^R1 W2 W3 => R1 W2' $file >/dev/null \
   && grep '^R1 W2 R3 R4 => R1 W2' $file >/dev/null \
   && grep '^R1 W2 R3 W4 => R1 W2' $file >/dev/null \
   && grep '^R1 W2 W3 R4 => R1 W2' $file >/dev/null \
   && grep '^R1 W2 W3 W4 => R1 W2' $file >/dev/null \
   && grep '^R1 W2 R3 R4 R5 => R1 W2' $file >/dev/null \
   && grep '^R1 W2 R3 R4 W5 => R1 W2' $file >/dev/null \
   && grep '^R1 W2 R3 W4 R5 => R1 W2' $file >/dev/null \
   && grep '^R1 W2 R3 W4 W5 => R1 W2' $file >/dev/null \
   && grep '^R1 W2 W3 R4 R5 => R1 W2' $file >/dev/null \
   && grep '^R1 W2 W3 R4 W5 => R1 W2' $file >/dev/null \
   && grep '^R1 W2 W3 W4 R5 => R1 W2' $file >/dev/null \
   && grep '^R1 W2 W3 W4 W5 => R1 W2' $file >/dev/null \
; then
  echo "    The first of the enqueued lock attempts is granted."
else
  if    grep '^R1 W2 R3 => R1 R' $file >/dev/null \
     && grep '^R1 W2 R3 R4 => R1 R' $file >/dev/null \
     && grep '^R1 W2 R3 W4 => R1 R' $file >/dev/null \
     && grep '^R1 W2 W3 R4 => R1 R' $file >/dev/null \
     && grep '^R1 W2 R3 R4 R5 => R1 R' $file >/dev/null \
     && grep '^R1 W2 R3 R4 W5 => R1 R' $file >/dev/null \
     && grep '^R1 W2 R3 W4 R5 => R1 R' $file >/dev/null \
     && grep '^R1 W2 R3 W4 W5 => R1 R' $file >/dev/null \
     && grep '^R1 W2 W3 R4 R5 => R1 R' $file >/dev/null \
     && grep '^R1 W2 W3 R4 W5 => R1 R' $file >/dev/null \
     && grep '^R1 W2 W3 W4 R5 => R1 R' $file >/dev/null \
  ; then
    prefers_readers_1=true
    if    grep '^R1 W2 R3 => R1 R3' $file >/dev/null \
       && grep '^R1 W2 R3 R4 => R1 R3' $file >/dev/null \
       && grep '^R1 W2 R3 W4 => R1 R3' $file >/dev/null \
       && grep '^R1 W2 W3 R4 => R1 R4' $file >/dev/null \
       && grep '^R1 W2 R3 R4 R5 => R1 R3' $file >/dev/null \
       && grep '^R1 W2 R3 R4 W5 => R1 R3' $file >/dev/null \
       && grep '^R1 W2 R3 W4 R5 => R1 R3' $file >/dev/null \
       && grep '^R1 W2 R3 W4 W5 => R1 R3' $file >/dev/null \
       && grep '^R1 W2 W3 R4 R5 => R1 R4' $file >/dev/null \
       && grep '^R1 W2 W3 R4 W5 => R1 R4' $file >/dev/null \
       && grep '^R1 W2 W3 W4 R5 => R1 R5' $file >/dev/null \
    ; then
      echo "    If at least one of the enqueued lock attempts is for reading, the"
      echo "    first one of them is granted."
    else
      if    grep '^R1 W2 R3 => R1 R3' $file >/dev/null \
         && grep '^R1 W2 R3 R4 => R1 R4' $file >/dev/null \
         && grep '^R1 W2 R3 W4 => R1 R3' $file >/dev/null \
         && grep '^R1 W2 W3 R4 => R1 R4' $file >/dev/null \
         && grep '^R1 W2 R3 R4 R5 => R1 R5' $file >/dev/null \
         && grep '^R1 W2 R3 R4 W5 => R1 R4' $file >/dev/null \
         && grep '^R1 W2 R3 W4 R5 => R1 R5' $file >/dev/null \
         && grep '^R1 W2 R3 W4 W5 => R1 R3' $file >/dev/null \
         && grep '^R1 W2 W3 R4 R5 => R1 R5' $file >/dev/null \
         && grep '^R1 W2 W3 R4 W5 => R1 R4' $file >/dev/null \
         && grep '^R1 W2 W3 W4 R5 => R1 R5' $file >/dev/null \
      ; then
        echo "    If at least one of the enqueued lock attempts is for reading, the"
        echo "    latest (LIFO!) one of them is granted."
      else
        echo "    If at least one of the enqueued lock attempts is for reading, one"
        echo "    of them is granted."
        deterministic=false
      fi
    fi
    if    grep '^R1 W2 W3 => R1 W2' $file >/dev/null \
       && grep '^R1 W2 W3 W4 => R1 W2' $file >/dev/null \
       && grep '^R1 W2 W3 W4 W5 => R1 W2' $file >/dev/null \
    ; then
      echo "    Otherwise, the first of the waiting write attempts is granted."
    else
      if    grep '^R1 W2 W3 => R1 W3' $file >/dev/null \
         && grep '^R1 W2 W3 W4 => R1 W4' $file >/dev/null \
         && grep '^R1 W2 W3 W4 W5 => R1 W5' $file >/dev/null \
      ; then
        echo "    Otherwise, the latest (LIFO!) waiting write attempt is granted."
      else
        echo "    Otherwise ???"
        deterministic=false
      fi
    fi
  else
    if    grep '^R1 W2 R3 => R1 W' $file >/dev/null \
       && grep '^R1 W2 W3 => R1 W' $file >/dev/null \
       && grep '^R1 W2 R3 R4 => R1 W' $file >/dev/null \
       && grep '^R1 W2 R3 W4 => R1 W' $file >/dev/null \
       && grep '^R1 W2 W3 R4 => R1 W' $file >/dev/null \
       && grep '^R1 W2 W3 W4 => R1 W' $file >/dev/null \
       && grep '^R1 W2 R3 R4 R5 => R1 W' $file >/dev/null \
       && grep '^R1 W2 R3 R4 W5 => R1 W' $file >/dev/null \
       && grep '^R1 W2 R3 W4 R5 => R1 W' $file >/dev/null \
       && grep '^R1 W2 R3 W4 W5 => R1 W' $file >/dev/null \
       && grep '^R1 W2 W3 R4 R5 => R1 W' $file >/dev/null \
       && grep '^R1 W2 W3 R4 W5 => R1 W' $file >/dev/null \
       && grep '^R1 W2 W3 W4 R5 => R1 W' $file >/dev/null \
       && grep '^R1 W2 W3 W4 W5 => R1 W' $file >/dev/null \
    ; then
      prefers_writers_1=true
      if    grep '^R1 W2 R3 => R1 W2' $file >/dev/null \
         && grep '^R1 W2 W3 => R1 W2' $file >/dev/null \
         && grep '^R1 W2 R3 R4 => R1 W2' $file >/dev/null \
         && grep '^R1 W2 R3 W4 => R1 W2' $file >/dev/null \
         && grep '^R1 W2 W3 R4 => R1 W2' $file >/dev/null \
         && grep '^R1 W2 W3 W4 => R1 W2' $file >/dev/null \
         && grep '^R1 W2 R3 R4 R5 => R1 W2' $file >/dev/null \
         && grep '^R1 W2 R3 R4 W5 => R1 W2' $file >/dev/null \
         && grep '^R1 W2 R3 W4 R5 => R1 W2' $file >/dev/null \
         && grep '^R1 W2 R3 W4 W5 => R1 W2' $file >/dev/null \
         && grep '^R1 W2 W3 R4 R5 => R1 W2' $file >/dev/null \
         && grep '^R1 W2 W3 R4 W5 => R1 W2' $file >/dev/null \
         && grep '^R1 W2 W3 W4 R5 => R1 W2' $file >/dev/null \
         && grep '^R1 W2 W3 W4 W5 => R1 W2' $file >/dev/null \
      ; then
        echo "    If at least one of the enqueued lock attempts is for writing, the"
        echo "    first one of them is granted."
      else
        if    grep '^R1 W2 R3 => R1 W2' $file >/dev/null \
           && grep '^R1 W2 W3 => R1 W3' $file >/dev/null \
           && grep '^R1 W2 R3 R4 => R1 W2' $file >/dev/null \
           && grep '^R1 W2 R3 W4 => R1 W4' $file >/dev/null \
           && grep '^R1 W2 W3 R4 => R1 W3' $file >/dev/null \
           && grep '^R1 W2 W3 W4 => R1 W4' $file >/dev/null \
           && grep '^R1 W2 R3 R4 R5 => R1 W2' $file >/dev/null \
           && grep '^R1 W2 R3 R4 W5 => R1 W5' $file >/dev/null \
           && grep '^R1 W2 R3 W4 R5 => R1 W4' $file >/dev/null \
           && grep '^R1 W2 R3 W4 W5 => R1 W5' $file >/dev/null \
           && grep '^R1 W2 W3 R4 R5 => R1 W3' $file >/dev/null \
           && grep '^R1 W2 W3 R4 W5 => R1 W5' $file >/dev/null \
           && grep '^R1 W2 W3 W4 R5 => R1 W4' $file >/dev/null \
           && grep '^R1 W2 W3 W4 W5 => R1 W5' $file >/dev/null \
        ; then
          echo "    If at least one of the enqueued lock attempts is for writing, the"
          echo "    latest (LIFO!) one of them is granted."
        else
          echo "    If at least one of the enqueued lock attempts is for writing, one"
          echo "    of them is granted."
          deterministic=false
        fi
      fi
    else
      echo "    ???"
      deterministic=false
    fi
  fi
fi

echo "  When releasing a writer lock:"

# These are the lines that matter:
# W1 R2 R3 => W1 ...
# W1 R2 W3 => W1 ...
# W1 W2 R3 => W1 ...
# W1 W2 W3 => W1 ...
# W1 R2 R3 R4 => W1 ...
# W1 R2 R3 W4 => W1 ...
# W1 R2 W3 R4 => W1 ...
# W1 R2 W3 W4 => W1 ...
# W1 W2 R3 R4 => W1 ...
# W1 W2 R3 W4 => W1 ...
# W1 W2 W3 R4 => W1 ...
# W1 W2 W3 W4 => W1 ...
# W1 R2 R3 R4 R5 => W1 ...
# W1 R2 R3 R4 W5 => W1 ...
# W1 R2 R3 W4 R5 => W1 ...
# W1 R2 R3 W4 W5 => W1 ...
# W1 R2 W3 R4 R5 => W1 ...
# W1 R2 W3 R4 W5 => W1 ...
# W1 R2 W3 W4 R5 => W1 ...
# W1 R2 W3 W4 W5 => W1 ...
# W1 W2 R3 R4 R5 => W1 ...
# W1 W2 R3 R4 W5 => W1 ...
# W1 W2 R3 W4 R5 => W1 ...
# W1 W2 R3 W4 W5 => W1 ...
# W1 W2 W3 R4 R5 => W1 ...
# W1 W2 W3 R4 W5 => W1 ...
# W1 W2 W3 W4 R5 => W1 ...
# W1 W2 W3 W4 W5 => W1 ...

prefers_readers_2=false
prefers_writers_2=false
if    grep '^W1 R2 R3 => W1 R' $file >/dev/null \
   && grep '^W1 R2 W3 => W1 R' $file >/dev/null \
   && grep '^W1 W2 R3 => W1 W' $file >/dev/null \
   && grep '^W1 W2 W3 => W1 W' $file >/dev/null \
   && grep '^W1 R2 R3 R4 => W1 R' $file >/dev/null \
   && grep '^W1 R2 R3 W4 => W1 R' $file >/dev/null \
   && grep '^W1 R2 W3 R4 => W1 R' $file >/dev/null \
   && grep '^W1 R2 W3 W4 => W1 R' $file >/dev/null \
   && grep '^W1 W2 R3 R4 => W1 W' $file >/dev/null \
   && grep '^W1 W2 R3 W4 => W1 W' $file >/dev/null \
   && grep '^W1 W2 W3 R4 => W1 W' $file >/dev/null \
   && grep '^W1 W2 W3 W4 => W1 W' $file >/dev/null \
   && grep '^W1 R2 R3 R4 R5 => W1 R' $file >/dev/null \
   && grep '^W1 R2 R3 R4 W5 => W1 R' $file >/dev/null \
   && grep '^W1 R2 R3 W4 R5 => W1 R' $file >/dev/null \
   && grep '^W1 R2 R3 W4 W5 => W1 R' $file >/dev/null \
   && grep '^W1 R2 W3 R4 R5 => W1 R' $file >/dev/null \
   && grep '^W1 R2 W3 R4 W5 => W1 R' $file >/dev/null \
   && grep '^W1 R2 W3 W4 R5 => W1 R' $file >/dev/null \
   && grep '^W1 R2 W3 W4 W5 => W1 R' $file >/dev/null \
   && grep '^W1 W2 R3 R4 R5 => W1 W' $file >/dev/null \
   && grep '^W1 W2 R3 R4 W5 => W1 W' $file >/dev/null \
   && grep '^W1 W2 R3 W4 R5 => W1 W' $file >/dev/null \
   && grep '^W1 W2 R3 W4 W5 => W1 W' $file >/dev/null \
   && grep '^W1 W2 W3 R4 R5 => W1 W' $file >/dev/null \
   && grep '^W1 W2 W3 R4 W5 => W1 W' $file >/dev/null \
   && grep '^W1 W2 W3 W4 R5 => W1 W' $file >/dev/null \
   && grep '^W1 W2 W3 W4 W5 => W1 W' $file >/dev/null \
; then
  if    grep '^W1 R2 R3 => W1 R' $file >/dev/null \
     && grep '^W1 R2 W3 => W1 R' $file >/dev/null \
     && grep '^W1 W2 R3 => W1 W2' $file >/dev/null \
     && grep '^W1 W2 W3 => W1 W2' $file >/dev/null \
     && grep '^W1 R2 R3 R4 => W1 R' $file >/dev/null \
     && grep '^W1 R2 R3 W4 => W1 R' $file >/dev/null \
     && grep '^W1 R2 W3 R4 => W1 R' $file >/dev/null \
     && grep '^W1 R2 W3 W4 => W1 R' $file >/dev/null \
     && grep '^W1 W2 R3 R4 => W1 W2' $file >/dev/null \
     && grep '^W1 W2 R3 W4 => W1 W2' $file >/dev/null \
     && grep '^W1 W2 W3 R4 => W1 W2' $file >/dev/null \
     && grep '^W1 W2 W3 W4 => W1 W2' $file >/dev/null \
     && grep '^W1 R2 R3 R4 R5 => W1 R' $file >/dev/null \
     && grep '^W1 R2 R3 R4 W5 => W1 R' $file >/dev/null \
     && grep '^W1 R2 R3 W4 R5 => W1 R' $file >/dev/null \
     && grep '^W1 R2 R3 W4 W5 => W1 R' $file >/dev/null \
     && grep '^W1 R2 W3 R4 R5 => W1 R' $file >/dev/null \
     && grep '^W1 R2 W3 R4 W5 => W1 R' $file >/dev/null \
     && grep '^W1 R2 W3 W4 R5 => W1 R' $file >/dev/null \
     && grep '^W1 R2 W3 W4 W5 => W1 R' $file >/dev/null \
     && grep '^W1 W2 R3 R4 R5 => W1 W2' $file >/dev/null \
     && grep '^W1 W2 R3 R4 W5 => W1 W2' $file >/dev/null \
     && grep '^W1 W2 R3 W4 R5 => W1 W2' $file >/dev/null \
     && grep '^W1 W2 R3 W4 W5 => W1 W2' $file >/dev/null \
     && grep '^W1 W2 W3 R4 R5 => W1 W2' $file >/dev/null \
     && grep '^W1 W2 W3 R4 W5 => W1 W2' $file >/dev/null \
     && grep '^W1 W2 W3 W4 R5 => W1 W2' $file >/dev/null \
     && grep '^W1 W2 W3 W4 W5 => W1 W2' $file >/dev/null \
  ; then
    if    grep '^W1 R2 R3 => W1 R2' $file >/dev/null \
       && grep '^W1 R2 W3 => W1 R2' $file >/dev/null \
       && grep '^W1 W2 R3 => W1 W2' $file >/dev/null \
       && grep '^W1 W2 W3 => W1 W2' $file >/dev/null \
       && grep '^W1 R2 R3 R4 => W1 R2' $file >/dev/null \
       && grep '^W1 R2 R3 W4 => W1 R2' $file >/dev/null \
       && grep '^W1 R2 W3 R4 => W1 R2' $file >/dev/null \
       && grep '^W1 R2 W3 W4 => W1 R2' $file >/dev/null \
       && grep '^W1 W2 R3 R4 => W1 W2' $file >/dev/null \
       && grep '^W1 W2 R3 W4 => W1 W2' $file >/dev/null \
       && grep '^W1 W2 W3 R4 => W1 W2' $file >/dev/null \
       && grep '^W1 W2 W3 W4 => W1 W2' $file >/dev/null \
       && grep '^W1 R2 R3 R4 R5 => W1 R2' $file >/dev/null \
       && grep '^W1 R2 R3 R4 W5 => W1 R2' $file >/dev/null \
       && grep '^W1 R2 R3 W4 R5 => W1 R2' $file >/dev/null \
       && grep '^W1 R2 R3 W4 W5 => W1 R2' $file >/dev/null \
       && grep '^W1 R2 W3 R4 R5 => W1 R2' $file >/dev/null \
       && grep '^W1 R2 W3 R4 W5 => W1 R2' $file >/dev/null \
       && grep '^W1 R2 W3 W4 R5 => W1 R2' $file >/dev/null \
       && grep '^W1 R2 W3 W4 W5 => W1 R2' $file >/dev/null \
       && grep '^W1 W2 R3 R4 R5 => W1 W2' $file >/dev/null \
       && grep '^W1 W2 R3 R4 W5 => W1 W2' $file >/dev/null \
       && grep '^W1 W2 R3 W4 R5 => W1 W2' $file >/dev/null \
       && grep '^W1 W2 R3 W4 W5 => W1 W2' $file >/dev/null \
       && grep '^W1 W2 W3 R4 R5 => W1 W2' $file >/dev/null \
       && grep '^W1 W2 W3 R4 W5 => W1 W2' $file >/dev/null \
       && grep '^W1 W2 W3 W4 R5 => W1 W2' $file >/dev/null \
       && grep '^W1 W2 W3 W4 W5 => W1 W2' $file >/dev/null \
    ; then
      echo "    The first of the enqueued lock attempts is granted."
    else
      echo "    If at least one of the enqueued lock attempts is for writing, the"
      echo "    first of them is granted."
      echo "    Otherwise, one of the waiting read attempts is granted."
      deterministic=false
    fi
  else
    echo "    If at least one of the enqueued lock attempts is for writing, one of"
    echo "    the waiting write attempts is granted."
    echo "    Otherwise, one of the waiting read attempts is granted."
    deterministic=false
  fi
else
  if    grep '^W1 R2 R3 => W1 R' $file >/dev/null \
     && grep '^W1 R2 W3 => W1 R' $file >/dev/null \
     && grep '^W1 W2 R3 => W1 R' $file >/dev/null \
     && grep '^W1 R2 R3 R4 => W1 R' $file >/dev/null \
     && grep '^W1 R2 R3 W4 => W1 R' $file >/dev/null \
     && grep '^W1 R2 W3 R4 => W1 R' $file >/dev/null \
     && grep '^W1 R2 W3 W4 => W1 R' $file >/dev/null \
     && grep '^W1 W2 R3 R4 => W1 R' $file >/dev/null \
     && grep '^W1 W2 R3 W4 => W1 R' $file >/dev/null \
     && grep '^W1 W2 W3 R4 => W1 R' $file >/dev/null \
     && grep '^W1 R2 R3 R4 R5 => W1 R' $file >/dev/null \
     && grep '^W1 R2 R3 R4 W5 => W1 R' $file >/dev/null \
     && grep '^W1 R2 R3 W4 R5 => W1 R' $file >/dev/null \
     && grep '^W1 R2 R3 W4 W5 => W1 R' $file >/dev/null \
     && grep '^W1 R2 W3 R4 R5 => W1 R' $file >/dev/null \
     && grep '^W1 R2 W3 R4 W5 => W1 R' $file >/dev/null \
     && grep '^W1 R2 W3 W4 R5 => W1 R' $file >/dev/null \
     && grep '^W1 R2 W3 W4 W5 => W1 R' $file >/dev/null \
     && grep '^W1 W2 R3 R4 R5 => W1 R' $file >/dev/null \
     && grep '^W1 W2 R3 R4 W5 => W1 R' $file >/dev/null \
     && grep '^W1 W2 R3 W4 R5 => W1 R' $file >/dev/null \
     && grep '^W1 W2 R3 W4 W5 => W1 R' $file >/dev/null \
     && grep '^W1 W2 W3 R4 R5 => W1 R' $file >/dev/null \
     && grep '^W1 W2 W3 R4 W5 => W1 R' $file >/dev/null \
     && grep '^W1 W2 W3 W4 R5 => W1 R' $file >/dev/null \
  ; then
    prefers_readers_2=true
    if    grep '^W1 R2 R3 => W1 R2' $file >/dev/null \
       && grep '^W1 R2 W3 => W1 R2' $file >/dev/null \
       && grep '^W1 W2 R3 => W1 R3' $file >/dev/null \
       && grep '^W1 R2 R3 R4 => W1 R2' $file >/dev/null \
       && grep '^W1 R2 R3 W4 => W1 R2' $file >/dev/null \
       && grep '^W1 R2 W3 R4 => W1 R2' $file >/dev/null \
       && grep '^W1 R2 W3 W4 => W1 R2' $file >/dev/null \
       && grep '^W1 W2 R3 R4 => W1 R3' $file >/dev/null \
       && grep '^W1 W2 R3 W4 => W1 R3' $file >/dev/null \
       && grep '^W1 W2 W3 R4 => W1 R4' $file >/dev/null \
       && grep '^W1 R2 R3 R4 R5 => W1 R2' $file >/dev/null \
       && grep '^W1 R2 R3 R4 W5 => W1 R2' $file >/dev/null \
       && grep '^W1 R2 R3 W4 R5 => W1 R2' $file >/dev/null \
       && grep '^W1 R2 R3 W4 W5 => W1 R2' $file >/dev/null \
       && grep '^W1 R2 W3 R4 R5 => W1 R2' $file >/dev/null \
       && grep '^W1 R2 W3 R4 W5 => W1 R2' $file >/dev/null \
       && grep '^W1 R2 W3 W4 R5 => W1 R2' $file >/dev/null \
       && grep '^W1 R2 W3 W4 W5 => W1 R2' $file >/dev/null \
       && grep '^W1 W2 R3 R4 R5 => W1 R3' $file >/dev/null \
       && grep '^W1 W2 R3 R4 W5 => W1 R3' $file >/dev/null \
       && grep '^W1 W2 R3 W4 R5 => W1 R3' $file >/dev/null \
       && grep '^W1 W2 R3 W4 W5 => W1 R3' $file >/dev/null \
       && grep '^W1 W2 W3 R4 R5 => W1 R4' $file >/dev/null \
       && grep '^W1 W2 W3 R4 W5 => W1 R4' $file >/dev/null \
       && grep '^W1 W2 W3 W4 R5 => W1 R5' $file >/dev/null \
    ; then
      echo "    If at least one of the enqueued lock attempts is for reading, the"
      echo "    first of them is granted."
    else
      if    grep '^W1 R2 R3 => W1 R3' $file >/dev/null \
         && grep '^W1 R2 W3 => W1 R2' $file >/dev/null \
         && grep '^W1 W2 R3 => W1 R3' $file >/dev/null \
         && grep '^W1 R2 R3 R4 => W1 R4' $file >/dev/null \
         && grep '^W1 R2 R3 W4 => W1 R3' $file >/dev/null \
         && grep '^W1 R2 W3 R4 => W1 R4' $file >/dev/null \
         && grep '^W1 R2 W3 W4 => W1 R2' $file >/dev/null \
         && grep '^W1 W2 R3 R4 => W1 R4' $file >/dev/null \
         && grep '^W1 W2 R3 W4 => W1 R3' $file >/dev/null \
         && grep '^W1 W2 W3 R4 => W1 R4' $file >/dev/null \
         && grep '^W1 R2 R3 R4 R5 => W1 R5' $file >/dev/null \
         && grep '^W1 R2 R3 R4 W5 => W1 R4' $file >/dev/null \
         && grep '^W1 R2 R3 W4 R5 => W1 R5' $file >/dev/null \
         && grep '^W1 R2 R3 W4 W5 => W1 R3' $file >/dev/null \
         && grep '^W1 R2 W3 R4 R5 => W1 R5' $file >/dev/null \
         && grep '^W1 R2 W3 R4 W5 => W1 R4' $file >/dev/null \
         && grep '^W1 R2 W3 W4 R5 => W1 R5' $file >/dev/null \
         && grep '^W1 R2 W3 W4 W5 => W1 R2' $file >/dev/null \
         && grep '^W1 W2 R3 R4 R5 => W1 R5' $file >/dev/null \
         && grep '^W1 W2 R3 R4 W5 => W1 R4' $file >/dev/null \
         && grep '^W1 W2 R3 W4 R5 => W1 R5' $file >/dev/null \
         && grep '^W1 W2 R3 W4 W5 => W1 R3' $file >/dev/null \
         && grep '^W1 W2 W3 R4 R5 => W1 R5' $file >/dev/null \
         && grep '^W1 W2 W3 R4 W5 => W1 R4' $file >/dev/null \
         && grep '^W1 W2 W3 W4 R5 => W1 R5' $file >/dev/null \
      ; then
        echo "    If at least one of the enqueued lock attempts is for reading, the"
        echo "    latest (LIFO!) one of them is granted."
      else
        echo "    If at least one of the enqueued lock attempts is for reading, one of"
        echo "    them is granted."
        deterministic=false
      fi
    fi
    if    grep '^W1 W2 W3 => W1 W2 W3' $file >/dev/null \
       && grep '^W1 W2 W3 W4 => W1 W2 W3 W4' $file >/dev/null \
       && grep '^W1 W2 W3 W4 W5 => W1 W2 W3 W4 W5' $file >/dev/null \
    ; then
      echo "    Otherwise, the first of the waiting write attempts is granted."
    else
      if    grep '^W1 W2 W3 => W1 W3' $file >/dev/null \
         && grep '^W1 W2 W3 W4 => W1 W4' $file >/dev/null \
         && grep '^W1 W2 W3 W4 W5 => W1 W5' $file >/dev/null \
      ; then
        echo "    Otherwise, the latest (LIFO!) of the waiting write attempts is granted."
      else
        echo "    Otherwise ???"
        deterministic=false
      fi
    fi
  else
    if    grep '^W1 R2 W3 => W1 W' $file >/dev/null \
       && grep '^W1 W2 R3 => W1 W' $file >/dev/null \
       && grep '^W1 W2 W3 => W1 W' $file >/dev/null \
       && grep '^W1 R2 R3 W4 => W1 W' $file >/dev/null \
       && grep '^W1 R2 W3 R4 => W1 W' $file >/dev/null \
       && grep '^W1 R2 W3 W4 => W1 W' $file >/dev/null \
       && grep '^W1 W2 R3 R4 => W1 W' $file >/dev/null \
       && grep '^W1 W2 R3 W4 => W1 W' $file >/dev/null \
       && grep '^W1 W2 W3 R4 => W1 W' $file >/dev/null \
       && grep '^W1 W2 W3 W4 => W1 W' $file >/dev/null \
       && grep '^W1 R2 R3 R4 W5 => W1 W' $file >/dev/null \
       && grep '^W1 R2 R3 W4 R5 => W1 W' $file >/dev/null \
       && grep '^W1 R2 R3 W4 W5 => W1 W' $file >/dev/null \
       && grep '^W1 R2 W3 R4 R5 => W1 W' $file >/dev/null \
       && grep '^W1 R2 W3 R4 W5 => W1 W' $file >/dev/null \
       && grep '^W1 R2 W3 W4 R5 => W1 W' $file >/dev/null \
       && grep '^W1 R2 W3 W4 W5 => W1 W' $file >/dev/null \
       && grep '^W1 W2 R3 R4 R5 => W1 W' $file >/dev/null \
       && grep '^W1 W2 R3 R4 W5 => W1 W' $file >/dev/null \
       && grep '^W1 W2 R3 W4 R5 => W1 W' $file >/dev/null \
       && grep '^W1 W2 R3 W4 W5 => W1 W' $file >/dev/null \
       && grep '^W1 W2 W3 R4 R5 => W1 W' $file >/dev/null \
       && grep '^W1 W2 W3 R4 W5 => W1 W' $file >/dev/null \
       && grep '^W1 W2 W3 W4 R5 => W1 W' $file >/dev/null \
       && grep '^W1 W2 W3 W4 W5 => W1 W' $file >/dev/null \
    ; then
      prefers_writers_2=true
      if    grep '^W1 R2 W3 => W1 W3' $file >/dev/null \
         && grep '^W1 W2 R3 => W1 W2' $file >/dev/null \
         && grep '^W1 W2 W3 => W1 W2' $file >/dev/null \
         && grep '^W1 R2 R3 W4 => W1 W4' $file >/dev/null \
         && grep '^W1 R2 W3 R4 => W1 W3' $file >/dev/null \
         && grep '^W1 R2 W3 W4 => W1 W3' $file >/dev/null \
         && grep '^W1 W2 R3 R4 => W1 W2' $file >/dev/null \
         && grep '^W1 W2 R3 W4 => W1 W2' $file >/dev/null \
         && grep '^W1 W2 W3 R4 => W1 W2' $file >/dev/null \
         && grep '^W1 W2 W3 W4 => W1 W2' $file >/dev/null \
         && grep '^W1 R2 R3 R4 W5 => W1 W5' $file >/dev/null \
         && grep '^W1 R2 R3 W4 R5 => W1 W4' $file >/dev/null \
         && grep '^W1 R2 R3 W4 W5 => W1 W4' $file >/dev/null \
         && grep '^W1 R2 W3 R4 R5 => W1 W3' $file >/dev/null \
         && grep '^W1 R2 W3 R4 W5 => W1 W3' $file >/dev/null \
         && grep '^W1 R2 W3 W4 R5 => W1 W3' $file >/dev/null \
         && grep '^W1 R2 W3 W4 W5 => W1 W3' $file >/dev/null \
         && grep '^W1 W2 R3 R4 R5 => W1 W2' $file >/dev/null \
         && grep '^W1 W2 R3 R4 W5 => W1 W2' $file >/dev/null \
         && grep '^W1 W2 R3 W4 R5 => W1 W2' $file >/dev/null \
         && grep '^W1 W2 R3 W4 W5 => W1 W2' $file >/dev/null \
         && grep '^W1 W2 W3 R4 R5 => W1 W2' $file >/dev/null \
         && grep '^W1 W2 W3 R4 W5 => W1 W2' $file >/dev/null \
         && grep '^W1 W2 W3 W4 R5 => W1 W2' $file >/dev/null \
         && grep '^W1 W2 W3 W4 W5 => W1 W2' $file >/dev/null \
      ; then
        echo "    If at least one of the enqueued lock attempts is for writing, the"
        echo "    first one of them is granted."
      else
        if    grep '^W1 R2 W3 => W1 W3' $file >/dev/null \
           && grep '^W1 W2 R3 => W1 W2' $file >/dev/null \
           && grep '^W1 W2 W3 => W1 W3' $file >/dev/null \
           && grep '^W1 R2 R3 W4 => W1 W4' $file >/dev/null \
           && grep '^W1 R2 W3 R4 => W1 W3' $file >/dev/null \
           && grep '^W1 R2 W3 W4 => W1 W4' $file >/dev/null \
           && grep '^W1 W2 R3 R4 => W1 W2' $file >/dev/null \
           && grep '^W1 W2 R3 W4 => W1 W4' $file >/dev/null \
           && grep '^W1 W2 W3 R4 => W1 W3' $file >/dev/null \
           && grep '^W1 W2 W3 W4 => W1 W4' $file >/dev/null \
           && grep '^W1 R2 R3 R4 W5 => W1 W5' $file >/dev/null \
           && grep '^W1 R2 R3 W4 R5 => W1 W4' $file >/dev/null \
           && grep '^W1 R2 R3 W4 W5 => W1 W5' $file >/dev/null \
           && grep '^W1 R2 W3 R4 R5 => W1 W3' $file >/dev/null \
           && grep '^W1 R2 W3 R4 W5 => W1 W5' $file >/dev/null \
           && grep '^W1 R2 W3 W4 R5 => W1 W4' $file >/dev/null \
           && grep '^W1 R2 W3 W4 W5 => W1 W5' $file >/dev/null \
           && grep '^W1 W2 R3 R4 R5 => W1 W2' $file >/dev/null \
           && grep '^W1 W2 R3 R4 W5 => W1 W5' $file >/dev/null \
           && grep '^W1 W2 R3 W4 R5 => W1 W4' $file >/dev/null \
           && grep '^W1 W2 R3 W4 W5 => W1 W5' $file >/dev/null \
           && grep '^W1 W2 W3 R4 R5 => W1 W3' $file >/dev/null \
           && grep '^W1 W2 W3 R4 W5 => W1 W5' $file >/dev/null \
           && grep '^W1 W2 W3 W4 R5 => W1 W4' $file >/dev/null \
           && grep '^W1 W2 W3 W4 W5 => W1 W5' $file >/dev/null \
        ; then
          echo "    If at least one of the enqueued lock attempts is for writing, the"
          echo "    latest (LIFO!) one of them is granted."
        else
          echo "    If at least one of the enqueued lock attempts is for writing, one of"
          echo "    the waiting write attempts is granted (not necessarily the first one)."
          deterministic=false
        fi
      fi
      if    grep '^W1 R2 R3 => W1 R' $file >/dev/null \
         && grep '^W1 R2 R3 R4 => W1 R' $file >/dev/null \
         && grep '^W1 R2 R3 R4 R5 => W1 R' $file >/dev/null \
      ; then
        if    grep '^W1 R2 R3 => W1 R2 R3' $file >/dev/null \
           && grep '^W1 R2 R3 R4 => W1 R2 R3 R4' $file >/dev/null \
           && grep '^W1 R2 R3 R4 R5 => W1 R2 R3 R4 R5' $file >/dev/null \
        ; then
          echo "    Otherwise, the first of the waiting read attempts is granted."
        else
          if    grep '^W1 R2 R3 => W1 R3' $file >/dev/null \
             && grep '^W1 R2 R3 R4 => W1 R4' $file >/dev/null \
             && grep '^W1 R2 R3 R4 R5 => W1 R5' $file >/dev/null \
          ; then
            echo "    Otherwise, the latest (LIFO!) of the waiting read attempts is granted."
          else
            echo "    Otherwise, one of the waiting read attempts is granted."
            deterministic=false
          fi
        fi
      else
        echo "    Otherwise, ???"
        deterministic=false
      fi
    else
      echo "    ???"
      deterministic=false
    fi
  fi
fi

if $prefers_readers_1; then
  if $prefers_readers_2; then
    echo "  This implementation always prefers readers."
  else
    echo "  This implementation does not globally prefer readers, only when releasing"
    echo "  a reader lock."
  fi
else
  if $prefers_readers_2; then
    echo "  This implementation does not globally prefer readers, only when releasing"
    echo "  a writer lock."
  else
    echo "  This implementation does not prefer readers."
  fi
fi

if $prefers_writers_1; then
  if $prefers_writers_2; then
    echo "  This implementation always prefers writers."
  else
    echo "  This implementation does not globally prefer writers, only when releasing"
    echo "  a reader lock."
  fi
else
  if $prefers_writers_2; then
    echo "  This implementation does not globally prefer writers, only when releasing"
    echo "  a writer lock."
  else
    echo "  This implementation does not prefer writers."
  fi
fi

if $deterministic; then
  echo "  This implementation is deterministic."
fi

exit 0
