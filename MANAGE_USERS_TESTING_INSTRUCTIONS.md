# Manage Users - Complete Testing Instructions

## "Invalid Response Format" Error Fix - Testing Guide

---

## Quick Start

### Option 1: Automated Testing (Recommended)

**Windows (PowerShell):**
```powershell
powershell -ExecutionPolicy Bypass -File test_manage_users_fix.ps1
```

**Linux/Mac (Bash):**
```bash
chmod +x test_manage_users_fix.sh
./test_manage_users_fix.sh
```

### Option 2: Manual Browser Testing

Visit: `https://decinatransit.online/api/users?action=get_users`

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "users": [
      {
        "id": "1",
        "username": "admin",
        "email": "admin@example.com",
        "full_name": "Admin User",
        "role": "admin",
        "is_online": false,
        "last_seen": null,
        ...
      }
    ]
  }
}
```

### Option 3: cURL Testing

```bash
curl -X GET "https://decinatransit.online/api/users?action=get_users" \
  -H "Accept: application/json" \
  | jq '.'
```

---

## Detailed Testing Steps

### Step 1: API Endpoint Testing

#### Test 1.1: Basic Connectivity
```bash
curl -I https://decinatransit.online/api/users?action=get_users
```

**Expected:**
- HTTP/1.1 200 OK
- Content-Type: application/json

#### Test 1.2: Response Structure
```bash
curl https://decinatransit.online/api/users?action=get_users | jq '.success'
```

**Expected:** `true`

#### Test 1.3: Data Presence
```bash
curl https://decinatransit.online/api/users?action=get_users | jq '.data.users | length'
```

**Expected:** Number of users (e.g., `5`)

#### Test 1.4: User Fields
```bash
curl https://decinatransit.online/api/users?action=get_users | jq '.data.users[0] | keys'
```

**Expected:** Array of field names including:
- id
- username
- email
- full_name
- role
- (optional) is_online, last_seen, phone_number, etc.

---

### Step 2: Flutter App Testing

#### Test 2.1: User Management Screen Load

**Steps:**
1. Open the Transit app
2. Log in as admin
3. Navigate to: **Admin → User Management**

**Expected Results:**
- ✅ Screen loads without errors
- ✅ No "Invalid response format" error
- ✅ Loading indicator appears briefly
- ✅ User list displays
- ✅ Users show with names and roles

**If Error Occurs:**
- Note the exact error message
- Check if it's still "Invalid response format"
- Check console logs for details

#### Test 2.2: User List Display

**Verify:**
- ✅ Each user shows:
  - Full name (bold)
  - Username and role (subtitle)
  - Online status indicator (green/gray dot)
  - Last seen time (if offline)
- ✅ List is scrollable
- ✅ Refresh icon in app bar

#### Test 2.3: Pull to Refresh

**Steps:**
1. Pull down on user list
2. Release

**Expected:**
- ✅ Loading indicator appears
- ✅ List refreshes
- ✅ Success message shows user count
- ✅ No errors

#### Test 2.4: User Details Navigation

**Steps:**
1. Tap on any user in the list

**Expected:**
- ✅ Edit User screen opens
- ✅ All user fields are populated
- ✅ No errors loading user data

---

### Step 3: Edit User Testing

#### Test 3.1: View User Details

**Verify all fields display:**
- ✅ Username
- ✅ Email
- ✅ Full Name
- ✅ Phone Number
- ✅ Birthday
- ✅ License Information (if applicable)
- ✅ Role

#### Test 3.2: Update User Information

**Steps:**
1. Modify the full name
2. Tap "Save Changes"

**Expected:**
- ✅ Success message appears
- ✅ Returns to user list
- ✅ Changes are visible in list
- ✅ Pull to refresh shows updated data

#### Test 3.3: Validation Testing

**Steps:**
1. Clear the email field
2. Tap "Save Changes"

**Expected:**
- ✅ Validation error appears
- ✅ "Please enter an email" message
- ✅ Cannot save with invalid data

**Steps:**
1. Enter invalid email (e.g., "notanemail")
2. Tap "Save Changes"

**Expected:**
- ✅ Validation error appears
- ✅ "Please enter a valid email" message

---

### Step 4: Archive User Testing

#### Test 4.1: Archive Another User

**Steps:**
1. Open a user (NOT your own admin account)
2. Scroll to bottom
3. Tap "Archive User" button
4. Read confirmation dialog
5. Tap "Archive"

**Expected:**
- ✅ Confirmation dialog shows user details
- ✅ Warning message is clear
- ✅ Success message after archiving
- ✅ User disappears from list
- ✅ User count decreases

#### Test 4.2: Self-Archive Prevention

**Steps:**
1. Open your own admin account
2. Scroll to bottom

**Expected:**
- ✅ Archive button is NOT visible
- ✅ Warning message explains why
- ✅ "You cannot archive your own admin account" message

---

### Step 5: Error Handling Testing

#### Test 5.1: Network Error

**Steps:**
1. Turn off WiFi/mobile data
2. Open User Management screen
3. Observe error message
4. Turn on internet
5. Tap retry button

**Expected:**
- ✅ "No internet connection" error
- ✅ Retry button visible
- ✅ Error message is user-friendly
- ✅ Retry loads users successfully

#### Test 5.2: Empty State

**Steps:**
1. Archive all users (in test environment)
2. Refresh user list

**Expected:**
- ✅ Empty state icon shows
- ✅ "No users found" message
- ✅ Refresh button available

---

### Step 6: Edge Cases Testing

#### Test 6.1: Special Characters

**Steps:**
1. Create/edit user with name: `O'Brien <Test>`
2. Save

