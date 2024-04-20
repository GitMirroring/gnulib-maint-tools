#!/bin/sh
fail=0
for dir in info-tests create-tests import-tests; do
  echo "Running tests in $dir..."
  (cd "$dir" && ./test-all.sh)
  case $? in
    0) # PASS
      ;;
    77) # SKIP
      ;;
    *) # FAIL
      fail=1
      ;;
  esac
done
exit $fail
