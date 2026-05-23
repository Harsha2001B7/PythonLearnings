myTuple = (1,2,3)
myList = list(myTuple)
myList[0] = 100
myTuple = tuple(myList)
print(myTuple)