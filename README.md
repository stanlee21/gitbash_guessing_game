# 🏷 guess_game

Gitbash Guessing Game

## 📌 Problem Statement

A robust, interactive guessing game designed specifically for **Git Bash**. This project features variable difficulties, real-time score tracking, dynamic line validation, localized match history, leaderboard calculation systems, and safe user history pruning.
The script is optimized to be completely compliant with strict **ShellCheck** linter definitions.

## Project_Goals

**practice Core Bash Concepts:** Implement loops (`while`), conditional statements (`if/else`), and user input handling (`read`).

**State Management:** Track variables across iterations (e.g., counting the total number of user attempts).

**Input Validation:** Ensure the script safely handles non-numeric inputs or out-of-bounds guesses without crashing.

## Tech_Stack

**Language:** Bash

**Environment:** Linux or Git Bash on windows

## Features

### 1. Dynamic Difficulty Settings

The script accepts arguments upon boot up to instantly calibrate gameplay ranges and limits:
**Easy:** Values range from `1-50` with unlimited guessing attempts.
**Normal:** Values range from `1-100` with unlimited guessing attempts *(Default fallback)*.
**Hard:** Values range from `1-1000` capped tightly at a maximum of `7` attempts.

### 2. Time & Attempt Metrics

Tracks execution timings accurately across system shifts
Isolates pure integer constants from text string logging layouts cleanly using string pattern truncation engines (`${variable%% *}`).
Converts numerical entries safely back to Base-10 decimals (`$((10#$variable))`) to circumvent structural octal conversions errors natively.

### 3. Interactive Performance Visualizations

**Match History Summary:** Displays valid matching logs across all levels simultaneously.
**Leaderboard Engine:** Filters records exclusively for the active match difficulty level. It displays the **Top 5** players sorted by fewest attempts first, then by fastest time, while utilizing memory matrices to ensure each player is listed only once.

### 4. Secure History

Uses safe isolation variables (`temp_file.txt`) to process file modification streams sequentially without data collisions.
Ensures that matching entries belonging to other competitors remain completely untouched.

## How to run the game?

Give permission to the file to let it run as a program (`chmod +x guess_game.sh`)
Launch the game by providing your name and preferred difficulty level as arguments:

```bash
./guess.sh Muna easy
./guess.sh Alex hard
```

## What i learned in the process

How to capture and read user input dynamically in real time
How to apply standard conditional logic (`if/elif/else`) and loops (`while`) in the terminal

## Screenshots

![alt text](<assets/image/Screenshot From 2026-10-27 10-19-42.png>)
![alt text](<assets/image/Screenshot From 2026-10-27 10-19-53.png>)

## Demo

![alt text](<assets/image/Screenshot From 2026-10-27 10-19-07.png>)
![alt text](<assets/image/Screenshot From 2026-10-27 10-19-20.png>)

## ⚙ Installation & Setup

Clone the repository:

```bash
git clone https://github.com/yourusername/project-name.git
cd project-name
```
