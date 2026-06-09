from cryptography.fernet import Fernet

# ==========================================
# CONSTANTS
# ==========================================

FILE_PATH = r"C:\Users\renuk\PythonLearnings\Documents\passwords.txt"
KEY_PATH = r"C:\Users\renuk\PythonLearnings\Documents\key.key"

# ==========================================
# LOAD ENCRYPTION KEY
# ==========================================

def load_key():
    """
    Reads the encryption key from disk.

    rb = Read Binary

    Returns bytes.
    """

    with open(KEY_PATH, "rb") as f:
        return f.read()


# Create Fernet object once and reuse it.
fer = Fernet(load_key())


# ==========================================
# ADD PASSWORD
# ==========================================

def add_password():

    username = input("Enter Username: ")
    password = input("Enter Password: ")

    # Encrypt password
    encrypted_password = fer.encrypt(
        password.encode()
    ).decode()

    with open(FILE_PATH, "a") as f:
        f.write(
            f"{username}|{encrypted_password}\n"
        )

    print("Password added successfully!")


# ==========================================
# VIEW PASSWORDS
# ==========================================

def view_passwords():

    try:

        with open(FILE_PATH, "r") as f:

            for line in f:

                username, encrypted_password = (
                    line.rstrip().split("|")
                )

                decrypted_password = (
                    fer.decrypt(
                        encrypted_password.encode()
                    ).decode()
                )

                print(
                    f"Username: {username}"
                )
                print(
                    f"Password: {decrypted_password}"
                )
                print("-" * 30)

    except FileNotFoundError:
        print("No passwords stored yet.")


# ==========================================
# MAIN LOOP
# ==========================================

while True:

    response = input(
        "\nadd  - Add Password\n"
        "view - View Passwords\n"
        "q    - Quit\n\n"
        "Choose: "
    ).lower()

    if response == "add":
        add_password()

    elif response == "view":
        view_passwords()

    elif response == "q":
        print("Goodbye!")
        break

    else:
        print("Invalid option.")