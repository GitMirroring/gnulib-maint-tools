  When releasing the last reader lock:
    If at least one of the enqueued lock attempts is for reading, the
    first one of them is granted.
    Otherwise, the first of the waiting write attempts is granted.
  When releasing a writer lock:
    If at least one of the enqueued lock attempts is for reading, one of
    them is granted.
    Otherwise, the first of the waiting write attempts is granted.
  This implementation always prefers readers.
  This implementation does not prefer writers.
