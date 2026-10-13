# Sourced by other scripts: sets OS to the stow layer for this machine.
case "$(uname -s)" in
    Darwin) OS=darwin ;;
    Linux) OS=omarchy ;;
    *) echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac
