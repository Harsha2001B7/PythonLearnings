# ============================================================
# FILE: coffee_machine.py
# ============================================================
# PURPOSE: The 'brain' that coordinates everything.
# CoffeeMachine does NOT do the work itself — it delegates:
#   • Drink info?    → asks Menu
#   • Resources?     → asks CoffeeMaker
#   • Money?         → asks MoneyMachine
#
# OOP CONCEPT SHOWN: COMPOSITION — CoffeeMachine HAS-A Menu,
# HAS-A CoffeeMaker, and HAS-A MoneyMachine.
# This is 'has-a' relationships, NOT 'is-a' inheritance.
# Each component can be tested and changed independently.
# ============================================================
 
from menu         import Menu
from coffee_maker import CoffeeMaker
from money_machine import MoneyMachine
 
 
# ─── CLASS: CoffeeMachine ────────────────────────────────────────────────────
class CoffeeMachine:
 
    def __init__(self):
        # COMPOSITION: We create ONE instance of each helper class.
        # These are stored as instance variables on CoffeeMachine.
        self.menu          = Menu()          # Knows the drinks
        self.coffee_maker  = CoffeeMaker()   # Manages resources
        self.money_machine = MoneyMachine()  # Handles payments
        self.is_on         = True            # Machine power state
 
    def start(self):
        """Main loop — keeps the machine running until turned off.
 
        Input:  None
        Output: None (runs an infinite loop until self.is_on = False)
        """
        while self.is_on:
            options = self.menu.get_items()
            choice  = input(f'What would you like? ({options}): ').lower().strip()
 
            if choice == 'off':
                # SECRET admin command — shuts the machine down
                print('Shutting down the coffee machine. Goodbye!')
                self.is_on = False
 
            elif choice == 'report':
                # SECRET admin command — prints resource + money report
                self.coffee_maker.report()
                self.money_machine.report()
 
            else:
                # --- STEP 1: Find the drink on the menu ---
                drink = self.menu.find_drink(choice)
                if drink is None:
                    continue    # Unknown input — loop back to prompt
 
                # --- STEP 2: Check if machine has enough ingredients ---
                if not self.coffee_maker.is_resource_sufficient(drink):
                    continue    # Not enough ingredients — loop back
 
                # --- STEP 3: Collect and validate payment ---
                money = self.money_machine.process_coins()
                if not self.money_machine.make_payment(drink.cost, money):
                    continue    # Not enough money — loop back
 
                # --- STEP 4: All checks passed — make the drink! ---
                self.coffee_maker.make_coffee(drink)
