#!/bin/bash

ERROR_LOG="errors.log"

search_directory() {
    local dir="$1"
    local keyword="$2"
   
    for file in "$dir"/*; do
        if [[ -d "$file" ]]; then
            search_directory "$file" "$keyword"
        elif [[ -f "$file" ]]; then
            grep -Hn "$keyword" "$file" 2>/dev/null
        fi
    done
}

show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
  -d <directory>  Search for a keyword in the specified directory recursively
  -k <keyword>    Keyword to search for
  -f <file>       Search for a keyword in a specific file
  --help          Display this help message

Examples:
  $0 -d logs -k error
  $0 -f script.sh -k TODO
EOF
}

log_error() {
    echo "Error: $1" | tee -a "$ERROR_LOG"
    exit 1
}

validate_input() {
    local file="$1"
    local keyword="$2"
   
    [[ -n "$keyword" ]] || log_error "Keyword cannot be empty"
    [[ "$keyword" =~ ^[a-zA-Z0-9_]+$ ]] || log_error "Invalid keyword format"
    [[ -f "$file" ]] || log_error "File does not exist"
}

while getopts ":d:k:f:-:" opt; do
    case "$opt" in
        d) directory="$OPTARG" ;;
        k) keyword="$OPTARG" ;;
        f) file="$OPTARG" ;;
        -)
            case "$OPTARG" in
                help) show_help; exit 0 ;;
                *) log_error "Invalid option: --$OPTARG" ;;
            esac
        ;;
        *) log_error "Invalid option: -$opt" ;;
    esac
done

if [[ -n "$directory" && -n "$keyword" ]]; then
    [[ -d "$directory" ]] || log_error "Directory does not exist"
    search_directory "$directory" "$keyword"
elif [[ -n "$file" && -n "$keyword" ]]; then
    validate_input "$file" "$keyword"
    grep -Hn "$keyword" "$file" <<< "$(cat "$file")" 2>/dev/null
else
    log_error "Missing required arguments. Use --help for usage details."
fi


