# 🏷 guess_game

A gitbash script that prompts the user to guess a number

## 📌 Problem Statement

When learning shell scripting, transitioning from theoretical commands to logic flow control (like loops, conditionals, and user input validation) can be challenging. This project solves that by creating a practical, engaging exercise that requires handling dynamic user input and maintaining a game state in a terminal environment.

## Project_Gaols

**ractice Core Bash Concepts:** Implement loops (`while`), conditional statements (`if/else`), and user input handling (`read`).

**State Management:** Track variables across iterations (e.g., counting the total number of user attempts).

**Input Validation:** Ensure the script safely handles non-numeric inputs or out-of-bounds guesses without crashing.

## Tech_Stack

**Language:** Bash

**Environment:** Linux or Git Bash on windows

## Features

**Random number generation:** Automatically picks a random number between 1 - 100 every time a new game starts

**Dynamic feedback:** Tells the user their guess is too "high" or too "low" to guide them to the correct answer.

**Score Tracking:** counts and displays the total number of attemps it took for the player to win.

## How can i run it?

Navigate to the folder containing your script
(`cd /home/user/project`)

Give permission to the file to let it run as a program (`chmod +x guess_game.sh`)

Execute the script (`./guess_game.sh`)

## What i learned in the process

How to capture and read user input dynamically in real time

How to apply standard conditional logic (`if/elif/else`) and loops (`while`) in the terminal
