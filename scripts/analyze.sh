#!/usr/bin/env bash
# Analyzes a RISC-V simulation log file
# echo "=== RiSC-V Simulation Log Analysis ==="
set -euo pipefail

#usage function 
usage() {
    cat <<EOF
Usage: $0 <logfile> [options]

Options:
  --format [text|csv]   Output format (default: text)
  --output <file>       Write report to file (default: stdout)
  --verbose             Show extra detail
  --help                Show this message
EOF
}


# Defaults
FORMAT="text"
OUTPUT=""
VERBOSE=false
LOG_FILE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help)
            usage
            exit 0
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --format)
            if [[ $# -lt 2 ]]; then
                echo "Error: $1 needs a value" >&2
                exit 1
            fi
            FORMAT="$2"
            shift 2
            ;;
        --output)
            if [[ $# -lt 2 ]]; then
                echo "Error: $1 needs a value" >&2
                exit 1
            fi
            OUTPUT="$2"
            shift 2
            ;;
        -*)
            echo "Error: unknown option: $1" >&2
            usage
            exit 1
            ;;
        *)
            LOG_FILE="$1"
            shift
            ;;
    esac
done

# Check 1: a log file argument must be given
if [[ -z "$LOG_FILE" ]]; then
    echo "Error: no log file given" >&2
    usage
    exit 1
fi

# Check 2: the file must actually exist
if [[ ! -f "$LOG_FILE" ]]; then
    echo "Error: file not found: $LOG_FILE" >&2
    exit 1
fi