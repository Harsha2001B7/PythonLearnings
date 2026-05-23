firstList = ["apple", "banana", "cherry"]
secondList = firstList.copy()
print(secondList)


thirdList = list(secondList)
print(thirdList)

fourthList = thirdList[:]
print(fourthList)

print(id(firstList))
print(id(secondList))
print(id(thirdList))
print(id(fourthList))

