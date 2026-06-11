"""
5. Mutation inside a function
Write two functions — one that mutates a list argument, one that tries to mutate a string. Show the caller's result in both cases and explain why they differ.
memory
"""

# def add_item(lst):
#     lst.append("new")

# def shout(s):
#     s = s.upper()  # does this change the caller's s?

# my_list = ["a", "b"]
# my_str = "hello"
# add_item(my_list)
# shout(my_str)
# print(my_list, my_str)

def shout(s):
    print("Before upper:", s, id(s))

    s = s.upper()

    print("After upper :", s, id(s))

my_str = "hello"

print("Original:", my_str, id(my_str))

shout(my_str)

print("Outside :", my_str, id(my_str))