#!/bin/bash

#---- define destination file so it saves properly
SCORE_FILE="score.txt"

# Ensure the file exists so the loops don't error out on a fresh run
touch "$SCORE_FILE"

# Check if the correct number of arguments was provided
if (( $# < 1 || $# > 2 )); then
    echo "Error: Invalid number of arguments."
    echo "Usage: $0 name [easy|normal|hard]"
    exit 1
fi

# Get the player's name
name=$1

# Validate the player's name
if [[ -z "$name" || "$name" == *"|"* ]]; then
    echo "Error: Invalid player name."
    echo "Usage: $0 name [easy|normal|hard]"
    exit 1
fi

# DIFFICULTY LEVEL VALIDATION
# ==========================================

level="${2:-normal}"
level="${level,,}"

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
        MAX_ATTEMPT=-1
        LEVEL_NAME="hard"
        ;;

    *)
        echo "Error: Invalid difficulty level."
        echo "Usage: $0 name [easy|normal|hard]"
        exit 1
        ;;
esac

# SCORE RECORD VALIDATION
# ==========================================

valid_record() {
    local player="$1"
    local game_level="$2"
    local start="$3"
    local end="$4"
    local attempts="$5"
    local seconds="$6"
    local extra="$7"

    # Check that all six required fields exist
    [[ -n "$player" && -n "$game_level" && -n "$start" &&
       -n "$end" && -n "$attempts" && -n "$seconds" ]] || return 1

    # Reject records containing extra fields
    [[ -z "$extra" ]] || return 1

    # Check valid difficulty
    [[ "$game_level" == "easy" || "$game_level" == "normal" ||
       "$game_level" == "hard" ]] || return 1

    # Check readable date-time format
    [[ "$start" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}:[0-9]{2}$ ]] || return 1
    [[ "$end" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}:[0-9]{2}$ ]] || return 1

    # Check that attempts and seconds are numeric
    [[ "$attempts" =~ ^[0-9]+$ ]] || return 1
    [[ "$seconds" =~ ^[0-9]+$ ]] || return 1

    return 0
}

