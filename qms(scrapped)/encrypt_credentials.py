from cryptography.fernet import Fernet
import base64
import hashlib
import json
import getpass

def get_key_from_pin(pin: str) -> bytes:
    hash = hashlib.sha256(pin.encode()).digest()
    return base64.urlsafe_b64encode(hash)

def encrypt_credentials(pin: str, username: str, password: str):
    key = get_key_from_pin(pin)
    fernet = Fernet(key)
    creds = json.dumps({"username": username, "password": password}).encode()
    encrypted = fernet.encrypt(creds)
    with open("credentials.enc", "wb") as file:
        file.write(encrypted)
    print("Credentials encryped and saved to 'credentials.enc'.")

if __name__ == "__main__":
    pin = getpass.getpass("Enter your personal PIN: ")
    username = input("Enter your username: ")
    password = getpass.getpass("Enter your password: ")
    encrypt_credentials(pin, username, password)