add_alias_to_zshrc() {
    local script_file="$1"
    local alias_name="$2"
    local zshrc="$HOME/.zshrc-aliases"

    # Ensure both parameters are provided
    if [[ -z "$script_file" || -z "$alias_name" ]]; then
        echo "❌ Usage: add_alias_to_zshrc <script_file> <alias_name>"
        return 1
    fi

    # Ensure the script file exists
    if [[ ! -f "$script_file" ]]; then
        echo "❌ Error: Script file '$script_file' not found."
        return 1
    fi

    # Convert script file path to absolute path
    local abs_path
    abs_path="$(realpath "$script_file")"

    # Check if the alias already exists in .zshrc
    if grep -qxF "alias $alias_name='$abs_path'" "$zshrc"; then
        echo "✅ Alias '$alias_name' already exists in $zshrc."
        return 0
    fi

    # Append the alias to .zshrc
    echo "alias $alias_name='$abs_path'" >> "$zshrc"
    echo "✅ Alias '$alias_name' added to $zshrc."

    # Reload Zsh configuration
    source "$zshrc"
    echo "🔄 Zsh configuration reloaded."
}

