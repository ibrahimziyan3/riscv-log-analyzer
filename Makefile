# Makefile for riscv-log-analyzer

SCRIPT = bash scripts/analyze.sh

.PHONY: all test report clean help setup

# Show all targets
help:
	@echo "Available targets:"
	@echo "  all     - Run the analyzer on all test logs"
	@echo "  test    - Run analyzer on each test log and verify results"
	@echo "  report  - Generate text and CSV reports in output/"
	@echo "  clean   - Remove generated files in output/"
	@echo "  setup   - Check that required tools are installed"
	@echo "  help    - Show this message"

# Check required tools are installed
setup:
	@for tool in bash grep awk sed date; do \
		if command -v $$tool >/dev/null 2>&1; then \
			echo "OK: $$tool found"; \
		else \
			echo "MISSING: $$tool"; exit 1; \
		fi; \
	done

# Run the analyzer on every test log (|| true because failing logs exit 1)
all:
	@for f in test_data/*.log; do \
		echo "=== $$f ==="; \
		$(SCRIPT) $$f || true; \
		echo; \
	done

# Verify expected exit codes and output
test:
	@fail=0; \
	$(SCRIPT) test_data/sample_pass.log >/dev/null && rc=0 || rc=$$?; \
	if [ $$rc -eq 0 ]; then echo "PASS: sample_pass.log exits 0"; else echo "FAIL: sample_pass.log expected 0, got $$rc"; fail=1; fi; \
	$(SCRIPT) test_data/sample_fail.log >/dev/null && rc=0 || rc=$$?; \
	if [ $$rc -eq 1 ]; then echo "PASS: sample_fail.log exits 1"; else echo "FAIL: sample_fail.log expected 1, got $$rc"; fail=1; fi; \
	$(SCRIPT) test_data/sample_sim.log >/dev/null && rc=0 || rc=$$?; \
	if [ $$rc -eq 1 ]; then echo "PASS: sample_sim.log exits 1"; else echo "FAIL: sample_sim.log expected 1, got $$rc"; fail=1; fi; \
	if $(SCRIPT) test_data/sample_fail.log | grep -q "Failed:  2"; then echo "PASS: sample_fail.log reports 2 failures"; else echo "FAIL: sample_fail.log failure count wrong"; fail=1; fi; \
	exit $$fail

# Generate text and CSV reports for every log into output/
report:
	@mkdir -p output
	@for f in test_data/*.log; do \
		name=$$(basename $$f .log); \
		$(SCRIPT) $$f --output output/$$name.txt >/dev/null || true; \
		$(SCRIPT) $$f --format csv --output output/$$name.csv >/dev/null || true; \
		echo "Generated output/$$name.txt and output/$$name.csv"; \
	done

# Remove generated files
clean:
	@rm -rf output/*
	@echo "Cleaned output/"