**Expected:**
- ✅ Saves successfully
- ✅ Displays correctly in list
- ✅ No SQL injection or XSS issues

#### Test 6.2: Long Text

**Steps:**
1. Enter very long username (50+ characters)
2. Save

**Expected:**
- ✅ Validation prevents or truncates
- ✅ UI doesn't break
- ✅ Error message if too long

#### Test 6.3: Concurrent Edits

**Steps:**
1. Have two admins open same user
2. Both make different changes
3. Both save

**Expected:**
- ✅ Last save wins
- ✅ No data corruption
- ✅ Both see updated data after refresh

---

## Test Results Checklist

### API Tests
- [ ] Endpoint returns HTTP 200
- [ ] Response is valid JSON
- [ ] Response has `success: true`
- [ ] Response has `data.users` array
- [ ] Users have all required fields
- [ ] Optional fields handled gracefully
- [ ] Content-Type is application/json
- [ ] CORS headers present

### Flutter App Tests
- [ ] User Management screen loads
- [ ] No "Invalid response format" error
- [ ] Users display in list
- [ ] Online status indicators work
- [ ] Pull to refresh works
- [ ] User details screen opens
- [ ] User editing works
- [ ] Validation works
- [ ] Archive user works
- [ ] Self-archive prevention works
- [ ] Network error handling works
- [ ] Empty state displays correctly

### Edge Cases
- [ ] Special characters handled
- [ ] Long text handled
- [ ] Concurrent edits handled
- [ ] Large user lists perform well

---

## Troubleshooting

### Issue: Still Getting "Invalid Response Format"

**Check:**
1. API endpoint returns valid JSON (test in browser)
2. Response structure matches expected format
3. Database connection is working
4. Users table exists and has data

**Debug:**
```bash
# Check API response
curl https://decinatransit.online/api/users?action=get_users | jq '.'

# Check for HTML error pages
curl https://decinatransit.online/api/users?action=get_users | head -n 1
```

### Issue: Users Not Loading

**Check:**
1. Database has users
2. Users table has required columns
3. No database errors in server logs

**Debug:**
```sql
-- Check users exist
SELECT COUNT(*) FROM users;

-- Check table structure
DESCRIBE users;
```

### Issue: Missing Fields

**Check:**
1. Database columns exist
2. Migration was applied
3. API returns all fields

**Fix:**
```bash
# Apply migration
mysql -u username -p database < database/fix_users_table_complete.sql
```

### Issue: Archive Not Working

**Check:**
1. `is_archived` column exists
2. `archived_at` column exists
3. `archived_by` column exists
4. Foreign key constraint exists

**Debug:**
```sql
-- Check archive columns
SHOW COLUMNS FROM users LIKE '%archive%';
```

---

## Success Criteria

### Minimum Requirements (Must Pass)
✅ API returns valid JSON
✅ Response structure is correct
✅ User list loads without errors
✅ Users display correctly
✅ No "Invalid response format" error

### Full Functionality (Should Pass)
✅ All API tests pass
✅ All Flutter app tests pass
✅ User editing works
✅ User archiving works
✅ Error handling works
✅ Edge cases handled

### Optimal (Nice to Have)
✅ All edge case tests pass
✅ Performance is good with 100+ users
✅ UI is responsive and smooth
✅ No console warnings or errors

---

## Next Steps After Testing

### If All Tests Pass:
1. ✅ Mark task as complete
2. ✅ Update documentation
3. ✅ Deploy to production
4. ✅ Monitor for issues

### If Some Tests Fail:
1. Document which tests failed
2. Note exact error messages
3. Check troubleshooting section
4. Report issues for fixing

### If Major Issues Found:
1. Do not deploy to production
2. Document all issues
3. Prioritize critical bugs
4. Retest after fixes

---

## Test Report Template

```
# Manage Users Testing Report

Date: [DATE]
Tester: [NAME]
Environment: [Production/Staging/Local]

## API Tests
- Endpoint Reachability: [PASS/FAIL]
- Response Format: [PASS/FAIL]
- Response Structure: [PASS/FAIL]
- Success Flag: [PASS/FAIL]
- User Data: [PASS/FAIL]
- Optional Fields: [PASS/FAIL]
- Headers: [PASS/FAIL]

## Flutter App Tests
- Screen Load: [PASS/FAIL]
- User List: [PASS/FAIL]
- Pull to Refresh: [PASS/FAIL]
- User Details: [PASS/FAIL]
- User Edit: [PASS/FAIL]
- User Archive: [PASS/FAIL]
- Error Handling: [PASS/FAIL]

## Issues Found
1. [Issue description]
2. [Issue description]

## Overall Result
[PASS/FAIL]

## Recommendations
[Your recommendations]
```

---

## Contact & Support

If you encounter issues not covered in this guide:

1. Check server error logs
2. Check Flutter console logs
3. Review API response in browser
4. Check database connection
5. Verify all files are uploaded correctly

---

**Last Updated:** 2024-01-15
**Version:** 1.0
**Related Docs:** 
- MANAGE_USERS_DEBUG_SUMMARY.md
- MANAGE_USERS_INVALID_RESPONSE_FIX.md
- MANAGE_USERS_TESTING_REPORT.md
