def deposit():
    while True:
        amount = input("How much would you like deposit? $")
        if amount.isdigit():
            amount = int(amount)
            if amount > 0:
                break
            else:
                print("Amount must be greater than Zero!!")
        else :
            print("Please Enter a Valid Number")
    return amount