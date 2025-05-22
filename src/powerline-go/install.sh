#!/bin/sh
set -e

echo "Activating feature 'powerline-go' version $VERSION"

GOBIN=/usr/local/go/bin go install github.com/justjanne/powerline-go@$VERSION

GREETING=${GREETING:-undefined}
echo "The provided greeting is: $GREETING"

# The 'install.sh' entrypoint script is always executed as the root user.
#
# These following environment variables are passed in by the dev container CLI.
# These may be useful in instances where the context of the final 
# remoteUser or containerUser is useful.
# For more details, see https://containers.dev/implementors/features#user-env-var
echo "The effective dev container remoteUser is '$_REMOTE_USER'"
echo "The effective dev container remoteUser's home directory is '$_REMOTE_USER_HOME'"

echo "The effective dev container containerUser is '$_CONTAINER_USER'"
echo "The effective dev container containerUser's home directory is '$_CONTAINER_USER_HOME'"

cat > "${_REMOTE_USER_HOME}/.bash_powerline" \
<< EOF
#!/bin/bash
function _update_ps1() {
    PS1="\$(powerline-go -colorize-hostname -theme ${POWERLINE_THEME} -modules '${POWERLINE_MODULES}' -error \$? -jobs \$(jobs -p | wc -l))"

    # Uncomment the following line to automatically clear errors after showing
    # them once. This not only clears the error for powerline-go, but also for
    # everything else you run in that shell. Don't enable this if you're not
    # sure this is what you want.

    #set "?"
}

[[ "$TERM" != "linux" ]] && [[ -f "$(which powerline-go)" ]] && {
    PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
}
EOF

# Define the snippet to add to a login shell file
SNIPPET="source $_REMOTE_USER_HOME/.bash_powerline"

# Function to check if snippet already exists in file
snippet_exists() {
    local file="$1"
    grep -Fq "$SNIPPET" "$file" 2>/dev/null
}

TARGET_FILE="$_REMOTE_USER_HOME/.bashrc"

# Check if snippet already exists
if snippet_exists "$TARGET_FILE"; then
    echo "Snippet already exists in $TARGET_FILE"
else
    # Append the snippet with proper newlines
    echo "\n\n$SNIPPET" | tee -a "$TARGET_FILE" > /dev/null
    echo "Added snippet to $TARGET_FILE"
fi
