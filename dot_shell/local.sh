#!/usr/bin/env bash
# ~/.shell/local.sh - Machine-specific configuration

# -----------------------------
# Token Management
# -----------------------------
# OpenAI token is now stored in ~/.netrc for security
# Access it with: grep "api.openai.com" ~/.netrc | awk '{print $NF}'

# If you need the token as an environment variable, uncomment this:
# export OPENAI_TOKEN=$(grep "api.openai.com" ~/.netrc 2>/dev/null | awk '{print $NF}')

# -----------------------------
# Machine-specific aliases
# -----------------------------
# Add any machine-specific aliases here

# -----------------------------
# Local PATH additions
# -----------------------------
# Add any local paths here if needed

# -----------------------------
# Additional local configuration
# -----------------------------
# Add any other machine-specific configuration here