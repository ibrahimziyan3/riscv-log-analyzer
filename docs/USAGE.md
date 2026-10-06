# Usage Guide

## Command
```bash
./scripts/analyze.sh <logfile> [options]
```

## Options
| Option | Meaning | Default |
|---|---|---|
| `<logfile>` | Path to the log file (required) | none |
| `--format text` or `--format csv` | Output format | text |
| `--output <file>` | Save the report to a file | screen |
| `--verbose` | Also show ERROR lines from the log | off |
| `--help` | Show help | |

## Exit codes
- 0: all tests passed
- 1: at least one test failed, or there was an error

## Examples
```bash
./scripts/analyze.sh test_data/sample_pass.log
./scripts/analyze.sh test_data/sample_sim.log --format csv --output output/sim.csv
```

## Make commands
| Command | What it does |
|---|---|
| `make all` | Analyze all logs in test_data/ |
| `make test` | Check the results are correct |
| `make report` | Save reports into output/ |
| `make clean` | Delete generated reports |
| `make setup` | Check required tools are installed |
| `make help` | List commands |
