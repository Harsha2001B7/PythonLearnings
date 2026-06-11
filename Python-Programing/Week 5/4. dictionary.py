thisdict = {
  "brand": "Ford",
  "model": "Mustang",
  "year": 1964,
  "year": 1968
}
# print(thisdict)

car = {
"brand": "Ford",
"model": "Mustang",
"year": 1964
}

x = car.keys()

print(x) #before the change

car["color"] = "white"

print(x) #after the change

x = thisdict.items()

print(x)