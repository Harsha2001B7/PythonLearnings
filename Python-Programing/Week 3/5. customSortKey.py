def customSort (n):
    return abs(n-50)

myList = [20,30,40,50,60,70,80]
myList.sort(key=customSort)
print(myList)