lfcd() {
  local last_directory
  last_directory="$(command lf -print-last-dir "$@")"

  if [[ -n "$last_directory" && "$last_directory" != "$PWD" ]]; then
    cd "$last_directory"
  fi
}
