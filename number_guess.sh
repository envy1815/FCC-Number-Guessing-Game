#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

# Check if the username exists
USERNAME_AVAIL=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")
# Count the number of games played by the user
GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM users INNER JOIN games USING(user_id) WHERE username = '$USERNAME'")
# Get the best game (minimum number of guesses)
BEST_GAME=$($PSQL "SELECT MIN(number_guesses) FROM users INNER JOIN games USING(user_id) WHERE username = '$USERNAME'")

if [[ -z $USERNAME_AVAIL ]]; then
  # Insert new user if username is not found
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generate a random number between 1 and 1000
RANDOM_NUM=$((1 + RANDOM % 1000))
GUESS=1
echo "Guess the secret number between 1 and 1000:"

while read NUM; do
  # Check if the input is an integer
  if [[ ! $NUM =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
  else
    if [[ $NUM -eq $RANDOM_NUM ]]; then
      break
    else
      if [[ $NUM -gt $RANDOM_NUM ]]; then
        echo -n "It's lower than that, guess again: "
      else
        echo -n "It's higher than that, guess again: "
      fi
    fi
  fi
  GUESS=$((GUESS + 1))
done

# Output the result of the guessing game
if [[ $GUESS -eq 1 ]]; then
  echo "You guessed it in $GUESS try. The secret number was $RANDOM_NUM. Nice job!"
else
  echo "You guessed it in $GUESS tries. The secret number was $RANDOM_NUM. Nice job!"
fi

# Get the user_id for the current user
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
# Insert the game result into the games table
INSERT_GAME=$($PSQL "INSERT INTO games(number_guesses, user_id) VALUES($GUESS, $USER_ID)")