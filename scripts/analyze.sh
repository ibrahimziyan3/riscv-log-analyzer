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

# Count lines in the log that report a given test status (PASS, FAIL or SKIP)
count_status() {
    local status="$1"
    grep -c "TEST ${status}:" "$LOG_FILE" || true
}

PASS=$(count_status "PASS")
FAIL=$(count_status "FAIL")
SKIP=$(count_status "SKIP")

TOTAL=$((PASS + FAIL + SKIP))
if [[ "$TOTAL" -eq 0 ]]; then
    echo "Error: no test results found in $LOG_FILE" >&2
    exit 1
fi
PASS_RATE=$(awk -v p="$PASS" -v t="$TOTAL" 'BEGIN { printf "%.1f", p / t * 100 }')
FAIL_RATE=$(awk -v p="$FAIL" -v t="$TOTAL" 'BEGIN { printf "%.1f", p / t * 100 }')
SKIP_RATE=$(awk -v p="$SKIP" -v t="$TOTAL" 'BEGIN { printf "%.1f", p / t * 100 }')

#Function for Default or Text output
print_text_report() {
    echo "=== RISC-V Simulation Log Analysis ==="
    echo "Log file: $LOG_FILE"
    echo "Analysis date: $(date '+%Y-%m-%d %H:%M:%S')"
    echo
    echo "--- Results Summary ---"
    echo "Total tests: $TOTAL"
    echo "Passed:  $PASS ($PASS_RATE%)"
    echo "Failed:  $FAIL ($FAIL_RATE%)"
    echo "Skipped: $SKIP ($SKIP_RATE%)"
    echo
    echo "--- Failed Tests ---"
    awk '/TEST FAIL:/ { n++; print n ". " $5 }' "$LOG_FILE"
    echo
    echo "--- Timing Statistics ---"
    awk '
    /TEST (PASS|FAIL):/ {
        t = $6
        gsub(/[()s]/, "", t)
        t = t + 0
        sum += t
        n++
        if (n == 1 || t < min) { min = t; min_name = $5 }
        if (n == 1 || t > max) { max = t; max_name = $5 }
    }
    END {
        if (n > 0) {
            printf "Min time: %.2fs (%s)\n", min, min_name
            printf "Max time: %.2fs (%s)\n", max, max_name
            printf "Avg time: %.2fs\n", sum / n
        }
    }
    ' "$LOG_FILE"
    echo
}
