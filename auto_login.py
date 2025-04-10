import requests
import json
import getpass
from cryptography.fernet import Fernet
import base64
import hashlib
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.edge.service import  Service as EdgeService
from selenium.webdriver.edge.options import Options as EdgeOptions
from webdriver_manager.microsoft import EdgeChromiumDriverManager
import time


def get_key_from_pin(pin: str) -> bytes:
    hash = hashlib.sha256(pin.encode()).digest()
    return base64.urlsafe_b64encode(hash)

def decrypt_credentials(pin: str) -> dict:
    key = get_key_from_pin(pin)
    fernet = Fernet(key)
    with open("credentials.enc", "rb") as file:
        encryped = file.read()
    decrypted = fernet.decrypt(encryped)
    return json.loads(decrypted.decode())

def login_with_selenium(username, password):
    options = EdgeOptions()
    options.add_argument("--new-window")
    options.add_argument(r"user-data-dir=C:\Users\p00802830\AppData\Local\Microsoft\Edge\User Data\AutomationProfile")
    service = EdgeService(EdgeChromiumDriverManager().install())
    driver = webdriver.Edge(service=service, options=options)
    driver.get("https://qms.prismesolutions.net/index.cfm?useraction=login")
    time.sleep(0.5)
    driver.find_element(By.NAME, "login_name").send_keys(username)
    driver.find_element(By.NAME, "password").send_keys(password)
    driver.find_element(By.NAME, "Login").click()


    print("Login attempted: Check broswer to confirm")
    input("Press enter to close browser...")
    driver.quit()


if __name__ == "__main__":
    pin = getpass.getpass("Enter your personal PIN: ")
    creds =decrypt_credentials(pin)
    login_with_selenium(creds["username"], creds["password"])
    #open_browser_with_sessions(session, "https://qms.prismesolutions.net/")