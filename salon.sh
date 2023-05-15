#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ My Salon ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  
  GET_SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")
  
  echo "$GET_SERVICES" | while read ID BAR NAME
  do
    echo -e "$ID) $NAME" 
  done
  read SERVICE_ID_SELECTED
  SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  # if service not found
  if [[ -z $SERVICE ]]
  then
    # wrong entry
    echo "I could not find that service. What would you like today?"
    MAIN_MENU
  else
    # check customer records
    CUS_RECORDS
  fi
}


CUS_RECORDS(){
  echo -e "What's your phone number?"
  read CUSTOMER_PHONE
  # get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  # check customer name for that phone
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  # if number not fount
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "I don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    # update table customers
    INSERT_CUSTOMERS_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi
  # get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  MAKE_APPOINTMENT  
}

MAKE_APPOINTMENT(){
  
  echo -e "What time would you like your $SERVICE, $CUSTOMER_NAME?"

  read SERVICE_TIME
  # update table appointments
  INSERT_APPOINTMENT_RESULTS=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
  echo -e "I have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
  
}

MAIN_MENU
