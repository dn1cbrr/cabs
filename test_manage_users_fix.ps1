# =============================================
# Manage Users - API Endpoint Test Script (PowerShell)
# Tests the "Invalid Response Format" fix
# =============================================

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Testing Manage Users API Fix" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$API_BASE_URL = "https://decinatransit.online/api"
$USERS_ENDPOINT = "$API_BASE_URL/users?action=get_users"

# Test counter
$TESTS_PASSED = 0
$TESTS_FAILED = 0

# Function to print test result
function Print-Result {
    param(
        [bool]$Success,
        [string]$Message
    )
    
    if ($Success) {
        Write-Host "✓ PASS: $Message" -ForegroundColor Green
        $script:TESTS_PASSED++
    } else {
        Write-Host "✗ FAIL: $Message" -ForegroundColor Red
        $script:TESTS_FAILED++
    }
}

Write-Host "Test 1: API Endpoint Reachability" -ForegroundColor Yellow
Write-Host "-----------------------------------"
try {
    $response = Invoke-WebRequest -Uri $USERS_ENDPOINT -Method Get -UseBasicParsing
    $statusCode = $response.StatusCode
    
    if ($statusCode -eq 200) {
        Print-Result -Success $true -Message "API endpoint is reachable (HTTP $statusCode)"
    } else {
        Print-Result -Success $false -Message "API endpoint returned HTTP $statusCode (expected 200)"
    }
} catch {
    Print-Result -Success $false -Message "Failed to reach API endpoint: $($_.Exception.Message)"
}
Write-Host ""

Write-Host "Test 2: Response Format Validation" -ForegroundColor Yellow
Write-Host "-----------------------------------"
try {
    $response = Invoke-RestMethod -Uri $USERS_ENDPOINT -Method Get
    $jsonResponse = $response | ConvertTo-Json -Depth 10
    
    Print-Result -Success $true -Message "Response is valid JSON"
    
    # Save response for inspection
    $jsonResponse | Out-File -FilePath "test_response.json" -Encoding UTF8
    Write-Host "   Response saved to: test_response.json" -ForegroundColor Gray
    
} catch {
    Print-Result -Success $false -Message "Response is NOT valid JSON: $($_.Exception.Message)"
    Write-Host "   Raw response: $response" -ForegroundColor Gray
}
Write-Host ""

Write-Host "Test 3: Response Structure Validation" -ForegroundColor Yellow
Write-Host "--------------------------------------"
try {
    if ($null -ne $response.success) {
        Print-Result -Success $true -Message "Response has 'success' field"
    } else {
        Print-Result -Success $false -Message "Response missing 'success' field"
    }
    
    if ($null -ne $response.data) {
        Print-Result -Success $true -Message "Response has 'data' field"
    } else {
        Print-Result -Success $false -Message "Response missing 'data' field"
    }
    
    if ($null -ne $response.data.users) {
        Print-Result -Success $true -Message "Response has 'data.users' field"
        $userCount = $response.data.users.Count
        Write-Host "   Found $userCount users" -ForegroundColor Gray
    } else {
        Print-Result -Success $false -Message "Response missing 'data.users' field"
    }
} catch {
    Print-Result -Success $false -Message "Error validating structure: $($_.Exception.Message)"
}
Write-Host ""

Write-Host "Test 4: Success Flag Validation" -ForegroundColor Yellow
Write-Host "--------------------------------"
try {
    if ($response.success -eq $true) {
        Print-Result -Success $true -Message "Success flag is true"
    } else {
        Print-Result -Success $false -Message "Success flag is $($response.success) (expected true)"
        
        if ($response.message) {
            Write-Host "   Error message: $($response.message)" -ForegroundColor Gray
        }
    }
} catch {
    Print-Result -Success $false -Message "Error checking success flag: $($_.Exception.Message)"
}
Write-Host ""

