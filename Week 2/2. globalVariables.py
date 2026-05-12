x='Ammu'

def printName():
    print('Hello',x)

printName()

y = 'harsha'

def execute():
    global y 
    y = 'reddy'
    print(y)

execute()
print(y)