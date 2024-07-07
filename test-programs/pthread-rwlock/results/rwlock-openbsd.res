  When releasing the last reader lock:
    If at least one of the enqueued lock attempts is for reading, the
    first one of them is granted.
    Otherwise, the first of the waiting write attempts is granted.
  When releasing a writer lock:
    The first of the enqueued lock attempts is granted.
  This implementation does not globally prefer readers, only when releasing
  a reader lock.
  This implementation does not prefer writers.
  This implementation is deterministic.
