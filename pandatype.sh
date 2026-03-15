#!/bin/bash

WORDSET="wordset.txt"
mapfile -t words < "$WORDSET"
symbols=("!" "?" "." "," ";" ":" "@", "#", "&", "*")

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

# Generate sentence based on the passed parameters
generate_sentence() {
  num_words=$1 
  freq_symbols=$2 

  for ((i=1;i<=num_words;i++)); do
    rand=$(( RANDOM % freq_symbols ))
    random_idx=$(( RANDOM % ${#words[@]} ))
    echo -n "${words[$random_idx]}"

    # To ensure no symbols for easy mode
    if (( rand == 1 )); then
      echo -n "${symbols[$(( RANDOM % ${#symbols[@]} ))]}"
    fi

    # To ensure no extra whitespace is added at the end of sentence
    if (( i != num_words )); then 
      echo -n " "
    fi
  done
}

choose_difficulty() {
  read -p "Choose the difficulty level for you: Easy (e), Medium (m), Hard (h) : " difficulty
  sentence=""
  random_idx=$(( RANDOM % 5 ))

  case "$difficulty" in
    e)
      sentence=$(generate_sentence 8 1)
      ;;
    m)
      sentence=$(generate_sentence 12 5)
      ;;
    h)
      sentence=$(generate_sentence 16 3)
      ;;
  esac

  echo "$sentence"
}

# Main test function
run_test() {
    # Pick a random text from the array
    target_text=$(choose_difficulty)
    echo ""

    clear
    echo "=========================================="
    echo "          BASH TYPING TEST                "
    echo "=========================================="
    echo "Press [ENTER] when you are ready to start."
    read -r

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
