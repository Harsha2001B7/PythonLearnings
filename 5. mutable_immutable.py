# Immutable: int, float, bool, str, tuple, frozenset, bytes
s = "hello"
# s[0] = "H"  # ERROR — strings can't be modified in place
s = "Hello"   # this just rebinds s to a NEW string object
 
# Mutable: list, dict, set, bytearray, most custom classes
nums = [1, 2, 3]
nums[0] = 99   # OK — we changed the list itself
nums.append(4) # also OK — same object, modified
