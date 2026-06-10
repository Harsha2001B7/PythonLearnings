# ============================================================
# FILE: menu.py
# ============================================================
# PURPOSE: Defines the data/blueprint for drinks and ingredients.
# This file contains NO logic — only data. It answers the question:
# 'What drinks exist, and what do they cost/require?'
#
# OOP CONCEPT SHOWN: Classes as blueprints, __init__ (constructor),
# instance variables, and object creation.
# ============================================================
 
 
# ─── CLASS: MenuItem ─────────────────────────────────────────────────────────
# A class is a blueprint (like a cookie-cutter mold).
# MenuItem is the blueprint for a single drink option.
# Every drink (espresso, latte, cappuccino) is one OBJECT made from this blueprint.
class MenuItem:
 
    # __init__ is the CONSTRUCTOR: it runs automatically when we create a new object.
    # Think of it as the 'setup instructions' for every drink.
    # 'self' refers to the specific drink being created (the object, not the class).
    def __init__(self, name, water, milk, coffee, cost):
 
        # INSTANCE VARIABLES: These belong to THIS specific drink object.
        # Each drink gets its own private copy of these values.
        self.name   = name     # str  - e.g. 'espresso'
        self.cost   = cost     # float - e.g. 1.50
 
        # Ingredients grouped inside a dictionary for clean access
        self.ingredients = {
            "water":  water,   # int - millilitres needed
            "milk":   milk,    # int - millilitres needed
            "coffee": coffee,  # int - grams needed
        }
 
 
# ─── CLASS: Menu ─────────────────────────────────────────────────────────────
# Menu is the blueprint for the FULL drink menu.
# It creates and stores all available MenuItem objects.
class Menu:
 
    def __init__(self):
        # We CREATE three MenuItem OBJECTS here using the MenuItem blueprint above.
        # This is COMPOSITION: Menu HAS-A collection of MenuItems.
        self.menu = [
            MenuItem(name="espresso", water=50,  milk=0,   coffee=18, cost=1.50),
            MenuItem(name="latte",    water=200, milk=150, coffee=24, cost=2.50),
            MenuItem(name="cappuccino", water=250, milk=100, coffee=24, cost=3.00),
        ]
 
    def get_items(self):
        """Returns a string of all available drink names, e.g. 'espresso/latte/cappuccino'.
 
        Input:  None
        Output: str — drink names joined by '/'
        """
        return "/".join([item.name for item in self.menu])
 
    def find_drink(self, order_name):
        """Searches the menu list for a drink matching the user's order.
 
        Input:  order_name (str) — what the user typed
        Output: MenuItem object if found, None if not found
        """
        for item in self.menu:
            if item.name == order_name:
                return item        # Return the matching MenuItem object
        print(f'Sorry, "{order_name}" is not on the menu.')
        return None
