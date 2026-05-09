"""
6. Reference counter demo
Use Python's sys.getrefcount() to watch an object's reference count go up and down as you create aliases and delete them.
memory
import sys
data = [10, 20, 30]
# Check refcount, then create aliases,
# check again, then del them one by one.
"""

import sys
data = [10,20,30]
print(sys.getrefcount(data))
alias = data
print(sys.getrefcount(data))  #this acts as tempopary referance to obj because as fucntion parameter we are passing.