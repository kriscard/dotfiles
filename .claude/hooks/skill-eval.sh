#!/bin/bash
# Skill activation hook - reinforces CLAUDE.md skill evaluation rule.
# Runs on UserPromptSubmit. Kept short for higher compliance rate.
# Cost: ~30 input tokens per prompt.
cat << 'EOF'
REMINDER: Check available skills for this request. If any match, call Skill() before implementing.
EOF
