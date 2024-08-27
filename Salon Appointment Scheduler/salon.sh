#! /bin/bash

# Function to display services
display_services() {
  echo -e "\nAvailable Services:"
  psql --username=freecodecamp --dbname=salon -t --no-align -c "SELECT service_id, name FROM services" | while IFS="|" read SERVICE_ID NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
}

# Prompt for service selection
service_selection() {
  display_services
  echo -e "\nPlease select a service:"
  read SERVICE_ID_SELECTED

  # Check if service exists
  SERVICE_NAME=$(psql --username=freecodecamp --dbname=salon -t --no-align -c "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_NAME ]]
  then
    echo -e "\nInvalid service ID. Please try again."
    service_selection
  fi
}

# Start of the script
echo -e "\nWelcome to the Salon!"

service_selection

# Get customer details
echo -e "\nEnter your phone number:"
read CUSTOMER_PHONE

CUSTOMER_NAME=$(psql --username=freecodecamp --dbname=salon -t --no-align -c "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

if [[ -z $CUSTOMER_NAME ]]
then
  echo -e "\nEnter your name:"
  read CUSTOMER_NAME
  psql --username=freecodecamp --dbname=salon -c "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')"
fi

# Get appointment time
echo -e "\nEnter the time of your appointment:"
read SERVICE_TIME

CUSTOMER_ID=$(psql --username=freecodecamp --dbname=salon -t --no-align -c "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

# Insert appointment
psql --username=freecodecamp --dbname=salon -c "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')"

echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
