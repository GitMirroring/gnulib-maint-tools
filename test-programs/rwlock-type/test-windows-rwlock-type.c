/* Test of locking in multithreaded situations.
   Copyright (C) 2024 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* Written by Bruno Haible <bruno@clisp.org>, 2024.  */

#include <config.h>

#if defined _WIN32 && !defined __CYGWIN__

/* Specification.  */
# include "windows-rwlock.h"

# include <errno.h>
# include <stdio.h>
# include <string.h>

# include "macros.h"

/* Returns the effective type of a read-write-lock.  */
static const char *
get_effective_type (glwthread_rwlock_t *lock)
{
  /* Lock for reading once.  */
  ASSERT (glwthread_rwlock_rdlock (lock) == 0);
  /* Lock for reading a second time.  */
  ASSERT (glwthread_rwlock_rdlock (lock) == 0);
  /* Unlock.  */
  ASSERT (glwthread_rwlock_unlock (lock) == 0);
  ASSERT (glwthread_rwlock_unlock (lock) == 0);

  /* Lock for writing once.  */
  ASSERT (glwthread_rwlock_wrlock (lock) == 0);

  /* Try to lock for writing a second time.  */
  int err = glwthread_rwlock_trywrlock (lock);
  if (err == 0)
    return "RECURSIVE";
  if (err == EBUSY)
    return "NORMAL";

  return "impossible!";
}

int
main ()
{
  /* Find the effective type of a read-write-lock.  */
  const char *type;
  {
    glwthread_rwlock_t lock;
    glwthread_rwlock_init (&lock);
    type = get_effective_type (&lock);
  }

  printf ("type = %s\n", type);

  ASSERT (strcmp (type, "NORMAL") == 0);

  return test_exit_status;
}

#else

# include <stdio.h>

int
main ()
{
  fputs ("Skipping test: not a native Windows system\n", stderr);
  return 77;
}

#endif

/* Results:
native Windows  NORMAL
*/
