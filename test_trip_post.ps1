# Test script for trip adding POST request
$body = @{
    driver_id = 1
    trip_date = "2024-01-15"
    start_time = "2024-01-15T08:00:00"
    route_details = "Test route from Manila to Quezon City"
    total_passengers = 5
} | ConvertTo-Json

Write-Host "Testing POST request to trips endpoint..."
Write-Host "Request body: $body"
Write-Host ""

try {
    $response = Invoke-WebRequest -Uri "http://localhost/transit/api/drivers/trips/add.php" -Method POST -Body $body -Headers @{"Content-Type"="application/json"}
    Write-Host "✅ SUCCESS - Status Code: $($response.StatusCode)"
    Write-Host "Response: $($response.Content)"
} catch {
    Write-Host "❌ ERROR - Status Code: $($_.Exception.Response.StatusCode.value__)"
    Write-Host "Error Message: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response Body: $responseBody"
    }
}
