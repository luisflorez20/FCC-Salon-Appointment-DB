#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
    if [[ $1 ]]
    then
        echo -e "\n$1"
    fi

    echo -e "Welcome to My Salon, how can I help you?\n"
    
    # Obtener servicios
    SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
    echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
    do
        echo "$SERVICE_ID) $SERVICE_NAME"
    done

    read SERVICE_ID_SELECTED
    
    # Validar servicio
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    
    if [[ -z $SERVICE_NAME ]]
    then
        MAIN_MENU "I could not find that service. What would you like today?"
    else
        # Obtener teléfono
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE
        
        # Verificar cliente
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        
        if [[ -z $CUSTOMER_ID ]]
        then
            # Cliente nuevo
            echo -e "\nI don't have a record for that phone number, what's your name?"
            read CUSTOMER_NAME
            
            # Insertar cliente
            INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
            CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        else
            # Cliente existente
            CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        fi
        
        # Obtener hora
        echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
        read SERVICE_TIME
        
        # Insertar cita
        INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
        
        # Mostrar mensaje final
        SERVICE_NAME_CLEAN=$(echo $SERVICE_NAME | sed -r 's/^ *| *$//g')
        CUSTOMER_NAME_CLEAN=$(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')
        echo -e "\nI have put you down for a $SERVICE_NAME_CLEAN at $SERVICE_TIME, $CUSTOMER_NAME_CLEAN."
    fi
}

MAIN_MENU
