import random

user_wins = 0
computer_wins = 0

choices = ["Rock", "Paper", "Scissors"]

rules = {
    1: 3,
    2: 1,
    3: 2
}

def decide_winner(user_choice, computer_choice):

    if user_choice == computer_choice:
        return "Tie"

    if rules[user_choice] == computer_choice:
        return "User"

    return "Computer"


print("Let's play Rock Paper Scissors!")
print("First to 5 wins.\n")

while user_wins < 5 and computer_wins < 5:

    print("\n1. Rock")
    print("2. Paper")
    print("3. Scissors")
    print("q to Quit")

    user_choice = input("Choose: ").strip().lower()

    if user_choice == "q":
        print("Thank you for playing!")
        break

    if user_choice not in ["1", "2", "3"]:
        print("Invalid choice!")
        continue

    user_choice = int(user_choice)

    computer_choice = random.randint(1, 3)

    print(f"\nYou chose: {choices[user_choice - 1]}")
    print(f"Computer chose: {choices[computer_choice - 1]}")

    result = decide_winner(user_choice, computer_choice)

    if result == "User":
        user_wins += 1
        print("🎉 You won this round!")

    elif result == "Computer":
        computer_wins += 1
        print("💻 Computer won this round!")

    else:
        print("🤝 It's a tie!")

    print(f"Score -> You: {user_wins} | Computer: {computer_wins}")

print("\n================")

winner = "You" if user_wins == 5 else "Computer"

print(f"{winner} won the match!")
print("Thank you for playing.")