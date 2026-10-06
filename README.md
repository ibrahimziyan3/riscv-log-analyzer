cat > README.md <<'EOF'
# riscv-log-analyzer

## Description
A shell tool that reads RISC-V simulation log files and prints a summary:
total tests, passed/failed/skipped counts, pass rate, failing test names,
and min/max/average execution time.

## Installation
```bash
git clone git@github.com:ibrahimziyan3/riscv-log-analyzer.git
cd riscv-log-analyzer
chmod +x scripts/*.sh
make setup
```

## Usage
```bash
./scripts/analyze.sh <logfile> [--format text|csv] [--output <file>] [--verbose] [--help]
```

Examples:
```bash
./scripts/analyze.sh test_data/sample_fail.log
./scripts/analyze.sh test_data/sample_fail.log --format csv
./scripts/analyze.sh test_data/sample_fail.log --format csv --output output/report.csv
./scripts/analyze.sh test_data/sample_fail.log --verbose
```

## Sample Output
=== RISC-V Simulation Log Analysis ===
Log file: test_data/sample_sim.log
Analysis date: 2026-10-06 22:32:40

--- Results Summary ---
Total tests: 25
Passed:  20 (80.0%)
Failed:  3 (12.0%)
Skipped: 2 (8.0%)

--- Failed Tests ---
1. rv32i-sra
2. rv32i-lb
3. rv32i-mul

--- Timing Statistics ---
Min time: 0.39s (rv32i-nop)
Max time: 2.85s (rv32i-mul)
Avg time: 0.90s

--- Verdict: FAIL ---
Exit code: 1
