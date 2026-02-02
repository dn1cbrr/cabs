#!/bin/bash

# =============================================
# Manage Users - API Endpoint Test Script
# Tests the "Invalid Response Format" fix
# =============================================

echo "=========================================="
echo "Testing Manage Users API Fix"
echo "=========================================="
echo ""

# Configuration
API_BASE_URL="https://decinatransit.online/api"
USERS_ENDPOINT="$API_BASE_URL/users?action=get_users"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to print test result
print_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ PASS${NC}: $2"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗ FAIL${NC}: $2"
        ((TESTS_FAILED++))
    fi
}

echo "Test 1: API Endpoint Reachability"
echo "-----------------------------------"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$USERS_ENDPOINT")
if [ "$HTTP_CODE" = "200" ]; then
    print_result 0 "API endpoint is reachable (HTTP $HTTP_CODE)"
else
    print_result 1 "API endpoint returned HTTP $HTTP_CODE (expected 200)"
fi
echo ""

echo "Test 2: Response Format Validation"
echo "-----------------------------------"
RESPONSE=$(curl -s "$USERS_ENDPOINT")

# Check if response is valid JSON
if echo "$RESPONSE" | jq empty 2>/dev/null; then
    print_result 0 "Response is valid JSON"
    
    # Save response for inspection
    echo "$RESPONSE" | jq '.' > test_response.json
    echo "   Response saved to: test_response.json"
else
    print_result 1 "Response is NOT valid JSON"
    echo "   Raw response: $RESPONSE"
fi
echo ""

echo "Test 3: Response Structure Validation"
echo "--------------------------------------"
if echo "$RESPONSE" | jq -e '.success' > /dev/null 2>&1; then
    print_result 0 "Response has 'success' field"
else
    print_result 1 "Response missing 'success' field"
fi

if echo "$RESPONSE" | jq -e '.data' > /dev/null 2>&1; then
    print_result 0 "Response has 'data' field"
else
    print_result 1 "Response missing 'data' field"
fi

if echo "$RESPONSE" | jq -e '.data.users' > /dev/null 2>&1; then
    print_result 0 "Response has 'data.users' field"
    
    USER_COUNT=$(echo "$RESPONSE" | jq '.data.users | length')
    echo "   Found $USER_COUNT users"
else
    print_result 1 "Response missing 'data.users' field"
fi
echo ""

echo "Test 4: Success Flag Validation"
echo "--------------------------------"
SUCCESS=$(echo "$RESPONSE" | jq -r '.success')
if [ "$SUCCESS" = "true" ]; then
    print_result 0 "Success flag is true"
else
    print_result 1 "Success flag is $SUCCESS (expected true)"
    
    # Check for error message
    ERROR_MSG=$(echo "$RESPONSE" | jq -r '.message // "No error message"')
    echo "   Error message: $ERROR_MSG"
fi
echo ""

echo "Test 5: User Data Structure Validation"
echo "---------------------------------------"
if [ "$USER_COUNT" -gt 0 ]; then
    # Check first user has required fields
    FIRST_USER=$(echo "$RESPONSE" | jq '.data.users[0]')
    
    REQUIRED_FIELDS=("id" "username" "email" "full_name" "role")
    for field in "${REQUIRED_FIELDS[@]}"; do
        if echo "$FIRST_USER" | jq -e ".$field" > /dev/null 2>&1; then
            print_result 0 "User has required field: $field"
        else
            print_result 1 "User missing required field: $field"
        fi
    done
    
    echo ""
    echo "   Sample user data:"
    echo "$FIRST_USER" | jq '{id, username, email, full_name, role, is_online, last_seen}'
else
    echo -e "${YELLOW}⚠ SKIP${NC}: No users found to validate structure"
fi
echo ""

echo "Test 6: Optional Fields Handling"
echo "---------------------------------"
if [ "$USER_COUNT" -gt 0 ]; then
    OPTIONAL_FIELDS=("phone_number" "birthday" "license_name" "is_online" "last_seen")
    for field in "${OPTIONAL_FIELDS[@]}"; do
        if echo "$FIRST_USER" | jq -e "has(\"$field\")" > /dev/null 2>&1; then
            VALUE=$(echo "$FIRST_USER" | jq -r ".$field")
            echo -e "${GREEN}✓${NC} Field '$field' exists (value: $VALUE)"
        else
            echo -e "${YELLOW}⚠${NC} Field '$field' not present (OK if column doesn't exist)"
        fi
    done
else
    echo -e "${YELLOW}⚠ SKIP${NC}: No users found to validate optional fields"
fi
echo ""

echo "Test 7: Content-Type Header"
echo "----------------------------"
CONTENT_TYPE=$(curl -s -I "$USERS_ENDPOINT" | grep -i "content-type" | cut -d' ' -f2- | tr -d '\r')
if echo "$CONTENT_TYPE" | grep -q "application/json"; then
    print_result 0 "Content-Type is application/json"
else
    print_result 1 "Content-Type is '$CONTENT_TYPE' (expected application/json)"
fi
echo ""

echo "Test 8: CORS Headers"
echo "--------------------"
CORS_HEADER=$(curl -s -I "$USERS_ENDPOINT" | grep -i "access-control-allow-origin" | cut -d' ' -f2- | tr -d '\r')
if [ -n "$CORS_HEADER" ]; then
    print_result 0 "CORS header present: $CORS_HEADER"
else
    print_result 1 "CORS header missing"
fi
echo ""

echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed! The 'Invalid Response Format' error is fixed.${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Test in Flutter app: Open User Management screen"
    echo "2. Verify users load without errors"
    echo "3. Test user editing and archiving features"
    exit 0
else
    echo -e "${RED}✗ Some tests failed. Please review the errors above.${NC}"
    echo ""
    echo "Troubleshooting:"
    echo "1. Check database connection in api/config/database.php"
    echo "2. Verify users table exists and has data"
    echo "3. Check server error logs for details"
    echo "4. Review test_response.json for actual API response"
    exit 1
fi
