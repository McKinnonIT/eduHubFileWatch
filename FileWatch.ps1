<#
.SYNOPSIS
Monitors a specified CSV file for changes and sends a notification with updated content via a webhook to Google Chat.

.DESCRIPTION
This script sets up a FileSystemWatcher to monitor a specific CSV file for any changes (e.g., modifications, deletions).
When a change is detected, the script reads the updated content of the CSV file, specifically the 'SFKEY' values, sorts them, 
and sends a notification containing these values along with a timestamp to a predefined webhook URL. The script is designed 
to run indefinitely, repeatedly checking for file changes every second.

.PARAMETERS
No parameters are directly taken by the script, but it has configurable variables within the script body:
- $path: The directory path where the target CSV file is located.
- $filter: The name of the CSV file to monitor.
- $WEBHOOK_URL: The URL of the webhook to which notifications will be sent.

.EXAMPLE
# No explicit example usage as the script is designed to be run as is. 
# However, to use, ensure that the $path, $filter, and $WEBHOOK_URL variables are set to your specific requirements.

.NOTES
- The script uses a global variable ($script:WEBHOOK_URL) to store the webhook URL. This URL includes the key and token query parameters for authentication.
- To prevent multiple triggers for the same event (e.g., during rapid file changes), consider implementing a debounce mechanism (not included in this script).
- Before the script sets up a new event subscriber, it attempts to unregister any existing subscriber with the same source identifier ("WatchStaffDelta") to avoid duplicate event handlers.

.LINK
For more information on PowerShell scripting and FileSystemWatcher:
- https://docs.microsoft.com/en-us/powershell/
- https://docs.microsoft.com/en-us/dotnet/api/system.io.filesystemwatcher?view=net-5.0

#>


# Webhook URL for sending notifications
$script:WEBHOOK_URL = "GOOGLE_CHAT_SPACE_WEBHOOK_URL"

# Unregister any previous event subscriptions with the same source identifier to avoid duplicates
Get-EventSubscriber -SourceIdentifier "WatchStaffDelta" | Unregister-Event

# Define the path of the directory containing the file to be monitored
$path = 'D:\eduHub'

# Define the specific file to monitor within the specified path
$filter = 'SF_8125_D.csv'

# Create a FileSystemWatcher object to watch for changes in the specified file
$fsw = New-Object IO.FileSystemWatcher $path, $filter -Property @{
    IncludeSubdirectories = $false # Only monitor the specified directory, not subdirectories
    EnableRaisingEvents   = $true    # Start raising events immediately
}

# Define the action to take when a change is detected in the specified file
$action = {
    param($source, $event)    
    
    # Import the modified file and extract the SFKEY column, sort the keys
    $SF_Keys = $(Import-Csv "$path\$filter").SFKEY | Sort

    # Prepare the message body with a timestamp, file name, and the sorted SFKEYs
    $timestamp = Get-Date -Format 'yyyy-MM-dd hh:mm:ss'
    $bodyText =
    @"
*$timestamp*
Staff Delta ($filter) has been modified.
$SF_Keys
"@ # Multiline string with embedded variable content
    $body = @{
        text = "$bodyText" # The text to send in the webhook payload
    }

    # Send a POST request to the webhook URL with the prepared message as JSON
    Invoke-RestMethod -Uri $script:WEBHOOK_URL -Method Post -Body ($body | ConvertTo-Json) -ContentType 'application/json'
}

# Register the defined action as an event handler for changes detected by the FileSystemWatcher
# and assign a unique source identifier for managing the event subscription
Register-ObjectEvent $fsw Changed -Action $action -SourceIdentifier "WatchStaffDelta"

# Run an infinite loop to keep the script running, allowing the FileSystemWatcher to monitor for changes
# The loop sleeps for 1 second between iterations to yield CPU time
while ($true) {
    Start-Sleep -Seconds 1
}