#  MAIN INTERACTIVE MENU LOOP
# =========================================================================
while true; do
	# Recalculate damaged lines dynamically on every menu loop refresh
	damaged_count=0

	while IFS='|' read -r f1 f2 f3 f4 f5 f6 f7 || [[ -n "$f1" ]]; do

		# Ignore completely empty lines
		if [[ -z "$f1" && -z "$f2" ]]; then
			continue
		fi

		# Count records that fail validation
		if ! valid_record "$f1" "$f2" "$f3" "$f4" "$f5" "$f6" "$f7"; then
			damaged_count=$((damaged_count + 1))
		fi

	done < "$SCORE_FILE"

	# Display Header exactly matching format
	echo ""
	echo "=== GUESS THE NUMBER · Player: $name · Level: $LEVEL_NAME (1-$MAX_RANGE) ==="
	if (( damaged_count > 0 )); then
		echo "Warning: $damaged_count damaged line(s) in the games file were skipped."
	fi

	# Display formal option index structure
	echo "1) Play"
	echo "2) My history"
	echo "3) Leaderboard"
	echo "4) Delete my history"
	echo "5) Quit"
	read -r -p "Choose: " CHOSEN_OPTION

	case "$CHOSEN_OPTION" in
		1)
			# ------------------------------------
			#  1) PLAY GAME MODE
			# ------------------------------------
			start_time=$(date +"%Y-%m-%d %H:%M:%S")
			start_epoch=$(date +%s)

			if (( MAX_ATTEMPT != -1 )); then
				echo "Listen! you have just '$MAX_ATTEMPT' attempts to guess the Number"
			fi

			number=$(( RANDOM % MAX_RANGE + 1 ))
			guess=-1
			count=0
			quit_game=0

			while (( guess != number )); do
				if (( MAX_ATTEMPT != -1 && count >= MAX_ATTEMPT )); then
					echo "====================================================="
					echo "GAME OVER, You ran out of attempts"
					echo "the secret number is '$number': "
					break
				fi

				read -r -p "Guess the random number: " guess

				if [[ "$guess" == "q" || "$guess" == "Q" ]]; then
					echo "Game cancelled. Returning to menu..."
					quit_game=1
					break
				fi

				if [[ -z "$guess" ]]; then
					echo "Please Enter a number"
					continue 
				fi

				if [[ ! "$guess" =~ ^[0-9]+$ ]]; then
					echo "Invalid input, please Enter a whole number."
					continue
				fi

				count=$((count + 1))

				if (( guess > number )); then
					echo "Too high! Try again."
				elif (( guess < number )); then
					echo "Too low! Try again."
				fi
			done

			if (( quit_game == 0 )) && (( guess == number )); then
				echo "CONGRATULATIONS, $name! You guessed the number $number in $count attempts."
				end_time=$(date +"%Y-%m-%d %H:%M:%S")
				end_epoch=$(date +%s)

				duration=$(( end_epoch - start_epoch ))

				# Check the player's previous best on this difficulty
				previous_best=0
				best_attempts=0
				best_seconds=0

				while IFS='|' read -r p1 p2 p3 p4 p5 p6 p7 || [[ -n "$p1" ]]; do

					if ! valid_record "$p1" "$p2" "$p3" "$p4" "$p5" "$p6" "$p7"; then
						continue
					fi

					if [[ "$p1" == "$name" && "$p2" == "$LEVEL_NAME" ]]; then

						if (( previous_best == 0 )) || \
						(( p5 < best_attempts )) || \
						(( p5 == best_attempts && p6 < best_seconds )); then

							previous_best=1
							best_attempts=$p5
							best_seconds=$p6
						fi
					fi

				done < "$SCORE_FILE"

				# Display personal best result
				if (( previous_best == 0 )); then
					echo "This is your first game on $LEVEL_NAME!"
				elif (( count < best_attempts )) || \
					(( count == best_attempts && duration < best_seconds )); then
					echo "New personal best! Previous best: $best_attempts attempts."
				else
					echo "Your personal best is still $best_attempts attempts."
				fi

				echo "${name}|${LEVEL_NAME}|${start_time}|${end_time}|${count}|${duration}" >> "$SCORE_FILE"
			fi
			;;

		2)
			#  2) MY HISTORY
			# ------------------------------------

			echo "=== MATCH HISTORY FOR $name ==="

			total_games=0
			total_attempts=0

			while IFS='|' read -r h1 h2 h3 h4 h5 h6 h7 || [[ -n "$h1" ]]; do

				if [[ -z "$h1" && -z "$h2" ]]; then
					continue
				fi

				if ! valid_record "$h1" "$h2" "$h3" "$h4" "$h5" "$h6" "$h7"; then
					continue
				fi

				if [[ "$h1" == "$name" ]]; then

					total_games=$((total_games + 1))
					total_attempts=$((total_attempts + h5))

					m=$((h6 / 60))
					s=$((h6 % 60))

					if (( m > 0 )); then
						formatted_time="${m}m${s}s"
					else
						formatted_time="${s}s"
					fi

					short_date=${h4%% *}

					echo "• Level: $h2 | Attempts: $h5 | Time: $formatted_time | Date: $short_date"
				fi

			done < "$SCORE_FILE"

			if (( total_games > 0 )); then
				average_attempts=$(awk -v total="$total_attempts" -v games="$total_games" \
					'BEGIN { printf "%.2f", total / games }')

				echo "------------------------------------"
				echo "Total games played: $total_games"
				echo "Average attempts: $average_attempts"
			else
				echo "No valid games found for $name."
			fi
			;;
		3)
			# ------------------------------------
			#  3) LEADERBOARD ENGINE
			# ------------------------------------
			echo "Leaderboard · $LEVEL_NAME · best game per player"
			
			leaderboard=$(mktemp) || {
				echo "Error: Could not create temporary file."
				continue
			}

			trap 'rm -f "$leaderboard"' EXIT

			while IFS='|' read -r l1 l2 l3 l4 l5 l6 l7 || [[ -n "$l1" ]]; do

				if [[ -z "$l1" && -z "$l2" ]]; then
					continue
				fi

				if ! valid_record "$l1" "$l2" "$l3" "$l4" "$l5" "$l6" "$l7"; then
					continue
				fi

				if [[ "$l2" == "$LEVEL_NAME" ]]; then
					short_date=${l4%% *}

					printf "%04d|%04d|%s|%s\n" \
						"$l5" "$l6" "$l1" "$short_date" >> "$leaderboard"
				fi

			done < "$SCORE_FILE"
			
			if [[ ! -s "$leaderboard" ]]; then
				echo "No $LEVEL_NAME games played yet."
			else
				printf "%-3s %-11s %-5s %-5s %-10s\n" "#" "PLAYER" "TRIES" "TIME" "DATE"
				
				declare -A seen_players
				rank=1

				while IFS='|' read -r pad_tries pad_seconds p_name p_date || [[ -n "$pad_tries" ]]; do
					real_tries=$((10#$pad_tries))
					real_seconds=$((10#$pad_seconds))

					if [[ -z "${seen_players[$p_name]}" ]]; then
						seen_players[$p_name]=1
						
						m=$((real_seconds / 60))
						s=$((real_seconds % 60))
						if (( m > 0 )); then pretty_time="${m}m${s}s"; else pretty_time="${s}s"; fi

						printf "%-3d %-11s %-5d %-5s %-10s\n" "$rank" "$p_name" "$real_tries" "$pretty_time" "$p_date"
						rank=$((rank + 1))
					fi

					if (( rank > 5 )); then break; fi
				done < <(sort "$leaderboard")
			fi
			;;

		4)
			# ------------------------------------
			#  4) DELETE MY HISTORY ENGINE
			# ------------------------------------
			read -r -p "Delete my history? (y/yes/n/no): " confirm
			confirm="${confirm,,}"

			if [[ "$confirm" == "y" || "$confirm" == "yes" ]]; then
				temp_file=$(mktemp) || {
					echo "Error: Could not create temporary file."
					continue
				}

				trap 'rm -f "$leaderboard" "$temp_file"' EXIT

				deleted_count=0

				while IFS= read -r line || [[ -n "$line" ]]; do

					IFS='|' read -r p1 _ <<< "$line"

					if [[ "$p1" == "$name" ]]; then
						deleted_count=$((deleted_count + 1))
					else
						printf '%s\n' "$line" >> "$temp_file"
					fi

				done < "$SCORE_FILE"

				cp "$temp_file" "$SCORE_FILE"
				rm -f "$temp_file"
				echo "Deleted $deleted_count games."

			elif [[ "$confirm" == "n" || "$confirm" == "no" ]]; then
				echo "Nothing deleted."
			else
				echo "Please answer y or n. Nothing deleted."
			fi
			;;

		5)
			#  5) QUIT
			# ------------------------------------
			echo "Goodbye!"
			exit 0
			;;

		*)
			echo "Invalid option. Please choose a number from 1 to 5."
			;;
	esac
done
