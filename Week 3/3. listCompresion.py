fruits = ["apple", "banana", "cherry", "kiwi", "mango"]
newList = []

for fruit in fruits:
    if "a" in fruit:
        newList.append(fruit)
print(newList)


fruits = ["apple", "banana", "cherry", "kiwi", "mango"]

newlist = [x for x in fruits if "a" in x]

print(newlist)

# newlist = [expression for item in iterable if condition == True]

newlist = [x for x in range(10) if x < 5]
        