#! /bin/bash
echo -e "\n~~~~~ MY SALON ~~~~~\n"
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# Welcome message
echo -e "Welcome to My Salon, how can I help you?\n"

DISPLAY_SERVICES(){
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES" | while read ID BAR SERVICE
  do
    echo -e "$ID) $SERVICE"
  done
}

SALON(){
  # Display services
  DISPLAY_SERVICES
  
  # Select service
  read SERVICE_ID_SELECTED
  GET_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED" | sed -E 's/^\s+|\s+$//g')
  
  if [[ -z $GET_SERVICE ]]; then
    echo -e "\nI could not find that service. What would you like today?"
    SALON
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    
    # Get customer ID
    GET_USER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'" | sed -E 's/^\s+|\s+$//g')
    
    # If customer doesn't exist, add them
    if [[ -z $GET_USER_ID ]]; then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      ADD_USER=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
      GET_USER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'" | sed -E 's/^\s+|\s+$//g')
    else
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'" | sed -E 's/^\s+|\s+$//g')
    fi
    
    # Get appointment time
    echo -e "\nWhat time would you like your $GET_SERVICE, $CUSTOMER_NAME?"
    read SERVICE_TIME
    
    # Insert appointment
    ADD_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($GET_USER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    
    # Confirm appointment
    echo -e "\nI have put you down for a $GET_SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
    return
  fi
}

SALON
