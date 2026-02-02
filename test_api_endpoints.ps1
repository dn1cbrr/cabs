# Test User Management API Endpoints
Write-Host "=== Testing User Management API Endpoints ===" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "https://decinatransit.online/api/users"
$response = $null

# Test 1: Get Users
Write-Host "Test 1: GET Users" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl?action=get_users" -Method GET -UseBasicParsing
    Write-Host "Success" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Gray
    $response | ConvertTo-Json -Depth 5
    Write-Host ""
} catch {
    Write-Host "Failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

# Test 2: Check response structure
Write-Host "Test 2: Verify Response Structure" -ForegroundColor Yellow
if ($null -ne $response) {
    if ($response.success -eq $true -and $null -ne $response.data -and $null -ne $response.data.users) {
        Write-Host "Response structure is correct" -ForegroundColor Green
        Write-Host "  - success: $($response.success)" -ForegroundColor Gray
        Write-Host "  - data.users exists: True" -ForegroundColor Gray
        Write-Host "  - Number of users: $($response.data.users.Count)" -ForegroundColor Gray
    } else {
        Write-Host "Response structure is incorrect" -ForegroundColor Red
        Write-Host "  Expected: {success: true, data: {users: [...]}}" -ForegroundColor Gray
    }
} else {
    Write-Host "Could not verify structure (response is null)" -ForegroundColor Yellow
}
Write-Host ""

# Test 3: Test update endpoint structure (without actually updating)
Write-Host "Test 3: Test Update Endpoint (Dry Run)" -ForegroundColor Yellow
Write-Host "  Note: This would require a valid user_id to test fully" -ForegroundColor Gray
Write-Host "  Expected response format: {success: true, data: {message: '...'}}" -ForegroundColor Gray
Write-Host ""

# Summary
Write-Host "=== Test Summary ===" -ForegroundColor Cyan
if ($null -ne $response) {
    Write-Host "API is accessible" -ForegroundColor Green
    Write-Host "Get Users endpoint tested" -ForegroundColor Green
} else {
    Write-Host "API test failed - check connection" -ForegroundColor Red
}
Write-Host "Update/Archive endpoints require manual testing with valid data" -ForegroundColor Yellow
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. Visit https://decinatransit.online/api/users/test_user_management.php" -ForegroundColor White
Write-Host "2. Apply database migration: database/fix_users_table_complete.sql" -ForegroundColor White
Write-Host "3. Test in Flutter app" -ForegroundColor White
