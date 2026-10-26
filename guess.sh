#!/bin/bash
name=$1

# Ensure a name is provided
if [[ -z "$name" ]]; then
    read -r -p "Enter your name: " name
fi

echo "WELCOME INFIDEL TO MY GUESSING GAME, $name!"
echo "===================================="
echo "I have selected a random number between 1 and 100. Try to guess it!"

number=$(( RANDOM % 100 + 1 ))
guess=-1
count=0

while (( guess != number )); do
    read -r -p "Guess the number if you can BETWEEN 1 & 100: " guess

    # 1. Check if input is empty
    if [[ -z "$guess" ]]; then
        echo "Enter a number, you absolute infidel!"
        continue # Use continue instead of exit so the game doesn't crash
    fi

    # 2. Check if input is a valid positive integer
    if [[ ! "$guess" =~ ^[0-9]+$ ]]; then
        echo "That isn't even a number! Use your brain, infidel!"
        continue
    fi

    # Increment count only for valid inputs
    count=$((count + 1))

    # 3. Numeric comparisons
    if (( guess > number )); then
        echo "LOL! Too high!"
    elif (( guess < number )); then
        echo "OH OH! Too low! Try again!"
    fi
done

echo "===================================="
echo "Congratulations, $name! You guessed the number $number in $count attempts."
