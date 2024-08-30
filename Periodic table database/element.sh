#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Check if argument is provided
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit
fi

# Determine if input is a number (atomic number) or string (symbol/name)
if [[ $1 =~ ^[0-9]+$ ]]
then
  # Input is an atomic number
  ELEMENT=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius 
                   FROM elements 
                   INNER JOIN properties USING(atomic_number) 
                   INNER JOIN types USING(type_id) 
                   WHERE atomic_number = $1")
else
  # Input is a symbol or name (enclose in single quotes for SQL)
  ELEMENT=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius 
                   FROM elements 
                   INNER JOIN properties USING(atomic_number) 
                   INNER JOIN types USING(type_id) 
                   WHERE symbol = '$1' OR name = '$1'")
fi

# Check if element exists
if [[ -z $ELEMENT ]]
then
  echo "I could not find that element in the database."
else
  # Display element information
  echo $ELEMENT | while IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELT BOIL
  do
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
  done
fi
