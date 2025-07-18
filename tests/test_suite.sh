#!/usr/bin/env bash

# Test Suite for Toolbox Functions
# Run with: ./tests/test_suite.sh

TOOLBOX_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIB="$TOOLBOX_ROOT/lib"
BIN="$TOOLBOX_ROOT/bin"

# Source the toolbox functions
source "$LIB/utils.sh"

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Test helper functions
test_start() {
    echo -e "${BLUE}🧪 Running Test Suite${RESET}"
    echo -e "${GRAY}================================${RESET}"
    echo ""
}

test_end() {
    echo ""
    echo -e "${GRAY}================================${RESET}"
    echo -e "${BLUE}📊 Test Results:${RESET}"
    echo -e "  Total: $TOTAL_TESTS"
    echo -e "  ${GREEN}Passed: $PASSED_TESTS${RESET}"
    echo -e "  ${RED}Failed: $FAILED_TESTS${RESET}"
    
    if [[ $FAILED_TESTS -eq 0 ]]; then
        echo -e "${GREEN}✅ All tests passed!${RESET}"
        exit 0
    else
        echo -e "${RED}❌ Some tests failed${RESET}"
        exit 1
    fi
}

assert() {
    local test_name="$1"
    local expected="$2"
    local actual="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [[ "$expected" == "$actual" ]]; then
        echo -e "  ${GREEN}✅ $test_name${RESET}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "  ${RED}❌ $test_name${RESET}"
        echo -e "    Expected: $expected"
        echo -e "    Actual:   $actual"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

assert_file_exists() {
    local test_name="$1"
    local file_path="$2"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [[ -e "$file_path" ]]; then
        echo -e "  ${GREEN}✅ $test_name${RESET}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "  ${RED}❌ $test_name${RESET}"
        echo -e "    File not found: $file_path"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

assert_file_not_exists() {
    local test_name="$1"
    local file_path="$2"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [[ ! -e "$file_path" ]]; then
        echo -e "  ${GREEN}✅ $test_name${RESET}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "  ${RED}❌ $test_name${RESET}"
        echo -e "    File still exists: $file_path"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

# Test directory setup
setup_test_env() {
    echo -e "${BLUE}🔧 Setting up test environment${RESET}"
    TEST_DIR="$TOOLBOX_ROOT/test_temp"
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
    echo "Test content" > test_file.txt
    mkdir -p test_dir
    echo "Nested content" > test_dir/nested_file.txt
}

cleanup_test_env() {
    echo -e "${BLUE}🧹 Cleaning up test environment${RESET}"
    cd "$TOOLBOX_ROOT"
    rm -rf "$TEST_DIR"
}

# Test individual functions
test_create() {
    echo -e "${CYAN}📄 Testing create function${RESET}"
    
    # Test creating a file
    source "$LIB/create.sh"
    create_item "new_file.txt" > /dev/null 2>&1
    assert_file_exists "Create file" "new_file.txt"
    
    # Test creating a directory
    create_item "new_dir/" > /dev/null 2>&1
    assert_file_exists "Create directory" "new_dir"
    
    # Test creating nested structure
    create_item "nested/path/file.js" > /dev/null 2>&1
    assert_file_exists "Create nested file" "nested/path/file.js"
    
    # Test absolute path (should be relative to current dir)
    create_item "/absolute/path/file.txt" > /dev/null 2>&1
    assert_file_exists "Create absolute path" "absolute/path/file.txt"
    
    # Test app creation help
    local output=$(create_item "-a" 2>&1)
    assert "App creation help" "true" "$(echo "$output" | grep -q "Available app types" && echo "true" || echo "false")"
    
    # Test app creation with missing name
    local output=$(create_item "-a" "vite" 2>&1)
    assert "App creation missing name" "true" "$(echo "$output" | grep -q "App name required" && echo "true" || echo "false")"
    
    # Test unknown app type
    local output=$(create_item "-a" "unknown" "test-app" 2>&1)
    assert "Unknown app type" "true" "$(echo "$output" | grep -q "Unknown app type" && echo "true" || echo "false")"
}

test_delete() {
    echo -e "${CYAN}🗑️  Testing delete function${RESET}"
    
    # Create test files
    touch delete_test.txt
    mkdir -p delete_test_dir
    touch delete_test_dir/file.txt
    
    source "$LIB/delete.sh"
    
    # Test deleting a file
    delete_item "delete_test.txt" > /dev/null 2>&1
    assert_file_not_exists "Delete file" "delete_test.txt"
    
    # Test deleting a directory
    delete_item "delete_test_dir" > /dev/null 2>&1
    assert_file_not_exists "Delete directory" "delete_test_dir"
}

test_move() {
    echo -e "${CYAN}📦 Testing move function${RESET}"
    
    # Create test files
    echo "move test" > move_source.txt
    mkdir -p move_dest
    
    source "$LIB/move.sh"
    
    # Test moving a file
    move_item "move_source.txt" "move_dest/" > /dev/null 2>&1
    assert_file_exists "Move file to directory" "move_dest/move_source.txt"
    assert_file_not_exists "Source file removed" "move_source.txt"
    
    # Test moving to new path
    echo "move test 2" > move_source2.txt
    move_item "move_source2.txt" "move_dest/renamed.txt" > /dev/null 2>&1
    assert_file_exists "Move and rename file" "move_dest/renamed.txt"
}

test_copy() {
    echo -e "${CYAN}📋 Testing copy function${RESET}"
    
    # Create test files
    echo "copy test" > copy_source.txt
    mkdir -p copy_dest
    
    source "$LIB/copy.sh"
    
    # Test copying a file
    copy_item "copy_source.txt" "copy_dest/" > /dev/null 2>&1
    assert_file_exists "Copy file to directory" "copy_dest/copy_source.txt"
    assert_file_exists "Source file preserved" "copy_source.txt"
    
    # Test copying directory
    mkdir -p copy_source_dir
    echo "nested content" > copy_source_dir/file.txt
    copy_item "copy_source_dir" "copy_dest/" > /dev/null 2>&1
    assert_file_exists "Copy directory" "copy_dest/copy_source_dir"
    assert_file_exists "Copy nested file" "copy_dest/copy_source_dir/file.txt"
}

test_list() {
    echo -e "${CYAN}📋 Testing list function${RESET}"
    
    # Create test files
    mkdir -p list_test
    echo "file1" > list_test/file1.txt
    echo "file2" > list_test/file2.txt
    mkdir -p list_test/subdir
    
    source "$LIB/list.sh"
    
    # Test basic listing
    local output=$(list_items "list_test" 2>/dev/null)
    assert "List directory contents" "true" "$(echo "$output" | grep -q "list_test" && echo "true" || echo "false")"
}

test_size() {
    echo -e "${CYAN}📊 Testing size function${RESET}"
    
    # Create test file with known content
    echo "This is test content for size testing" > size_test.txt
    
    source "$LIB/size.sh"
    
    # Test file size
    local output=$(get_size "size_test.txt" 2>/dev/null)
    assert "Get file size" "true" "$(echo "$output" | grep -q "Size:" && echo "true" || echo "false")"
    
    # Test directory size
    local output=$(get_size "." 2>/dev/null)
    assert "Get directory size" "true" "$(echo "$output" | grep -q "Size:" && echo "true" || echo "false")"
}

test_find() {
    echo -e "${CYAN}🔍 Testing find function${RESET}"
    
    # Create test files
    mkdir -p find_test
    echo "content" > find_test/file1.txt
    echo "content" > find_test/file2.txt
    echo "content" > find_test/file3.doc
    
    source "$LIB/find.sh"
    
    # Test finding files by pattern
    local output=$(find_files "*.txt" "find_test" 2>/dev/null)
    assert "Find files by pattern" "true" "$(echo "$output" | grep -q "Found" && echo "true" || echo "false")"
}

test_info() {
    echo -e "${CYAN}ℹ️  Testing info function${RESET}"
    
    # Create test file
    echo "Test content for info" > info_test.txt
    
    source "$LIB/info.sh"
    
    # Test file info
    local output=$(show_info "info_test.txt" 2>/dev/null)
    assert "Show file info" "true" "$(echo "$output" | grep -q "File Information" && echo "true" || echo "false")"
    
    # Test directory info
    local output=$(show_info "." 2>/dev/null)
    assert "Show directory info" "true" "$(echo "$output" | grep -q "File Information" && echo "true" || echo "false")"
}

test_rename() {
    echo -e "${CYAN}🔄 Testing rename function${RESET}"
    
    # Create test file
    echo "rename test" > rename_old.txt
    
    source "$LIB/rename.sh"
    
    # Test renaming file
    rename_item "rename_old.txt" "rename_new.txt" > /dev/null 2>&1
    assert_file_exists "Renamed file exists" "rename_new.txt"
    assert_file_not_exists "Old file removed" "rename_old.txt"
}

test_update() {
    echo -e "${CYAN}🔄 Testing update function${RESET}"
    
    # Create test file
    echo "update test" > update_test.txt
    local original_time=$(stat -c %Y update_test.txt)
    
    source "$LIB/update.sh"
    
    # Test touch update
    update_item "update_test.txt" "touch" > /dev/null 2>&1
    local new_time=$(stat -c %Y update_test.txt)
    # Check if timestamp was updated (new_time should be greater than or equal to original_time)
    if [[ $new_time -ge $original_time ]]; then
        assert "Update file timestamp" "true" "true"
    else
        assert "Update file timestamp" "true" "false"
    fi
    
    # Test backup
    update_item "update_test.txt" "backup" > /dev/null 2>&1
    assert_file_exists "Backup file created" "update_test.txt.backup."*
}

test_help() {
    echo -e "${CYAN}❓ Testing help function${RESET}"
    
    source "$LIB/help.sh"
    
    # Test help output
    local output=$(show_help 2>/dev/null)
    assert "Show help" "true" "$(echo "$output" | grep -q "Toolbox" && echo "true" || echo "false")"
}

# Main test runner
main() {
    test_start
    
    setup_test_env
    
    # Run all tests
    test_create
    test_delete
    test_move
    test_copy
    test_list
    test_size
    test_find
    test_info
    test_rename
    test_update
    test_help
    
    cleanup_test_env
    test_end
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 