  When releasing the last reader lock:
    The first of the enqueued lock attempts is granted.
  When releasing a writer lock:
    If at least one of the enqueued lock attempts is for writing, the
    first one of them is granted.
    Otherwise, one of the waiting read attempts is granted.
  This implementation does not prefer readers.
  This implementation does not globally prefer writers, only when releasing
  a writer lock.
