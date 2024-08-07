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

/* Specification.  */
#include <pthread.h>

#include <errno.h>
#include <stdio.h>
#include <string.h>

#include "macros.h"

/* Returns the effective type of a lock.  */
static const char *
get_effective_type (pthread_rwlock_t *lock)
{
  /* Lock for reading once.  */
  ASSERT (pthread_rwlock_rdlock (lock) == 0);
  /* Lock for reading a second time.  */
  ASSERT (pthread_rwlock_rdlock (lock) == 0);
  /* Unlock.  */
  ASSERT (pthread_rwlock_unlock (lock) == 0);
  ASSERT (pthread_rwlock_unlock (lock) == 0);

  /* Lock for writing once.  */
  ASSERT (pthread_rwlock_wrlock (lock) == 0);

  /* Try to lock for writing a second time.  */
  int err = pthread_rwlock_trywrlock (lock);
  if (err == 0)
    return "RECURSIVE";
  if (err == EBUSY)
    return "NORMAL";
  if (err == EDEADLK)
    return "NORMAL with macOS bug";

  return "impossible!";
}

int
main ()
{
#if __GLIBC__ >= 2 && defined __linux__

  /* Find the effective type of a PREFER_READER lock.  */
  const char *type_p_reader;
  {
    pthread_rwlock_t lock;
    pthread_rwlockattr_t attr;
    ASSERT (pthread_rwlockattr_init (&attr) == 0);
    ASSERT (pthread_rwlockattr_setkind_np (&attr, PTHREAD_RWLOCK_PREFER_READER_NP) == 0);
    ASSERT (pthread_rwlock_init (&lock, &attr) == 0);
    ASSERT (pthread_rwlockattr_destroy (&attr) == 0);
    type_p_reader = get_effective_type (&lock);
  }

  /* Find the effective type of an PREFER_WRITER lock.  */
  const char *type_p_writer;
  {
    pthread_rwlock_t lock;
    pthread_rwlockattr_t attr;
    ASSERT (pthread_rwlockattr_init (&attr) == 0);
    ASSERT (pthread_rwlockattr_setkind_np (&attr, PTHREAD_RWLOCK_PREFER_WRITER_NP) == 0);
    ASSERT (pthread_rwlock_init (&lock, &attr) == 0);
    ASSERT (pthread_rwlockattr_destroy (&attr) == 0);
    type_p_writer = get_effective_type (&lock);
  }

  /* Find the effective type of a PREFER_WRITER_NONRECURSIVE lock.  */
  const char *type_p_writer_nonrec;
  {
    pthread_rwlock_t lock;
    pthread_rwlockattr_t attr;
    ASSERT (pthread_rwlockattr_init (&attr) == 0);
    ASSERT (pthread_rwlockattr_setkind_np (&attr, PTHREAD_RWLOCK_PREFER_WRITER_NONRECURSIVE_NP) == 0);
    ASSERT (pthread_rwlock_init (&lock, &attr) == 0);
    ASSERT (pthread_rwlockattr_destroy (&attr) == 0);
    type_p_writer_nonrec = get_effective_type (&lock);
  }

  /* Find the effective type of a DEFAULT lock.  */
  const char *type_default;
  {
    pthread_rwlock_t lock;
    pthread_rwlockattr_t attr;
    ASSERT (pthread_rwlockattr_init (&attr) == 0);
    ASSERT (pthread_rwlockattr_setkind_np (&attr, PTHREAD_RWLOCK_DEFAULT_NP) == 0);
    ASSERT (pthread_rwlock_init (&lock, &attr) == 0);
    ASSERT (pthread_rwlockattr_destroy (&attr) == 0);
    type_default = get_effective_type (&lock);
  }

#endif

  /* Find the effective type of a default-initialized lock.  */
  const char *type_def;
  {
    pthread_rwlock_t lock;
    ASSERT (pthread_rwlock_init (&lock, NULL) == 0);
    type_def = get_effective_type (&lock);
  }

#if __GLIBC__ >= 2 && defined __linux__
  printf ("PREFER_READER               -> type = %s\n", type_p_reader);
  printf ("PREFER_WRITER               -> type = %s\n", type_p_writer);
  printf ("PREFER_WRITER_NONRECURSIVE  -> type = %s\n", type_p_writer_nonrec);
  printf ("DEFAULT                     -> type = %s\n", type_default);
#endif
  printf ("Default                     -> type = %s\n", type_def);

#if __GLIBC__ >= 2 && defined __linux__
  ASSERT (strcmp (type_default, type_def) == 0);
#endif

  return test_exit_status;
}

/* Results:
glibc                all NORMAL
macOS                NORMAL with macOS bug
all other platforms: NORMAL
*/
