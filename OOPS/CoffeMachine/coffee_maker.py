# ============================================================
# FILE: coffee_maker.py
# ============================================================
# PURPOSE: Manages the physical machine — its ingredients and
# the process of actually making a drink.
#
# SINGLE RESPONSIBILITY: CoffeeMaker only cares about resources.
# It does NOT handle money. It does NOT talk to the menu directly.
# It just checks if it CAN make a drink and then MAKES it.
#
# OOP CONCEPT SHOWN: Encapsulation — the resource data and the
# methods that act on that data are bundled TOGETHER inside one class.
# ============================================================
 
 
# ─── CLASS: CoffeeMaker ──────────────────────────────────────────────────────
class CoffeeMaker:
 
    def __init__(self):
        # INSTANCE VARIABLES: The machine's current resource levels.
        # These are ENCAPSULATED — only CoffeeMaker methods change them.
        self.resources = {
            "water":  300,  # millilitres
            "milk":   200,  # millilitres
            "coffee": 100,  # grams
        }
 
    def report(self):
        """Prints the current resource levels to the console.
 
        Input:  None
        Output: None (side effect: prints to screen)
        """
        print(f"Water:  {self.resources['water']}ml")
        print(f"Milk:   {self.resources['milk']}ml")
        print(f"Coffee: {self.resources['coffee']}g")
 
    def is_resource_sufficient(self, drink):
        """Checks whether the machine has enough ingredients to make the drink.
 
        Input:  drink (MenuItem) — the drink the user wants
        Output: bool — True if all ingredients are available, False if any is short
        """
        # Loop through each ingredient needed for this drink
        for ingredient, amount_needed in drink.ingredients.items():
            if self.resources[ingredient] < amount_needed:
                print(f'Sorry there is not enough {ingredient}.')
                return False   # Stop checking as soon as one is insufficient
        return True            # All ingredients are available
 
    def make_coffee(self, drink):
        """Deducts the drink's ingredients from the machine's resources
        and announces the completed drink.
 
        Input:  drink (MenuItem) — the drink to make
        Output: None (side effect: prints to screen, updates self.resources)
        """
        for ingredient, amount_used in drink.ingredients.items():
            self.resources[ingredient] -= amount_used   # Deduct used ingredients
        print(f"Here is your {drink.name}. Enjoy! ☕")
