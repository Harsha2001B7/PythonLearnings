mylist = [1,2,3,4,5,6]
newList = []
print(mylist)
size = len(mylist)-1
print(size)

for i in range(size+1):
    newList.append(mylist[size])
    size -= 1
print(newList)
