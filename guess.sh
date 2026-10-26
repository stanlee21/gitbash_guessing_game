#!/bin/bash

#---- define destination file so it saves properly
SCORE_FILE="score.txt"
#checking for too many arguements
if (( $# > 2 )); then
	echo "Error: Too many arguments. "
	echo "Usage: $0 [name] [easy|normal|hard]"
	exit 1
fi
name=$1

# Ensure a name is provided
if [[ -z "$name" ]]; then
    read -r -p "Enter your name: " name
fi

#------ Tracking time
start_time=$(date +%s)

level="${2,,}"
case "$level" in
	easy)
		MAX_RANGE=50
		MAX_ATTEMPT=-1
		LEVEL_NAME="easy" 
		;;
	normal)
		MAX_RANGE=100
		MAX_ATTEMPT=-1
		LEVEL_NAME="normal"
		;;
	hard)
		MAX_RANGE=1000
		MAX_ATTEMPT=7
		LEVEL_NAME="hard"
		;;
	*)
		level="normal"
		MAX_RANGE=100
		MAX_ATTEMPT=-1
		LEVEL_NAME="normal"
		;;
esac


echo "=========================================="
echo "WELCOME INFIDEL TO MY GUESSING GAME, $name!"
echo "PLAYER: $name | LEVEL: $LEVEL_NAME | RANGE: 1-$MAX_RANGE"
echo "===================================="

#informing the player that he has just a certain number of attempts
if (( MAX_ATTEMPT != -1 )); then
	echo "Listen! you have just '$MAX_ATTEMPT' attempts to guess the Number"
fi


#generating secret number.
number=$(( RANDOM % MAX_RANGE + 1 ))
guess=-1
count=0

while (( guess != number )); do

	#game over check
	if (( MAX_ATTEMPT != -1 && count >= MAX_ATTEMPT )); then
		echo "====================================================="
		echo "GAME OVER, You ran out of attempts"
		echo "the secret number is '$number': "
		exit 0
	fi

    read -r -p "Guess the random number: " guess

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

#---- success path, the user won!----
echo "CONGRATULATIONS, "$name"! You guessed the number "$number" in "$count" attempts. "


#----calculate end details after game is finishes.
end_time=$(date +"%Y-%m-%d %H:%M:%S")
seconds=$(date +%s)
duration=$(( seconds - start_time ))

# send details to file safely
echo "${name}|${LEVEL_NAME}|${start_time}|${end_time}|${count}|${duration} seconds" >> "$SCORE_FILE"
