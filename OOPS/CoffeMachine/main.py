# ============================================================
# FILE: main.py
# ============================================================
# PURPOSE: The entry point of the entire program.
# This is the ONLY file you run directly: python main.py
#
# It creates ONE CoffeeMachine OBJECT and calls start().
# All the complexity is hidden behind that single call.
# ============================================================
 
from coffee_machine import CoffeeMachine
 
# Create an OBJECT from the CoffeeMachine CLASS.
# This triggers CoffeeMachine.__init__() which sets everything up.
machine = CoffeeMachine()
 
# Start the machine — this runs the main loop.
machine.start()
