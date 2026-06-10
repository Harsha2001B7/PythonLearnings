# ============================================================
# FILE: money_machine.py
# ============================================================
# PURPOSE: Handles all financial logic for the coffee machine.
# This class knows about coins, their values, profit tracking,
# and whether a transaction is valid.
#
# SINGLE RESPONSIBILITY: MoneyMachine only cares about money.
# It does NOT know what a drink tastes like or how to make it.
# It does NOT manage water or milk levels.
#
# OOP CONCEPT SHOWN: Encapsulation — profit and coin logic are
# hidden inside this class. The outside world just calls
# process_coins() and make_payment(), without knowing internals.
# ============================================================
 
 
# ─── CLASS: MoneyMachine ─────────────────────────────────────────────────────
class MoneyMachine:
 
    # CLASS VARIABLE: shared by ALL MoneyMachine objects (if you made many).
    # Coin denominations never change — so it lives at class level, not instance.
    COIN_VALUES = {
        "quarters": 0.25,
        "dimes":    0.10,
        "nickels":  0.05,
        "pennies":  0.01,
    }
 
    def __init__(self):
        # INSTANCE VARIABLE: This machine's accumulated profit.
        # Each machine object gets its own profit counter.
        self.profit = 0.0
 
    def report(self):
        """Prints the total money earned by the machine.
 
        Input:  None
        Output: None (side effect: prints to screen)
        """
        print(f"Money: ${self.profit:.2f}")
 
    def process_coins(self):
        """Asks the user to insert coins and calculates the total inserted amount.
 
        Input:  None (reads from user input)
        Output: float — total amount of money the user inserted
        """
        print("Please insert coins.")
        total = 0.0
        for coin, value in self.COIN_VALUES.items():
            # Ask how many of each coin type was inserted
            count = int(input(f'How many {coin}?: '))
            total += count * value
        return total
 
    def make_payment(self, cost, money_received):
        """Validates whether the user paid enough, calculates change,
        and adds the drink cost to the machine's profit.
 
        Input:  cost (float)           — price of the selected drink
                money_received (float) — total coins inserted by user
        Output: bool — True if payment succeeds, False if insufficient
        """
        if money_received >= cost:
            change = round(money_received - cost, 2)
            if change > 0:
                print(f'Here is ${change:.2f} in change.')
            self.profit += cost   # Only the drink's cost goes into profit
            return True
        else:
            print('Sorry that\'s not enough money. Money refunded.')
            return False
