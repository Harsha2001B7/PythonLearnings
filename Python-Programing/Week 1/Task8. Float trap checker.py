"""
8. Float trap checker
Build a small program that demonstrates the 0.1+0.2 problem and shows the right way to compare floats using math.isclose.
numbers
Output:
0.1 + 0.2 = 0.30000000000000004
0.1 + 0.2 == 0.3 → False
math.isclose() → True
Safe for money? Use Decimal:
Decimal('0.1') + Decimal('0.2') = 0.3
"""

import math
from decimal import Decimal

a = 0.1 + 0.2
print(f"0.1 + 0.2 = {a}")
print(f"0.1 + 0.2 == 0.3 → {a == 0.3}")
print(f"math.isclose() → {math.isclose(a, 0.3)}")
print(f"Safe for money? Use Decimal:")
print(f"Decimal('0.1') + Decimal('0.2') = {Decimal('0.1') + Decimal('0.2')}")