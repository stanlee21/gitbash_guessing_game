#!/bin/bash

#---- define destination file so it saves properly
SCORE_FILE="score.txt"

# Ensure the file exists so the loops don't error out on a fresh run
touch "$SCORE_FILE"

#checking for too many arguments
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

# =========================================================================
#  MAIN INTERACTIVE MENU LOOP
# =========================================================================
while true; do
	# Recalculate damaged lines dynamically on every menu loop refresh
	damaged_count=0
	while IFS='|' read -r f1 f2 f3 f4 f5 f6 f7 || [[ -n "$f1" ]]; do
		if [[ -z "$f1" && -z "$f2" ]]; then
			continue
		fi
		remove_seconds=${f6%% *}

		if [[ -n "$f7" ]] || \
			[[ -z "$f1" || -z "$f2" || -z "$f3" || -z "$f4" || -z "$f5" || -z "$f6" ]] || \
			[[ "$f2" != "easy" && "$f2" != "normal" && "$f2" != "hard" ]] || \
			[[ ! "$f5" =~ ^[0-9]+$ ]] || \
			[[ ! "$remove_seconds" =~ ^[0-9]+$ ]]; then
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
			start_time=$(date +%s)
			if (( MAX_ATTEMPT != -1 )); then
				echo "Listen! you have just '$MAX_ATTEMPT' attempts to guess the Number"
			fi

			number=$(( RANDOM % MAX_RANGE + 1 ))
			guess=-1
			count=0

			while (( guess != number )); do
				if (( MAX_ATTEMPT != -1 && count >= MAX_ATTEMPT )); then
					echo "====================================================="
					echo "GAME OVER, You ran out of attempts"
					echo "the secret number is '$number': "
					break
				fi

				read -r -p "Guess the random number: " guess

				if [[ -z "$guess" ]]; then
					echo "Enter a number, you absolute infidel!"
					continue 
				fi

				if [[ ! "$guess" =~ ^[0-9]+$ ]]; then
					echo "That isn't even a number! Use your brain, infidel!"
					continue
				fi

				count=$((count + 1))

				if (( guess > number )); then
					echo "LOL! Too high!"
				elif (( guess < number )); then
					echo "OH OH! Too low! Try again!"
				fi
			done

			if (( guess == number )); then
				echo "CONGRATULATIONS, $name! You guessed the number $number in $count attempts."
				end_time=$(date +"%Y-%m-%d %H:%M:%S")
				seconds=$(date +%s)
				duration=$(( seconds - start_time ))
				echo "${name}|${LEVEL_NAME}|${start_time}|${end_time}|${count}|${duration} seconds" >> "$SCORE_FILE"
			fi
			;;

		2)
			# ------------------------------------
			#  2) MY HISTORY (CLEANLY ACCUMULATES METRICS)
			# ------------------------------------
			echo "=== MATCH HISTORY FOR $name ==="
			while IFS='|' read -r h1 h2 h3 h4 h5 h6 _h7 || [[ -n "$h1" ]]; do
				if [[ -z "$h1" ]]; then continue; fi
				clean_history_seconds=${h6%% *}

				if [[ -z "$h1" || -z "$h2" || -z "$h3" || -z "$h4" || -z "$h5" || -z "$h6" ]] || \
				   [[ "$h2" != "easy" && "$h2" != "normal" && "$h2" != "hard" ]] || \
				   [[ ! "$h5" =~ ^[0-9]+$ ]] || \
				   [[ ! "$clean_history_seconds" =~ ^[0-9]+$ ]]; then
					continue 
				fi

				if [[ "$h1" == "$name" ]]; then
					# Parse raw seconds matching assignment format e.g. 1m40s
					m=$((clean_history_seconds / 60))
					s=$((clean_history_seconds % 60))
					if (( m > 0 )); then formatted_time="${m}m${s}s"; else formatted_time="${s}s"; fi

					short_date=${h4%% *}
					echo "• Level: $h2 | Attempts: $h5 | Time: $formatted_time | Date: $short_date"
				fi
			done < "$SCORE_FILE"
			;;

		3)
			# ------------------------------------
			#  3) LEADERBOARD ENGINE
			# ------------------------------------
			echo "Leaderboard · $LEVEL_NAME · best game per player"
			
			leaderboard="leaderboard.txt"
			touch "$leaderboard"
			true > "$leaderboard"

			while IFS='|' read -r l1 l2 l3 l4 l4_tries l4_seconds_raw _l7 || [[ -n "$l1" ]]; do
				if [[ -z "$l1" && -z "$l2" ]]; then continue; fi
				l4_seconds=${l4_seconds_raw%% *}

				if [[ -z "$l1" || -z "$l2" || -z "$l3" || -z "$l4" || -z "$l4_tries" || -z "$l4_seconds_raw" ]] || \
				   [[ "$l2" != "easy" && "$l2" != "normal" && "$l2" != "hard" ]] || \
				   [[ ! "$l4_tries" =~ ^[0-9]+$ ]] || \
				   [[ ! "$l4_seconds" =~ ^[0-9]+$ ]]; then
					continue 
				fi

				if [[ "$l2" == "$LEVEL_NAME" ]]; then
					short_date=${l4%% *}
					printf "%04d|%04d|%s|%s\n" "$l4_tries" "$l4_seconds" "$l1" "$short_date" >> "$leaderboard"
				fi
			done < "$SCORE_FILE"

			if [[ ! -s "$leaderboard" ]]; then
				echo "No $LEVEL_NAME games played yet."
				rm -f "$leaderboard"
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

				rm -f "$leaderboard"
			fi
			;;

		4)
			# ------------------------------------
			#  4) DELETE MY HISTORY ENGINE
			# ------------------------------------
			read -r -p "Delete my history? (y/yes/n/no): " confirm
			confirm="${confirm,,}"

			if [[ "$confirm" == "y" || "$confirm" == "yes" ]]; then
				temp_file="temp_file.txt"
				touch "$temp_file"
				true > "$temp_file"

				deleted_count=0
				while IFS='|' read -r p1 p2 p3 p4 p5 p6 _p7 || [[ -n "$p1" ]]; do
					if [[ -z "$p1" && -z "$p2" ]]; then continue; fi

					if [[ "$p1" == "$name" ]]; then
						deleted_count=$((deleted_count + 1))
					else
						echo "${p1}|${p2}|${p3}|${p4}|${p5}|${p6}" >> "$temp_file"
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
