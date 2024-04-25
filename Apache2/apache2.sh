#!/bin/bash

# Function to display help message
function display_help {
    echo "Usage: $0 [--mysqlpass <password>]"
    echo "  --mysqlpass <password>  Set MySQL root password"
    exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        --mysqlpass)
        MYSQL_PASSWORD="$2"
        shift
        ;;
        -h|--help)
        display_help
        ;;
        *)
        # Unknown option
        ;;
    esac
    shift
done

# Check if MySQL password is provided
if [ -z "$MYSQL_PASSWORD" ]; then
    echo "Error: MySQL password not provided."
    display_help
fi

# Install Apache2
sudo apt update && sudo apt install apache2 -y
sudo ufw allow in "Apache"

# Check if Apache is running
if ! curl -s http://127.0.0.1 >/dev/null; then
    echo "Just Installed Apache but something is wrong."
    exit 1
fi

# Install MySQL
sudo apt install mysql-server -y

# Configure MySQL
sudo mysql <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$MYSQL_PASSWORD';
exit
EOF

# Secure MySQL installation
sudo mysql_secure_installation

# Install PHP
sudo apt install php libapache2-mod-php php-mysql -y
