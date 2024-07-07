  When releasing the last reader lock:
    If at least one of the enqueued lock attempts is for writing, one
    of them is granted.
  When releasing a writer lock:
    If at least one of the enqueued lock attempts is for writing, one of
    the waiting write attempts is granted (not necessarily the first one).
    Otherwise, one of the waiting read attempts is granted.
  This implementation does not prefer readers.
  This implementation always prefers writers.
