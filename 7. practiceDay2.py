# 1.	Run `a = [1,2,3]; b = a; b.append(4); print(a)`. Predict the output before running. Explain WHY in one sentence.

"""a=[1,2,3]
b=a
b.append(4)
print(a)
"""

# 2.	Use `id()` to confirm: when you do `s = 'hi'; s = s + '!'`, the id of s changes.
"""
s='hi'
print(id(s), '  ',s)
s=s+'!'
print(id(s), '  ',s)
"""

# 3.	Write a function that takes a list, appends an item, and returns nothing. Show that the caller's list changed. Then do the same with a string and show it didn't.
"""
def add_to_list(my_list, item):
    my_list.append(item)

numbers = [1, 2, 3]
print("Before:", numbers)
add_to_list(numbers, 4)
print("After:", numbers)

"""

def add_to_string(text):
    text += " world"

message = "Hello"
print("Before:", message)
add_to_string(message)
print("After:", message)

# 4.	Read PEP 8 §Naming Conventions — just that one section.


