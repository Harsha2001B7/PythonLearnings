print(2 ** 100)         # 1267650600228229401496703205376

type(2 ** 100)   # <class 'int'>  (no overflow, no 'long')
 
# Operators
7 / 2     # 3.5     true division (always returns float)
7 // 2    # 3       floor division
7 % 2     # 1       modulo (remainder)
2 ** 8    # 256     exponent
divmod(17, 5)  # (3, 2)  → quotient and remainder together

###############################################

0.1 + 0.2          # 0.30000000000000004
0.1 + 0.2 == 0.3   # False
 
# Right way to compare floats
import math
math.isclose(0.1 + 0.2, 0.3)   # True
 
# When you need exact decimals (money), use Decimal
from decimal import Decimal
Decimal("0.1") + Decimal("0.2")  # Decimal('0.3')

###############################################

True + True       # 2     yes, really
True == 1         # True
isinstance(True, int)  # True
 
# Useful idiom: count True values

votes = [True, False, True, True, False]
sum(votes)        # 3

###############################################

x = None
if x is None:
    print("not set yet")
 
def greet(name=None):
    if name is None:
        name = "stranger"
    print(f"hi, {name}")
