-- clockin.lua
-- This script automates clock-in by sending a curl command to a specified URL
-- only if the current day is a workday (Monday to Friday).

-- IMPORTANT CONFIGURATION:
-- Please replace the placeholder values below with your actual details.
-- Hardcoding sensitive information like cookies directly in the script is generally
-- NOT recommended for production environments due to security risks.
-- Ensure your clock-in system's API expects the data format used in the 'curl_command'.

local TARGET_URL = "https://your-clockin-system.com/api/clockin"
-- Example: "https://mycompany.com/api/time-entry"

local COOKIE_VALUE = "sessionid=YOUR_SESSION_ID_HERE; csrftoken=YOUR_CSRF_TOKEN_HERE"
-- This string should contain all necessary cookies for authentication.
-- You can usually find this by inspecting network requests in your browser's developer tools
-- when you manually clock in. Look for the 'Cookie' header.

local CLOCK_IN_TIME = "09:00:00"
-- The desired clock-in time in HH:MM:SS format.

local OVERRIDE_DATE = os.date("%Y-%m-%d")
-- The date for the clock-in. By default, it uses the current date (YYYY-MM-DD).
-- You can manually set it to a specific date if needed, e.g., "2024-07-14"

-- Get current day of the week
-- os.date("*t") returns a table with date/time fields.
-- 'wday' field: 1 = Sunday, 2 = Monday, ..., 7 = Saturday
local current_date_table = os.date("*t")
local weekday = current_date_table.wday

-- Check if the current day is a workday (Monday to Friday)
if weekday >= 2 and weekday <= 6 then -- 2 is Monday, 6 is Friday
    print("It's a workday. Attempting to clock in at " .. CLOCK_IN_TIME .. " on " .. OVERRIDE_DATE .. "...")

    -- Construct the curl command
    -- This example assumes your clock-in API accepts JSON data via POST.
    -- You MUST adjust the '-d' (data) part to match your specific clock-in system's API requirements.
    -- Common formats include JSON, x-www-form-urlencoded, or even query parameters for GET requests.
    local curl_command = string.format(
        'curl -X POST ' ..                                  -- Use POST method
        '-b "%s" ' ..                                       -- Send cookies
        '-H "Content-Type: application/json" ' ..           -- Set content type for JSON
        '-d \'{"time": "%s", "date": "%s", "override": true}\' ' .. -- JSON payload with time, date, and an override flag
        '"%s"',                                             -- Target URL
        COOKIE_VALUE,
        CLOCK_IN_TIME,
        OVERRIDE_DATE,
        TARGET_URL
    )

    -- Execute the curl command using io.popen
    -- io.popen allows running shell commands and capturing their output.
    local handle = io.popen(curl_command, "r")
    if handle then
        local result = handle:read("*all") -- Read all output from the curl command
        handle:close()
        print("Curl command executed. Response:")
        print(result) -- Print the response from the server for debugging/confirmation
    else
        print("Failed to execute curl command. Check if 'curl' is in your PATH.")
    end
else
    print("It's not a workday. Skipping clock-in.")
end

