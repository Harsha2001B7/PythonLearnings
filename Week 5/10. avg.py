
import math
import os
import random
import re
import sys



class Item:
    def __init__(self,name,price):
        self.name = name
        self.price = price


class ShoppingCart:
    def __init__(self):
        self.items = []
    
    def add(self, item):
        self.items.append(item)
    
    def total(self):
        return sum(item.price for item in self.items)
    
    def __len__(self):
        return len(self.items)


if __name__ == '__main__':

    n = int(input())
    items: list[Item] = []
    for _ in range(n):
        name, price = input().split()
        item = Item(name, int(price))
        items.append(item)

    cart = ShoppingCart()

    q = int(input())
    for _ in range(q):
        line = input().split()
        command, params = line[0], line[1:]
        if command == "len":
            print(len(cart))
        elif command == "total":
            print(cart.total())
        elif command == "add":
            name = params[0]
            item = next(item for item in items if item.name == name)
            cart.add(item)
        else:
            raise ValueError("Unknown command %s" % command)
            
