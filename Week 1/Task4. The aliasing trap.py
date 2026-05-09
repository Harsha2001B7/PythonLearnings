"""
4. The aliasing trap
Write a program that shows the difference between aliasing a list vs copying it — with id() proof.
memory
original = [1, 2, 3]
alias = original
copy = original.copy()
# Modify alias → original changes
# Modify copy → original stays
# Print id() of all three
"""

# cars = ["benz","toyota","audi"]
# print(id(cars))
# alias = cars
# print(id(alias))
# copy = cars.copy()
# print(id(copy))
# cars.append("bmw")

# print(id(cars))
# print(id(alias))
# print(id(copy))

# print(cars)
# print(alias)
# print(copy)

original = [1, 2, 3]
alias = original
copy = original.copy()

alias.append(99)
print("After alias.append(99):")
print(f"  original: {original}")  # [1, 2, 3, 99]
print(f"  alias   : {alias}")     # [1, 2, 3, 99]

copy.append(100)
print("After copy.append(100):")
print(f"  original: {original}")  # unchanged
print(f"  copy    : {copy}")

print(f"\nid(original): {id(original)}")
print(f"id(alias)   : {id(alias)}")
print(f"id(copy)    : {id(copy)}")
