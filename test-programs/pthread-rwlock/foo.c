/* Shows an implementation's wait queue handling of POSIX rwlocks.

   This file is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published
   by the Free Software Foundation, either version 3 of the License,
   or (at your option) any later version.

   This file is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* This program shows the wait queue handling of POSIX rwlocks.

   The program has a single pthread_rwlock_t.

   The function do_test takes as argument a string consisting of Rs and Ws,
   for example RWRRW. It launches a corresponding number of threads:
   For each R, a thread that attempts to lock the lock for reading;
   for each W, a thread that attempts to lock the lock for writing.
   The threads do this lock attempt one after the other.
   The first thread keeps the lock until after all threads have issued their
   requests, then releases it. The interesting part is, then, in which order
   these lock attempts are granted.

   The main() function can be invoked
     - either with such an R-W-string as argument. It then performs one do_test
       invocation.
     - or with a number, for example 5. It then performs do_test calls for all
       possible R-W-strings of that length.  */

#include <errno.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define STEP_INTERVAL 100000 /* microseconds */

static pthread_rwlock_t lock;

struct locals { const char *name; unsigned int wait_before; unsigned int wait_after; };

static void *
reader_func (void *arg)
{
  struct locals *l = arg;
  int err;

  if (l->wait_before > 0)
    usleep (l->wait_before);
  err = pthread_rwlock_rdlock (&lock);
  if (err)
    {
      fprintf (stderr, "pthread_rwlock_rdlock failed, error = %d\n", err);
      abort ();
    }
  printf (" %s", l->name);
  if (l->wait_after > 0)
    usleep (l->wait_after);
  err = pthread_rwlock_unlock (&lock);
  if (err)
    {
      fprintf (stderr, "pthread_rwlock_unlock failed, error = %d\n", err);
      abort ();
    }

  return NULL;
}

static void *
writer_func (void *arg)
{
  struct locals *l = arg;
  int err;

  if (l->wait_before > 0)
    usleep (l->wait_before);
  err = pthread_rwlock_wrlock (&lock);
  if (err)
    {
      fprintf (stderr, "pthread_rwlock_rdlock failed, error = %d\n", err);
      abort ();
    }
  printf (" %s", l->name);
  if (l->wait_after > 0)
    usleep (l->wait_after);
  err = pthread_rwlock_unlock (&lock);
  if (err)
    {
      fprintf (stderr, "pthread_rwlock_unlock failed, error = %d\n", err);
      abort ();
    }

  return NULL;
}

static void
do_test (const char *rw_string)
{
  size_t n = strlen (rw_string);
  int err;

  char **names = (char **) malloc (n * sizeof (char *));
  for (size_t i = 0; i < n; i++)
    {
      char name[10];
      sprintf (name, "%c%u", rw_string[i], (unsigned int) (i+1));
      names[i] = strdup (name);
      printf ("%s ", names[i]);
    }

#if defined PREFER_WRITER /* optionally, on glibc */
  pthread_rwlockattr_t attr;
  pthread_rwlockattr_init (&attr);
  pthread_rwlockattr_setkind_np (&attr, PTHREAD_RWLOCK_PREFER_WRITER_NP);
  err = pthread_rwlock_init (&lock, &attr);
  pthread_rwlockattr_destroy (&attr);
#elif defined PREFER_WRITER_NONRECURSIVE /* optionally, on glibc */
  pthread_rwlockattr_t attr;
  pthread_rwlockattr_init (&attr);
  pthread_rwlockattr_setkind_np (&attr, PTHREAD_RWLOCK_PREFER_WRITER_NONRECURSIVE_NP);
  err = pthread_rwlock_init (&lock, &attr);
  pthread_rwlockattr_destroy (&attr);
#else /* default */
  err = pthread_rwlock_init (&lock, NULL);
#endif
  if (err)
    {
      fprintf (stderr, "pthread_rwlock_init failed, error = %d\n", err);
      abort ();
    }

  printf ("=>");

  /* Create the threads.  */
  struct locals *locals = (struct locals *) malloc (n * sizeof (struct locals));
  pthread_t *threads = (pthread_t *) malloc (n * sizeof (pthread_t));
  for (size_t i = 0; i < n; i++)
    {
      locals[i].name = names[i];
      locals[i].wait_before = i * STEP_INTERVAL;
      locals[i].wait_after  = (i == 0 ? n * STEP_INTERVAL : 0);
      err = pthread_create (&threads[i], NULL,
                            rw_string[i] == 'R' ? reader_func : rw_string[i] == 'W' ? writer_func : (abort (), NULL),
                            &locals[i]);
      if (err)
        {
          fprintf (stderr, "pthread_create failed to create thread %u, error = %d\n", (unsigned int) (i+1), err);
          abort ();
        }
    }

  /* Wait until the threads are done.  */
  for (size_t i = 0; i < n; i++)
    {
      void *retcode;
      err = pthread_join (threads[i], &retcode);
      if (err)
        {
          fprintf (stderr, "pthread_join failed to wait for thread %u, error = %d\n", (unsigned int) (i+1), err);
          abort ();
        }
    }

  printf ("\n");

  /* Clean up.  */
  err = pthread_rwlock_destroy (&lock);
  if (err)
    {
      fprintf (stderr, "pthread_rwlock_destroy failed, error = %d\n", err);
      abort ();
    }
  free (threads);
  free (locals);
  for (size_t i = 0; i < n; i++)
    free (names[i]);
  free (names);
}

int
main (int argc, char *argv[])
{
  if (argc != 2)
    {
      fprintf (stderr, "Usage: foo RW..WR\nor: foo n\n");
      exit (1);
    }

  const char *arg1 = argv[1];
  if (arg1[0] == 'R' || arg1[0] == 'W')
    do_test (arg1);
  else
    {
      unsigned int n_max = (int) atoi (argv[1]);
      for (unsigned int n = 1; n <= n_max; n++)
        {
          char *buf = malloc (n+1);
          for (unsigned int k = 0; k < (1U << n); k++)
            {
              for (unsigned int i = 0; i < n; i++)
                buf[i] = ((k >> (n-1-i)) & 1 ? 'W' : 'R');
              buf[n] = '\0';

              do_test (buf);
            }
          free (buf);
        }
    }

  return 0;
}

/*
  gcc -Wall foo.c [-lpthread] -o foo
  On glibc also:
  gcc -Wall foo.c [-lpthread] -o foo -DPREFER_WRITER
  gcc -Wall foo.c [-lpthread] -o foo -DPREFER_WRITER_NONRECURSIVE

  For use with gnulib:
  - Add #include <config.h> at the top.
  - Use compilation options
      -Itestdir/build -Itestdir/build/gllib -Itestdir/gllib \
      -Ltestdir/build/libgnu.a
*/
