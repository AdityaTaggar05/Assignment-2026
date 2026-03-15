#!/usr/bin/env bash

# Settings
word_count=8
language="english"
difficulty="m"

symbols=("!" "?" "." "," ";" ":" "@" "#" "&" "*")
words=()

selected=0
menu_items=("Start Test" "Word Count" "Difficulty" "Language" "History" "Quit")

# Usage function
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

# TUI helpers
draw_header() {
  tput cup 0 0
  tput bold
  echo "BASH TYPING TEST"
  tput sgr0
  echo "---------------------------------------------"
}

draw_menu() {
  clear
  draw_header

  for i in "${!menu_items[@]}"; do
    tput cup $((i+3)) 2

    if [[ $i -eq $selected ]]; then
      tput rev
    fi

    case "${menu_items[$i]}" in
      "Word Count")
        echo "Word Count : $word_count"
        ;;
      "Difficulty")
        echo "Difficulty : $difficulty"
        ;;
      "Language")
        echo "Language   : $language"
        ;;
      *)
        echo "${menu_items[$i]}"
        ;;
    esac

    tput sgr0
  done

  echo ""
  echo "Use the arrow keys or j/k to navigate, ENTER to select"
}

# Input handling
read_key() {
  read -rsn1 key
  if [[ $key == $'\x1b' ]]; then
    read -rsn2 key
  fi
  echo "$key"
}

# Wordset loading
load_wordset() {
  filename="$HOME/.local/share/$language.json"

  if ! [[ -f "$filename" ]]; then
    mkdir -p "$HOME/.local/share"
    if ! curl --silent --fail -L "https://raw.githubusercontent.com/monkeytypegame/monkeytype/master/frontend/static/languages/$language.json" -o "$filename"; then
      echo "no wordset found corresponding to language $language. Reverting to default (english) in 2 seconds..."
      sleep 2
      language="english"
      load_wordset
      return
    fi
  fi

  mapfile -t words < <(jq -r '.words[]' "$filename" | tr -d '\r')
}

# Sentence generation
generate_sentence() {
  freq_symbols=$1

  for ((i=1;i<=word_count;i++)); do
    rand=$(( RANDOM % freq_symbols ))
    random_idx=$(( RANDOM % ${#words[@]} ))

    printf "%s" "${words[$random_idx]}"

    if (( rand == 1 )); then
      printf "%s" "${symbols[$(( RANDOM % ${#symbols[@]} ))]}"
    fi

    (( i != word_count )) && printf " "
  done
}

generate_target_text() {
  case "$difficulty" in
    e|easy) generate_sentence 1 ;;
    m|medium) generate_sentence 5 ;;
    h|hard) generate_sentence 3 ;;
  esac
}

# Accuracy
calculate_accuracy() {
  original="$1"
  typed="$2"

  original_len=${#original}
  typed_len=${#typed}

  max_len=$(( original_len > typed_len ? original_len : typed_len ))
  min_len=$(( original_len < typed_len ? original_len : typed_len ))

  correct=0

  for ((i=0;i<min_len;i++)); do
    [[ "${original:$i:1}" == "${typed:$i:1}" ]] && ((correct++))
  done

  ((max_len==0)) && echo 0 || echo $(( correct * 100 / max_len ))
}

# Test screen
run_test() {
  clear
  target=$(generate_target_text)

  draw_header
  echo ""
  echo "Type the sentence below:"
  echo ""

  tput setaf 6
  echo "$target"
  tput sgr0

  echo ""
  echo -n "> "

  tput cnorm
  start=$SECONDS
  read -r input
  end=$SECONDS
  tput civis

  time=$((end-start))
  ((time==0)) && time=1

  chars=${#input}
  wpm=$(( chars * 12 / time ))

  accuracy=$(calculate_accuracy "$target" "$input")

  clear
  draw_header

  save_results "$time" "$wpm" "$accuracy"
  show_results "$time" "$wpm" "$accuracy" "$(date)"

  echo "Press any key to return to menu..."
  read -rsn1
}

# Saving Results
save_results() {
  filename="$HOME/.local/share/pandatype-results.csv"
  if ! [[ -f "$filename" ]]; then
    mkdir -p "$HOME/.local/share/"
    touch $filename
  fi

  echo "$1,$2,$3,$(date)" >> $filename
}

# Results screen
show_results() {
  echo ""
  echo "===================================="
  echo "             RESULTS                "
  echo "===================================="
  echo ""
  echo "Time          : $1 sec"
  echo "WPM           : $2"
  echo "Accuracy      : $3 %"
  echo "Test Done on  : $4"
  echo ""
  echo "===================================="
}

# History screen
show_history() {
  clear

  file="$HOME/.local/share/pandatype-results.csv"

  [[ -f "$file" ]] || {
    echo "No history available."
    read -rsn1
    return
  }

  draw_header
  while IFS=',' read -r time wpm accuracy timestamp; do
    show_results "$time" "$wpm" "$accuracy" "$timestamp"
  done < "$file"

  echo ""
  echo "Press any key to return to menu..."
  read -rsn1
}

menu_loop() {
  draw_menu
  while true; do
    key=$(read_key)

    case "$key" in
      "[A" | "k")
        ((selected--))
        ((selected<0)) && selected=$((${#menu_items[@]}-1))
        draw_menu
        ;;
      "[B" | "j")
        ((selected++))
        ((selected>=${#menu_items[@]})) && selected=0
        draw_menu
        ;;
      "")
        case $selected in
          0)
            run_test
            draw_menu
            ;;
          1)
            while true; do
              read -p "Enter word count: " temp
              if [[ "$temp" =~ ^[0-9]+$ ]]; then
                word_count="$temp"
                break
              else
                echo "word count must be a number"
                echo ""
              fi
            done
            draw_menu
            ;;
          2)
            while true; do
              read -p "Difficulty (e/m/h): " temp
              case "$temp" in
                e|m|h|easy|medium|hard)
                  difficulty="$temp"
                  break
                  ;;
                *)
                  echo "difficulty must either be easy/e, medium/m, hard/h"
                  echo ""
                  ;;
              esac
            done
            draw_menu
            ;;
          3)
            read -p "Language: " language
            load_wordset
            draw_menu
            ;;
          4)
            show_history
            draw_menu
            ;;
          5)
            clear
            exit
            ;;
        esac
        ;;
    esac
  done
}

# Load provided settings through cli options
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

if ! load_wordset; then
  exit 1 
fi

tput civis
trap "tput cnorm; clear; exit" EXIT
menu_loop
