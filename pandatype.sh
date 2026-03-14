#!/bin/bash

# Define an array of sentences/paragraphs for the test
TEXTS=(
    "The quick brown fox jumps over the lazy dog."
    "Bash is a Unix shell and command language written by Brian Fox for the GNU Project."
    "Programming is the process of creating a set of instructions that tell a computer how to perform a task."
    "Consistency is key when learning how to type fast. Keep your fingers on the home row."
    "Open-source software is software with source code that anyone can inspect, modify, and enhance."
)

# Function to calculate accuracy by comparing character by character
calculate_accuracy() {
    original="$1"
    typed="$2"
    original_len=${#original}
    typed_len=${#typed}
    correct_chars=0

    # Max length is used to penalize missed or extra characters
    max_len=$(( original_len > typed_len ? original_len : typed_len ))
    min_len=$(( original_len < typed_len ? original_len : typed_len ))

    # Loop through and compare each character
    for (( i=0; i<min_len; i++ )); do
        if [[ "${original:$i:1}" == "${typed:$i:1}" ]]; then
            ((correct_chars++))
        fi
    done

    # Avoid division by zero in case of an empty string
    if [[ $max_len -eq 0 ]]; then
        echo 0
    else
        echo $(( correct_chars * 100 / max_len ))
    fi
}

# Main test function
run_test() {
    clear
    echo "=========================================="
    echo "          BASH TYPING TEST                "
    echo "=========================================="
    echo "Press [ENTER] when you are ready to start."
    read -r

    # Pick a random text from the array
    random_idx=$(( RANDOM % ${#TEXTS[@]} ))
    target_text="${TEXTS[$random_idx]}"

    clear
    echo "Type the text below and press [ENTER] when done:"
    echo "------------------------------------------------"
    # Printing the test in cyan color
    echo -e "\e[1;36m$target_text\e[0m"
    echo "------------------------------------------------"
    echo -n "> "

    # Start the timer
    start_time=$SECONDS

    # Read the user's input
    read -r user_input

    # Stop the timer
    end_time=$SECONDS
    time_taken=$(( end_time - start_time ))

    if [[ $time_taken -eq 0 ]]; then
        time_taken=1
    fi

    # Considering there are at avg. 5 characters per word
    chars_typed=${#user_input}
    wpm=$(( chars_typed * 12 / time_taken ))

    # Calculate accuracy
    accuracy=$(calculate_accuracy "$target_text" "$user_input")

    # Display results
    echo ""
    echo "=========================================="
    echo "                 RESULTS                  "
    echo "=========================================="
    echo "Time taken : $time_taken seconds"
    echo "Gross WPM  : $wpm WPM"
    echo "Accuracy   : $accuracy %"
    echo "=========================================="
}

# Infinite loop to allow restarting the test
while true; do
    run_test

    echo ""
    read -p "Do you want to play again? (y/n): " choice
    case "$choice" in
        y) 
            continue 
            ;;
        n) 
            echo "Thanks for practicing! Goodbye."
            break 
            ;;
        * ) 
            echo "Invalid input. Exiting..."
            break 
            ;;
    esac
done
