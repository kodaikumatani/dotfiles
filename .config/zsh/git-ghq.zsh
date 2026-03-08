# Wrap git to use ghq get instead of git clone
git() {
  if [[ "$1" == "clone" ]]; then
    shift
    ghq get "$@"
  else
    command git "$@"
  fi
}
