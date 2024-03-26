# CSV File Change Notifier for Google Chat

This PowerShell script monitors a specific CSV file for any changes and sends a notification to a Google Chat space via a webhook when changes are detected. It's designed for environments where immediate notifications of file updates are crucial, such as for teams relying on real-time data updates.

## Features

- **File Monitoring**: Watches for any changes in the specified CSV file within a Windows environment.
- **Instant Notifications**: Sends formatted messages to a Google Chat space, including the timestamp of the change and sorted values from a specific column (`SFKEY`) of the CSV.
- **Easy Customization**: Simple to modify for different file paths, names, or to monitor different data points within the CSV.

## Requirements

- Windows environment with PowerShell.
- Access to the file system where the CSV is stored.
- A Google Chat space and permission to create webhooks.

## Setting Up Your Google Chat Space Webhook

To receive notifications in your Google Chat space, you must create a webhook:

1. **Create or choose a Google Chat space** where you want to receive notifications.
2. **Open the space**, click on the space name at the top, then click on **Manage webhooks**.
3. **Create a new webhook**: Give it a name and optionally a custom avatar. Copy the generated webhook URL.
4. **Configure the script** by replacing the `$script:WEBHOOK_URL` variable's value with your copied webhook URL.

This webhook URL is a unique address that allows the script to securely send messages to your Google Chat space.

## Installation

1. Copy the script to a `.ps1` file on your local system, e.g., `NotifyGoogleChatOnFileChange.ps1`.
2. Ensure the `$path` and `$filter` variables within the script match the directory path and filename of the CSV file you wish to monitor.

## Running the Script as a Scheduled Task

To ensure the script runs continuously, especially after a system restart, you can set it up as a scheduled task:

1. **Open Task Scheduler** in Windows.
2. **Create a new task**: Go to `Action > Create Task...`.
3. **General tab**: Give your task a name and ensure it runs with the highest privileges.
4. **Triggers tab**: Click `New...` and select `At startup`.
5. **Actions tab**: Click `New...`, set Action to `Start a program`, and browse to the PowerShell executable, usually found at `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`.
6. In the `Add arguments (optional)` field, enter `-ExecutionPolicy Bypass -File "C:\path\to\your\NotifyGoogleChatOnFileChange.ps1"`, adjusting the path to where you saved the script.
7. **Conditions and Settings tabs**: Adjust these according to your preference.
8. **Save the task** and restart your system to test that it runs the script at startup.

## License

This script is provided "as is", without warranty of any kind, express or implied. Feel free to modify and use it as needed in your projects.

---

For more details on PowerShell scripting and scheduled tasks, refer to the official Microsoft documentation.
