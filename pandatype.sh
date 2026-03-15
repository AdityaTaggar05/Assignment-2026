#!/bin/bash

# Variables for the application
word_count=8
language="english"
difficulty="m"

words=()
symbols=("!" "?" "." "," ";" ":" "@" "#" "&" "*")

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  -w, --words <number>        Number of words (default: $word_count)
  -l, --language <language>   Language (default: $language)
  -d, --difficulty <level>    Difficulty: easy/e | medium/m | hard/h (default: $difficulty)
  -h, --help                  Show this help message and exit

Examples:
  $(basename "$0") -w 20 -l english -d easy
  $(basename "$0") --words 50 --language spanish --difficulty hard
EOF
}

# Load the requested language's wordset 
load_wordset() {
  filename="$HOME/.local/share/$language.json"
  if ! [[ -f "$filename" ]]; then 
    echo "Downloading wordset for the language $language..."
    echo ""
    mkdir -p "$HOME/.local/share"
    curl -L "https://raw.githubusercontent.com/monkeytypegame/monkeytype/master/frontend/static/languages/$language.json" -o "$filename"
    echo "download complete..."
    echo ""
  fi

  mapfile -t words < <(jq -r '.words[]' "$filename" | tr -d '\r')
}

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
  freq_symbols=$1 

  for ((i=1;i<=word_count;i++)); do
    rand=$(( RANDOM % freq_symbols ))
    random_idx=$(( RANDOM % ${#words[@]} ))
    echo -n "${words[$random_idx]}"

    # To ensure no symbols for easy mode
    if (( rand == 1 )); then
      echo -n "${symbols[$(( RANDOM % ${#symbols[@]} ))]}"
    fi

    # To ensure no extra whitespace is added at the end of sentence
    if (( i != word_count )); then 
      echo -n " "
    fi
  done
}

generate_target_text() {
  sentence=

  case "$difficulty" in
    e | easy)
      sentence=$(generate_sentence 1)
      ;;
    m | medium)
      sentence=$(generate_sentence 5)
      ;;
    h | hard)
      sentence=$(generate_sentence 3)
      ;;
    *)
      echo "Invalid difficult: $difficulty" >&2
      exit 1
      ;;
  esac

  echo "$sentence"
}

# Main test function
run_test() {
    # Pick a random text from the array
    target_text=$(generate_target_text)
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

error() {
  echo "error: $1" >&2
  echo >&2
  usage >&2
  exit 1
}

while [[ -n "$1" ]]; do
  case "$1" in
    -w | --words)
      [[ -z "$2" || "$2" =~ ^- ]] && error "missing word count"
      [[ "$2" =~ ^[0-9]+$ ]] || error "word count must be a number"

      word_count=$2 
      shift 2
      ;;
    -l | --language)
      [[ -z "$2" || "$2" =~ ^- ]] && error "missing language"
      language=$2 
      shift 2
      ;;
    -d | --difficulty)
      [[ -z "$2" || "$2" =~ ^- ]] && error "missing difficulty"
      case "$2" in
        e|m|h|easy|medium|hard)
          difficulty="$2"
          ;;
        *)
          error "invalid difficulty: $2 (use easy, medium, hard)"
          ;;
      esac
      shift 2
      ;;
    -h | --help)
      usage
      exit
      ;;
    *)
      usage >&2
      exit 1 
      ;;
  esac
done

load_wordset
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
