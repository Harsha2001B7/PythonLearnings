import random
import time

print("Welcome to Guess Number!!! ")
print("Spinning",end="",flush=True)

for _ in range(3):
    time.sleep(1.5)
    print(".",end="",flush=True)

randomNumber = random.randint(1,10)


while True:
    userNumber = input("\nEnter your Guess (1-10): ")
    if userNumber.isnumeric():
        userNumber = int(userNumber)
        if userNumber == randomNumber:
            print("You're Correct! Thanks for Playing :)")
            break
        elif userNumber < randomNumber:
            print("Try Higher!!")
        else:
            print("Try Lower!!")
    else:
        print("Please Enter a valid number!")