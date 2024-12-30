#!/bin/bash
# This script automates the setup of the commit-msg hook on a developer's local repository.
# It sets up a central Git template directory containing the commit-msg hook script.

# Define the Git template directory path
TEMPLATE_DIR="/path/to/git-template/hooks"
HOOK_SCRIPT="commit-msg"

# Check if the Git template directory path is set
if [ -z "$TEMPLATE_DIR" ]; then
    echo "Error: TEMPLATE_DIR is not set. Please define the path to the Git template directory."
    exit 1
fi

# Create Git template directory if it does not exist
echo "Creating Git template directory..."
mkdir -p "$TEMPLATE_DIR"

# Write the commit-msg hook script into the template directory
echo "Writing commit-msg hook script to template directory..."
cat > "$TEMPLATE_DIR/$HOOK_SCRIPT" << 'EOF'
#!/bin/bash
# Get the commit message from the file
commit_msg_file=$1
commit_msg=$(cat "$commit_msg_file")

# Regex pattern to match JIRA issue keys
jira_pattern="^(PAMIT|CI|EPM|EIT)-[0-9]+"

# Check if the commit message starts with a JIRA key
if ! [[ "$commit_msg" =~ $jira_pattern ]]; then
    # Prompt user to enter a JIRA key
    echo "No JIRA issue key (e.g. PAMIT-1234, CI-1234, EPM-1234) found at the start of the commit message. Please add JIRA ID at the start of the commit message and commit it again."
    read -p "Please enter the JIRA issue key (e.g., PAMIT-1234): " jira_key

    # Validate the JIRA key format
    if [[ "$jira_key" =~ ^(PAMIT|CI|EPM)-[0-9]+$ ]]; then
        # Prepend the JIRA key to the commit message
        echo "$jira_key: $commit_msg" > "$commit_msg_file"
    else
        echo "Invalid JIRA issue key format. Commit aborted."
        exit 1
    fi
fi
EOF

# Make the commit-msg script executable
chmod +x "$TEMPLATE_DIR/$HOOK_SCRIPT"

# Configure Git to use the template directory
echo "Configuring Git to use the template directory..."
git config --global init.templatedir "$TEMPLATE_DIR"

# Provide instructions for developers to clone the repository
echo "Git template directory has been set up."
echo "Once this setup is complete, every time a developer clones the repository, Git will automatically copy the hooks from the template directory into their local repository's .git/hooks/ folder."
echo "To verify this, a developer can clone the repository like this:"
echo "git clone <repository_url>"

# Final message
echo "Setup complete. The commit-msg hook will be automatically applied for new clones of the repository."

# Instructions for developers to manually set up on existing clones
echo "For existing repositories, you can manually run the following command to apply the hook:"
echo "git config --local init.templatedir $TEMPLATE_DIR"
echo "Then run 'git init' to set up the hooks in your local repository."
