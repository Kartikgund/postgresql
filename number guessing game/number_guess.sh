#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Prompt for username
echo "Enter your username:"
read USERNAME

# Check if user exists
USER_EXISTS=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER_EXISTS ]]
then
  # New user
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  $PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, 1000)" > /dev/null
else
  # Existing user
  echo $USER_EXISTS | while IFS="|" read NAME GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

# Generate secret number
SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))
echo "Guess the secret number between 1 and 1000:"
NUMBER_OF_GUESSES=0

# Guessing loop
while true
do
  read GUESS

  if ! [[ $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    ((NUMBER_OF_GUESSES++))

    if [[ $GUESS -eq $SECRET_NUMBER ]]
    then
      echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
      break
    elif [[ $GUESS -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi
  fi
done

# Update user stats
USER_STATS=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")
echo $USER_STATS | while IFS="|" read GAMES_PLAYED BEST_GAME
do
  NEW_GAMES_PLAYED=$((GAMES_PLAYED + 1))
  if [[ $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
  then
    $PSQL "UPDATE users SET games_played=$NEW_GAMES_PLAYED, best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME'" > /dev/null
  else
    $PSQL "UPDATE users SET games_played=$NEW_GAMES_PLAYED WHERE username='$USERNAME'" > /dev/null
  fi
done
