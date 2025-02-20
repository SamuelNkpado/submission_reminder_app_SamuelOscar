#!/bin/bash
# create_environment.sh
# This script sets up the directory structure for the submission_reminder_app.

# Step 1: Prompt the user for their name and set the directory name
read -p "Enter your name: " userName
dirName="submission_reminder_${userName}"

# Step 2: Create the main application directory and change into it
mkdir -p "$dirName"
cd "$dirName" || { echo "Failed to change directory to $dirName"; exit 1; }

# Step 3: Create the required subdirectories using -p to avoid errors if they exist
mkdir -p app modules assets config

# Step 4: Create the reminder script in app/
cat > app/reminder.sh << 'EOF'
#!/bin/bash

# Get the script's directory (absolute path)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source environment variables and helper functions
source "$SCRIPT_DIR/../config/config.env"
source "$SCRIPT_DIR/../modules/functions.sh"

# Path to the submissions file
submissions_file="$SCRIPT_DIR/../assets/submissions.txt"

# Print remaining time and run the reminder function
echo "Assignment: $ASSIGNMENT"
echo "Days remaining to submit: $DAYS_REMAINING days"
echo "--------------------------------------------"

check_submissions "$submissions_file"
EOF

# Step 5: Create the helper functions file in modules/
cat > modules/functions.sh << 'EOF'
#!/bin/bash

# Function to read submissions file and output students who have not submitted
function check_submissions {
    local submissions_file=$1
    echo "Checking submissions in $submissions_file"

    # Skip the header and iterate through the lines
    while IFS=, read -r student assignment status; do
        # Remove leading and trailing whitespace
        student=$(echo "$student" | xargs)
        assignment=$(echo "$assignment" | xargs)
        status=$(echo "$status" | xargs)

        # Check if assignment matches and status is 'not submitted'
        if [[ "$assignment" == "$ASSIGNMENT" && "$status" == "not submitted" ]]; then
            echo "Reminder: $student has not submitted the $ASSIGNMENT assignment!"
        fi
    done < <(tail -n +2 "$submissions_file") # Skip the header
}


EOF

# Step 6: Create the submissions file in assets/ 
cat > assets/submissions.txt << 'EOF'
student, assignment, submission status
Chinemerem, Shell Navigation, not submitted
Chiagoziem, Git, submitted
Divine, Shell Navigation, not submitted
Anissa, Shell Basics, submitted
EOF


# Step 7: Create the configuration file in config/
cat > config/config.env << 'EOF'
# config.env - Configuration for submission_reminder_app
ASSIGNMENT="Shell Navigation"
DAYS_REMAINING=2
EOF

# Step 8: Create the startup script at the root of the app directory
cat > startup.sh << 'EOF'
#!/bin/bash
# startup.sh - Starts the submission_reminder_app

echo "Starting submission_reminder_app..."
bash app/reminder.sh
EOF

# Step 9: Make the necessary scripts executable using their proper paths
chmod +x modules/functions.sh
chmod +x app/reminder.sh
chmod +x startup.sh

echo "Environment created successfully in directory: $(pwd)"
echo "To run the application, execute: ./startup.sh"


