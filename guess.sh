#!/bin/bash
name=$1
if [[ -z "$name" ]]; then
    read -r -p "Enter your name: " name
    # echo " Usage: ./guess.sh <name> where name is your name" 
fi

echo "Hello, $name! I have selected a random number between 1 and 100. Try to guess it!"

echo "WELCOME INFIDEL TO MY GUESSING GAME"
echo "===================================="

number=$(( RANDOM % 100 + 1 ))
guess=-1
count=0



while (( "$guess" != number )); do
	read -r -p "Guess the number if you can BETWEEN 1 & 100: " guess

if [[ -z "$guess" ]]; then
	echo "Enter a number you infidel"
	exit 1;
elif (( "$guess" > number )); then
	echo "LOL! too high"
elif (( "$guess" < number )); then
	echo "OH OH! too low, Try again"
fi
count=$((count + 1))
done

echo "Congratulations! You guessed the number $number in $count attempts."

