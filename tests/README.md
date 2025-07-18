# Toolbox Test Suite

This directory contains comprehensive tests for all toolbox functions to ensure they work correctly as you develop and modify them.

## 🧪 Running Tests

### Quick Test
```bash
# From toolbox root directory
make test
# or
./run_tests.sh
```

### Verbose Testing
```bash
make test-verbose
```

### Individual Test Files
```bash
# Run specific test suite
./tests/test_suite.sh
```

## 📋 What Gets Tested

### Core Functions
- **create** - File and directory creation
- **delete** - File and directory deletion
- **move** - Moving files and directories
- **copy** - Copying files and directories
- **list** - Directory listing with options
- **size** - File and directory size reporting
- **find** - File pattern searching
- **info** - Detailed file/directory information
- **rename** - File and directory renaming
- **update** - File timestamp updates and backups
- **help** - Help system

### Test Coverage
Each function is tested for:
- ✅ **Basic functionality** - Does it do what it's supposed to?
- ✅ **Error handling** - Does it handle errors gracefully?
- ✅ **Edge cases** - Does it work with unusual inputs?
- ✅ **File operations** - Does it correctly create/modify/delete files?
- ✅ **Directory operations** - Does it handle directories properly?
- ✅ **Path handling** - Does it work with relative and absolute paths?

## 🔧 Test Framework Features

### Assertion Functions
- `assert()` - Compare expected vs actual values
- `assert_file_exists()` - Check if file/directory exists
- `assert_file_not_exists()` - Check if file/directory was removed

### Test Environment
- **Isolated testing** - Creates temporary test directory
- **Automatic cleanup** - Removes test artifacts after testing
- **Color-coded output** - Easy to read test results
- **Detailed reporting** - Shows exactly what passed/failed

### Test Results
```
🧪 Running Test Suite
================================

📄 Testing create function
  ✅ Create file
  ✅ Create directory
  ✅ Create nested file
  ✅ Create absolute path

📦 Testing move function
  ✅ Move file to directory
  ✅ Source file removed
  ✅ Move and rename file

================================
📊 Test Results:
  Total: 25
  ✅ Passed: 25
  ❌ Failed: 0
✅ All tests passed!
```

## 🚀 Development Workflow

1. **Write your function** in the appropriate `lib/*.sh` file
2. **Add tests** to `tests/test_suite.sh` for your function
3. **Run tests** with `make test`
4. **Fix any failures** and re-run tests
5. **Commit your changes** when all tests pass

## 🐛 Debugging Failed Tests

### Verbose Mode
```bash
make test-verbose
```
Shows exactly what commands are being executed.

### Individual Test Debugging
```bash
# Test just the create function
cd tests
source ../lib/utils.sh
source ../lib/create.sh
create_item "test_file.txt"
ls -la test_file.txt
```

### Common Issues
- **Permission errors** - Make sure test files are writable
- **Path issues** - Check that relative paths work correctly
- **Function naming** - Ensure function names match between lib and test files

## 📝 Adding New Tests

To add tests for a new function:

1. **Add test function** to `tests/test_suite.sh`:
```bash
test_new_function() {
    echo -e "${CYAN}🔧 Testing new_function${RESET}"
    
    # Setup test data
    echo "test data" > test_file.txt
    
    # Source the function
    source "$LIB/new_function.sh"
    
    # Test the function
    new_function "test_file.txt" > /dev/null 2>&1
    assert_file_exists "New function works" "expected_output.txt"
}
```

2. **Add to main()** function:
```bash
main() {
    test_start
    setup_test_env
    
    # ... existing tests ...
    test_new_function  # Add this line
    
    cleanup_test_env
    test_end
}
```

3. **Run tests** to verify:
```bash
make test
```

## 🎯 Best Practices

- **Test edge cases** - Empty files, missing files, invalid paths
- **Test error conditions** - What happens when things go wrong?
- **Use descriptive test names** - Makes failures easier to debug
- **Clean up after tests** - Don't leave test artifacts
- **Test both success and failure** - Ensure error handling works

## 🔄 Continuous Integration

The test suite is designed to:
- **Exit with code 0** when all tests pass
- **Exit with code 1** when any test fails
- **Provide clear output** about what passed/failed
- **Clean up automatically** after running

This makes it perfect for CI/CD pipelines and automated testing! 