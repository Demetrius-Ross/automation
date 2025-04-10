import os
import getpass
import json
from encrypt_credentials import encrypt_credentials
from auto_login import decrypt_credentials, login_with_selenium
from cryptography.fernet import InvalidToken

CREDENTIAL_FILE = "credentials.enc"

def prompt_action():
    print("\nChoose an action:")
    print("1. Set up credentials")
    print("2. Change credentials (requires PIN)")
    print("3. Log in to QMS")
    print("4. Exit")
    return input("Enter your choice: ").strip()

def try_get_credentials():
    for attempt in range(3):
        pin = getpass.getpass("Enter your personal PIN: ")
        try:
            creds = decrypt_credentials(pin)
            return pin, creds
        except InvalidToken:
            print("Incorrect PIN. Try again.")
    print("Too many incorrect attempts.")
    return None, None

def setup_credentials():
    pin = getpass.getpass("Set a new personal PIN: ")
    username = input("Enter your username: ")
    password = getpass.getpass("Enter your password: ")
    encrypt_credentials(pin, username, password)
    print("Credentials saved successfully.")

def main():
    print("=== QMS Auto Login ===")

    if not os.path.exists(CREDENTIAL_FILE):
        print("No credentials found. Please set them up.")
        setup_credentials()

    while True:
        choice = prompt_action()

        if choice == "1":
            if os.path.exists(CREDENTIAL_FILE):
                print("Credentials already exist.")
            else:
                setup_credentials()

        elif choice == "2":
            pin, _ = try_get_credentials()
            if pin:
                setup_credentials()

        elif choice == "3":
            pin, creds = try_get_credentials()
            if creds:
                login_with_selenium(creds["username"], creds["password"])

        elif choice == "4":
            print("Goodbye!")
            break

        else:
            print("Invalid choice. Please enter 1-4.")

if __name__ == "__main__":
    main()