Write-Host "Test 5: User Data Structure Validation" -ForegroundColor Yellow
Write-Host "---------------------------------------"
try {
    if ($userCount -gt 0) {
        $firstUser = $response.data.users[0]
        
        $requiredFields = @("id", "username", "email", "full_name", "role")
        foreach ($field in $requiredFields) {
            if ($null -ne $firstUser.$field) {
                Print-Result -Success $true -Message "User has required field: $field"
            } else {
                Print-Result -Success $false -Message "User missing required field: $field"
            }
        }
        
        Write-Host ""
        Write-Host "   Sample user data:" -ForegroundColor Gray
        Write-Host "   ID: $($firstUser.id)" -ForegroundColor Gray
        Write-Host "   Username: $($firstUser.username)" -ForegroundColor Gray
        Write-Host "   Email: $($firstUser.email)" -ForegroundColor Gray
        Write-Host "   Full Name: $($firstUser.full_name)" -ForegroundColor Gray
        Write-Host "   Role: $($firstUser.role)" -ForegroundColor Gray
        Write-Host "   Online: $($firstUser.is_online)" -ForegroundColor Gray
        Write-Host "   Last Seen: $($firstUser.last_seen)" -ForegroundColor Gray
    } else {
        Write-Host "⚠ SKIP: No users found to validate structure" -ForegroundColor Yellow
    }
} catch {
    Print-Result -Success $false -Message "Error validating user structure: $($_.Exception.Message)"
}
Write-Host ""

Write-Host "Test 6: Optional Fields Handling" -ForegroundColor Yellow
Write-Host "---------------------------------"
try {
    if ($userCount -gt 0) {
        $firstUser = $response.data.users[0]
        $optionalFields = @("phone_number", "birthday", "license_name", "is_online", "last_seen")
        
        foreach ($field in $optionalFields) {
            if ($null -ne $firstUser.$field) {
                Write-Host "✓ Field '$field' exists (value: $($firstUser.$field))" -ForegroundColor Green
            } else {
                Write-Host "⚠ Field '$field' not present (OK if column doesn't exist)" -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "⚠ SKIP: No users found to validate optional fields" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Error checking optional fields: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

Write-Host "Test 7: Content-Type Header" -ForegroundColor Yellow
Write-Host "----------------------------"
try {
    $headers = Invoke-WebRequest -Uri $USERS_ENDPOINT -Method Get -UseBasicParsing
    $contentType = $headers.Headers["Content-Type"]
    
    if ($contentType -like "*application/json*") {
        Print-Result -Success $true -Message "Content-Type is application/json"
    } else {
        Print-Result -Success $false -Message "Content-Type is '$contentType' (expected application/json)"
    }
} catch {
    Print-Result -Success $false -Message "Error checking Content-Type: $($_.Exception.Message)"
}
Write-Host ""

Write-Host "Test 8: CORS Headers" -ForegroundColor Yellow
Write-Host "--------------------"
try {
    $corsHeader = $headers.Headers["Access-Control-Allow-Origin"]
    
    if ($corsHeader) {
        Print-Result -Success $true -Message "CORS header present: $corsHeader"
    } else {
        Print-Result -Success $false -Message "CORS header missing"
    }
} catch {
    Print-Result -Success $false -Message "Error checking CORS: $($_.Exception.Message)"
}
Write-Host ""

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Test Summary" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Passed: $TESTS_PASSED" -ForegroundColor Green
Write-Host "Failed: $TESTS_FAILED" -ForegroundColor Red
Write-Host ""

if ($TESTS_FAILED -eq 0) {
    Write-Host "✓ All tests passed! The 'Invalid Response Format' error is fixed." -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Test in Flutter app: Open User Management screen"
    Write-Host "2. Verify users load without errors"
    Write-Host "3. Test user editing and archiving features"
} else {
    Write-Host "✗ Some tests failed. Please review the errors above." -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Check database connection in api/config/database.php"
    Write-Host "2. Verify users table exists and has data"
    Write-Host "3. Check server error logs for details"
    Write-Host "4. Review test_response.json for actual API response"
}
