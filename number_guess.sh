#!/bin/bash
RANDOM_NUMBER=$((1 + RANDOM % 1000))

PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

echo -e "\nEnter your username:"
read USERNAME

USER_INFO=$($PSQL "SELECT * FROM users WHERE username='$USERNAME'")

if [[ -z $USER_INFO ]]
then
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  if [[ $INSERT_USER_RESULT == "INSERT 0 1" ]]
  then
    USER_INFO=$($PSQL "SELECT * FROM users WHERE username='$USERNAME'")
  fi
else
  GAME_INFO=$($PSQL "SELECT COUNT(game_id) AS games_played, MIN(number_of_guesses) AS best_game FROM games LEFT JOIN users ON games.user_id = users.user_id WHERE username='$USERNAME'")
  echo $GAME_INFO | while read GAMES_PLAYED BAR BEST_GAME
  do
    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

GUESSED_TIMES=0
GUESSED_NUMBER=0

echo -e "\nGuess the secret number between 1 and 1000:"

while [[ $GUESSED_NUMBER != $RANDOM_NUMBER ]]
do
  read GUESSED_NUMBER
  if ! [[ $GUESSED_NUMBER =~ ^[0-9]+$ ]]
  then
    echo -e "\nThat is not an integer, guess again:"
  elif [[ $GUESSED_NUMBER -gt $RANDOM_NUMBER ]]
  then
    echo -e "\nIt's lower than that, guess again:"
  elif [[ $GUESSED_NUMBER -lt $RANDOM_NUMBER ]]
  then
    echo -e "\nIt's higher than that, guess again:"
  fi

  GUESSED_TIMES=$(( $GUESSED_TIMES + 1 ))

  if [[ $GUESSED_NUMBER == $RANDOM_NUMBER ]]
  then
    echo -e "\nYou guessed it in $GUESSED_TIMES tries. The secret number was $RANDOM_NUMBER. Nice job!"
  fi
done

echo $USER_INFO | while read USER_ID BAR USERNAME
do
  INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, number_of_guesses) VALUES($USER_ID, $GUESSED_TIMES)")
done
