#!/usr/bin/env bash
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // .model.id // "unknown"')
workspace=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
branch=$(git -C "$workspace" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)

output=""

# Model
output="${output}${model}"

# Workspace (basename)
if [ -n "$workspace" ]; then
  dir=$(basename "$workspace")
  output="${output}  ${dir}"
fi

# Branch
if [ -n "$branch" ]; then
  output="${output}  ${branch}"
fi

printf "%s" "$output"
