#! /bin/bash

# Check if .env exists, create it if not
touch .env

echo "Enter Private Key:"
read -s PRIVATE_KEY

# Check if PRIVATE_KEY already exists in .env
if grep -q "^PRIVATE_KEY=" .env; then
# Update existing key (using a different delimiter | in case key has /)
	sed -i "s|^PRIVATE_KEY=.*|PRIVATE_KEY=$PRIVATE_KEY|" .env
	echo "Updated PRIVATE_KEY in .env"
else
    # Append new key
    echo "PRIVATE_KEY=$PRIVATE_KEY" >> .env
    echo "Added PRIVATE_KEY to .env"
fi

# Clear the variable from the local shell session
unset PRIVATE_KEY