#!/bin/bash

#---- define destination file so it saves properly
SCORE_FILE="score.txt"

#counter for damaged lines
damaged_count=0

#beginner friendly checks for damaged lines
#--- reading each line field-by-field splitting by the symbol "|"
while IFS='|' read -r f1 f2 f3 f4 f5 f6 f7 || [[ -n "$f1" ]]; do

	#skipping empty lines without damaging them completely
	if [[ -z "$f1" && -z "$f2" ]]; then
		continue
	fi
	#--remove the word "seconds" from the 6th field to isolate the raw number
	remove_seconds=${f6%% *}

	# checking for curruptions using clear simple rules
	if [[ -n "$f7" ]] || \
		[[ -z "$f1" || -z "$f2" || -z "$f3" || -z "$f4" || -z "$f5" || -z "$f6" ]] || \
		[[ "$f2" != "easy" && "$f2" != "normal" && "$f2" != "hard" ]] || \
		[[ ! "$f5" =~ ^[0-9]+$ ]] || \
		[[ ! "$remove_seconds" =~ ^[0-9]+$ ]]; then
	
		#if any validation rule above fails, count it as damaged
		damaged_count=$((damaged_count + 1))
	fi

done < "$SCORE_FILE"

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

#warning message to tell the player if damaged lines exist
if (( damaged_count > 0 )); then
	echo "WARNING: $damaged_count damaged lines were skipped in the log"
fi

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
echo "CONGRATULATIONS, $name! You guessed the number $number in $count attempts. "


#----calculate end details after game is finishes.
end_time=$(date +"%Y-%m-%d %H:%M:%S")
seconds=$(date +%s)
duration=$(( seconds - start_time ))

# send details to file safely
echo "${name}|${LEVEL_NAME}|${start_time}|${end_time}|${count}|${duration} seconds" >> "$SCORE_FILE"

# history and combine summary engine
echo "=============================================================="
echo "			MATCH HISTORY				"
echo "=============================================================="

#initialize counter for summary calculations
total_games=0

#read out data line by line
while IFS='|' read -r h1 h2 h3 h4 h5 h6 h7 || [[ -n "$h1" ]]; do

	#ignore empty spaced lines
	if [[ -z "$h1" && -z "$h2" ]]; then
		continue
	fi

	#remove text "seconds" out to clean the number 
	remove_history_seconds=${h6%% *}

	#rule verification filter
	if [[ -n "$h7" ]] || \
       [[ -z "$h1" || -z "$h2" || -z "$h3" || -z "$h4" || -z "$h5" || -z "$h6" ]] || \
       [[ "$h2" != "easy" && "$h2" != "normal" && "$h2" != "hard" ]] || \
       [[ ! "$h5" =~ ^[0-9]+$ ]] || \
       [[ ! "$remove_history_seconds" =~ ^[0-9]+$ ]]; then
        continue # Instantly skip this damaged record
    fi

	#if it is valid, print the game entry showing the level
	echo "Player: $h1 | Level: $h2 | Attempts: $h5 | Time: $h6"

	# Increment the summary total counter (Combines all difficulty levels)
    total_games=$((total_games + 1))
done < "$SCORE_FILE"

echo "=================================================================="
echo "SUMMARY: Total valid games played across all levels = $total_games"
echo "=================================================================="