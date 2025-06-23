#!/usr/bin/env python3
import hashlib
import secrets
import getpass

def generate_password_hash(password):
    """Generates a secure password hash using SHA256 and a salt."""
    salt = secrets.token_hex(16)  # Generate a random salt
    salted_password = salt + password  # Prepend salt to password
    hashed_password = hashlib.sha256(salted_password.encode('utf-8')).hexdigest()
    return f"sha256:{salt}:{hashed_password}"

if __name__ == "__main__":
    password = getpass.getpass("Enter the password: ")
    password_hash = generate_password_hash(password)
    print(password_hash)

