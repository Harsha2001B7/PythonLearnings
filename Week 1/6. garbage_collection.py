x = [1, 2, 3]   # list object's refcount = 1
y = x           # refcount = 2
del x           # refcount = 1
y = None        # refcount = 0  →  list is destroyed
