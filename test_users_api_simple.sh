#!/bin/bash

# Simple API test for manage users fix
echo "Testing User Management API..."
echo ""

# Test the endpoint
echo "Fetching users from API..."
RESPONSE=$(curl -s "https://decinatransit.online/api/users?action=get_users")

# Check if response contains success
if echo "$RESPONSE" | grep -q '"success":true'; then
    echo "✓ API returned success"
else
    echo "✗ API did not return success"
    echo "Response: $RESPONSE"
    exit 1
fi

# Check if response contains data.users
if echo "$RESPONSE" | grep -q '"data"'; then
    echo "✓ Response has 'data' field"
else
    echo "✗ Response missing 'data' field"
    echo "Response: $RESPONSE"
    exit 1
fi

if echo "$RESPONSE" | grep -q '"users"'; then
    echo "✓ Response has 'users' field"
else
    echo "✗ Response missing 'users' field"
    echo "Response: $RESPONSE"
    exit 1
fi

# Save response
echo "$RESPONSE" > api_response.json
echo ""
echo "✓ All basic checks passed!"
echo "Full response saved to: api_response.json"
echo ""
echo "Next: Test in Flutter app by opening User Management screen"
