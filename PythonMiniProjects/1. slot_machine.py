import random

MAX_LINES = 3
MIN_BET = 1
MAX_BET = 100

ROWS = 3
COLS = 3

symbol_count = {
    "A": 2,
    "B": 4,
    "C": 6,
    "D": 8
}
symbol_values = {
    "A": 5,
    "B": 4,
    "C": 3,
    "D": 2
}

def check_winnings(columns, lines, bet, values):
    winings = 0
    wining_line = []
    for line in range(lines):
        symbol = columns[0][line]
        for column in columns:
            symbol_to_check = column[line]
            if symbol != symbol_to_check:
                break
        else:
            winings += values[symbol] * bet
            wining_line.append(line + 1)
    return winings, wining_line

        


def get_slot_machine_spin(rows,cols,symbols):
    all_symbols =[]
    for symbol, symbol_count in symbols.items():
        for _ in range(symbol_count):
            all_symbols.append(symbol)

    columns = []
    for _ in range(cols):
        column = []
        current_symbols = all_symbols[:]
        for _ in range(rows):
            value = random.choice(current_symbols)
            current_symbols.remove(value)
            column.append(value)
        columns.append(column)
    return columns

def print_slot_machine(columns):
    for row in  range(len(columns[0])):
        for i, column in enumerate(columns):
            if i!= len(columns)-1:
                print(column[row], end = " | ")
            else:
                print(column[row], end = "")

        print()


def deposit():
    while True:
        amount = input("How much would you like deposit? $")
        if amount.isdigit():
            amount = int(amount)
            if amount > 0:
                break
            else:
                print("Amount must be greater than Zero!!")
        else:
            print("Please Enter a Valid Number")
    return amount

def get_number_of_lines():
    while True:
        lines = input("How many number's would you like to bet on? (1 - "+str(MAX_LINES)+" )? ")
        if lines.isdigit():
            lines = int(lines)
            if 1<= lines <= MAX_LINES:
                break
            else:
                print("Enter valid number of lines to bet on. ")
        else:
            print("Please Enter a valid number")
    return lines  

def get_bet():
    while True:
        amount = input("How much would you like to bet on each line? $ ")
        if amount.isdigit():
            amount = int(amount)
            if MIN_BET<= amount <= MAX_BET:
                break
            else:
                print(f"Amount must be between ${MIN_BET} - ${MAX_BET}.")
        else:
            print("Please Enter a valid amount")
    return amount    

def spin(balance):
    lines = get_number_of_lines()
    while True:
        bet = get_bet()
        total_bet = bet * lines

        if total_bet > balance:
            print(f"You do not have enough balance to bet that amount, Your current balance is ${balance}")
        else:
            break
       
    print(f"You are betting ${bet} on {lines} lines. Total bet amount is ${total_bet}")

    slots = get_slot_machine_spin(ROWS,COLS,symbol_count)
    print_slot_machine(slots)
    winings,winings_lines = check_winnings(slots,lines,bet,symbol_values)
    if winings == 0:
        print("Opps! you lost better luck next time.")
    else:
        print(f"You won ${winings}")
        print(f"You won on lines: ", *winings_lines)
    return winings - total_bet


def main():
    balance = deposit()
    while True:
        if balance == 0:
            print(f"Your wallet is empty! Press (Y) if you want to add balance or Press any key to quit")
            answer = input()
            if answer.lower() == 'y':
                # main()
                balance += deposit()
                continue
            else:
                break
        print(f"Current balance is ${balance}")
        answer = input("Press enter to play (q to quit).")
        if answer == "q":
            break
        balance += spin(balance)
        


    print(f"You left with {balance}")


main()

