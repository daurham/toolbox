# Toolbox Makefile
# Usage: make <target>

.PHONY: test install clean help

# Default target
all: test

# Run the test suite
test:
	@echo "🧪 Running tests..."
	@chmod +x tests/test_suite.sh
	@./tests/test_suite.sh

# Run tests with verbose output
test-verbose:
	@echo "🧪 Running tests with verbose output..."
	@chmod +x tests/test_suite.sh
	@bash -x ./tests/test_suite.sh

# Install toolbox to user's PATH
install:
	@echo "📦 Installing toolbox..."
	@chmod +x bin/toolbox
	@echo "✅ Toolbox installed. Add to your PATH:"
	@echo "   export PATH=\"\$$HOME/.toolbox/bin:\$$PATH\""

# Clean up test artifacts
clean:
	@echo "🧹 Cleaning up..."
	@rm -rf test_temp
	@find . -name "*.backup.*" -delete
	@echo "✅ Cleanup complete"

# Show help
help:
	@echo "🔧 Toolbox Development Commands:"
	@echo ""
	@echo "  make test         - Run test suite"
	@echo "  make test-verbose - Run tests with verbose output"
	@echo "  make install      - Install toolbox"
	@echo "  make clean        - Clean up test artifacts"
	@echo "  make help         - Show this help"
	@echo ""

# Show toolbox help
toolbox-help:
	@./bin/toolbox help 