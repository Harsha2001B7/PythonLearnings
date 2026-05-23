myTuple = (1,2,3)
print(myTuple)


thistuple = ("apple", "banana", "cherry", "apple", "cherry")
print(thistuple)


thistuple = ("apple",)
print(type(thistuple))

#NOT a tuple unless specified
thistuple = tuple("apple")
print(type(thistuple))

#list is a collection - ordered , changable, allow duplicates.
#tuple is a collection - ordered , unchangable, allow duplicates.
#set is a collection - unordered, unchangable, no duplicates.
#dictionary is a collection - oredered, changable, no duplicates