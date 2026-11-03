{ ... }:

{
  flake.modules.nixos.core-tmux =
    { pkgs, lib, ... }:
    let
      # --- SESSIONIZER HELPER ---
      tmux-sessionizer = pkgs.writeShellScriptBin "tmux-sessionizer" ''
        set -euo pipefail

        if [[ $# -eq 1 ]]; then
          selected="$1"
        else
          # Discover project directories across typical roots
          candidates=$(find -L "$HOME/dotfiles" "$HOME/projects" "$HOME/src" "$HOME/dev" -mindepth 0 -maxdepth 2 -type d 2>/dev/null || true)
          # Fallback to home if no candidates found
          if [[ -z "$candidates" ]]; then
            candidates="$HOME"
          fi
          selected=$(echo "$candidates" | sort -u | ${pkgs.fzf}/bin/fzf --tmux center,70%,60% --reverse --prompt="Select Workspace > ")
        fi

        if [[ -z "$selected" ]]; then
          exit 0
        fi

        selected_name=$(basename "$selected" | tr . _)
        tmux_running=$(pgrep tmux || true)

        if [[ -z "''${TMUX:-}" ]] && [[ -z "$tmux_running" ]]; then
          tmux new-session -s "$selected_name" -c "$selected"
          exit 0
        fi

        if ! tmux has-session -t="$selected_name" 2>/dev/null; then
          tmux new-session -ds "$selected_name" -c "$selected"
        fi

        if [[ -n "''${TMUX:-}" ]]; then
          tmux switch-client -t "$selected_name"
        else
          tmux attach-session -t "$selected_name"
        fi
      '';

      # --- DETACHED JOB RUNNER HELPER ---
      # TODO: Consider using zsh instead of bash here
      # TODO: Add support for multiple remote hosts
      # TODO: Look into https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/programs/jobrun/default.nix
      job-run = pkgs.writeShellScriptBin "job-run" ''
        set -euo pipefail

        usage() {
          cat <<EOF
Usage: job-run [-s|--session <name>] [-a|--attach] <command...>

Runs a command inside a detached, persistent tmux session with logging and notifications.

Options:
  -s, --session <name>   Specify custom tmux session name (default: sanitized command)
  -a, --attach           Attach to the session immediately after spawning
  -h, --help             Display this help message
EOF
          exit 1
        }

        SESSION_NAME=""
        ATTACH=0

        while [[ $# -gt 0 ]]; do
          case "$1" in
            -s|--session)
              SESSION_NAME="$2"
              shift 2
              ;;
            -a|--attach)
              ATTACH=1
              shift
              ;;
            -h|--help)
              usage
              ;;
            --)
              shift
              break
              ;;
            *)
              break
              ;;
          esac
        done

        if [[ $# -eq 0 ]]; then
          echo "Error: No command specified." >&2
          usage
        fi

        COMMAND="$*"

        if [[ -z "$SESSION_NAME" ]]; then
          # Generate clean alphanumeric session name from command
          CLEAN_CMD=$(echo "$1" | tr -cd '[:alnum:]_-')
          SESSION_NAME="job-''${CLEAN_CMD:-task}-$(date +%s)"
        fi

        LOG_DIR="$HOME/.local/state/tmux-jobs"
        mkdir -p "$LOG_DIR"
        LOG_FILE="$LOG_DIR/''${SESSION_NAME}-$(date +%Y%m%d_%H%M%S).log"

        # Create temporary execution wrapper script
        RUNNER_SCRIPT=$(mktemp /tmp/job-run-XXXXXX.sh)
        cat <<INNER > "$RUNNER_SCRIPT"
#!/usr/bin/env bash
SESSION="$SESSION_NAME"
LOG="$LOG_FILE"
CMD=\$(cat <<'EOINNER'
$COMMAND
EOINNER
)

echo -e "\033[1;34m=================================================================\033[0m"
echo -e "\033[1;36m▶ Running Job:\033[0m \$CMD"
echo -e "\033[1;36m▶ Session:    \033[0m \$SESSION"
echo -e "\033[1;36m▶ Log file:   \033[0m \$LOG"
echo -e "\033[1;34m=================================================================\033[0m"
echo ""

START_TIME=\$(date +%s)
eval "\$CMD" 2>&1 | tee -a "\$LOG"
EXIT_CODE=\''${PIPESTATUS[0]}
END_TIME=\$(date +%s)
DURATION=\$((END_TIME - START_TIME))

echo ""
echo -e "\033[1;34m=================================================================\033[0m"
if [[ \$EXIT_CODE -eq 0 ]]; then
  echo -e "\033[1;32m✔ [SUCCESS]\033[0m Completed in \''${DURATION}s with exit code 0."
  STATUS_TITLE="Job Succeeded: \$SESSION"
  URGENCY="normal"
else
  echo -e "\033[1;31m✖ [FAILED]\033[0m Terminated with exit code \$EXIT_CODE after \''${DURATION}s."
  STATUS_TITLE="Job Failed: \$SESSION"
  URGENCY="critical"
fi
echo -e "\033[1;36m▶ Log retained at:\033[0m \$LOG"
echo -e "\033[1;34m=================================================================\033[0m"

# Desktop notification & terminal bell
printf '\a' 2>/dev/null || true
if command -v notify-send >/dev/null 2>&1; then
  notify-send -u "\$URGENCY" -a "job-run" "\$STATUS_TITLE" "Finished in \''${DURATION}s with exit code \$EXIT_CODE\nLog: \$LOG" 2>/dev/null || true
fi

echo ""
read -r -p "Press [Enter] to close this window..."
rm -f "$RUNNER_SCRIPT"
INNER
        chmod +x "$RUNNER_SCRIPT"

        # Launch detached tmux session running the wrapper script
        tmux new-session -d -s "$SESSION_NAME" "$RUNNER_SCRIPT"

        echo -e "\033[1;32m✔ Job spawned in tmux session:\033[0m \033[1m$SESSION_NAME\033[0m"
        echo -e "\033[1;34m  • Log file:   \033[0m $LOG_FILE"
        echo -e "\033[1;34m  • To attach:  \033[0m tmux attach -t $SESSION_NAME"
        echo -e "\033[1;34m  • To detach:  \033[0m Press \033[1mCtrl-Space\033[0m then \033[1md\033[0m"

        if [[ $ATTACH -eq 1 ]]; then
          tmux attach-session -t "$SESSION_NAME"
        fi
      '';

      # --- SSH SAFE REMOTE ATTACH HELPER ---
      ssh-tmux = pkgs.writeShellScriptBin "ssh-tmux" ''
        set -euo pipefail

        if [[ $# -lt 1 ]]; then
          echo "Usage: ssh-tmux <target-host> [tmux-session-name]" >&2
          exit 1
        fi

        TARGET="$1"
        REMOTE_SESSION="''${2:-main}"
        shift || true
        EXTRA_ARGS=("$@")

        echo "Connecting to $TARGET with persistent tmux session '$REMOTE_SESSION'..."
        exec ssh -t "''${EXTRA_ARGS[@]}" "$TARGET" "tmux new-session -A -s $REMOTE_SESSION"
      '';
    in
    {
      programs.tmux = {
        enable = true;
        shortcut = "Space";
        baseIndex = 1;
        escapeTime = 0;
        keyMode = "vi";
        terminal = "tmux-256color";
        historyLimit = 50000;
        clock24 = true;

        plugins = with pkgs.tmuxPlugins; [
          tokyo-night-tmux
          resurrect
          continuum
          yank
          vim-tmux-navigator
        ];

        extraConfig = ''
          # --- GENERAL ERGONOMICS ---
          set -g mouse on
          set -g renumber-windows on
          set -g status-position bottom
          set -s set-clipboard on

          # Intuitive splits in current working directory
          bind | split-window -h -c "#{pane_current_path}"
          bind - split-window -v -c "#{pane_current_path}"
          bind c new-window -c "#{pane_current_path}"
          unbind '"'
          unbind %

          # Vi copy-mode keybindings
          bind -T copy-mode-vi v send-keys -X begin-selection
          bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel

          # Continuum & Resurrect automation
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15'
          set -g @resurrect-capture-pane-contents 'on'

          # Tokyo Night theme styling overrides
          set -g @tokyo-night-tmux_window_id_style digital
          set -g @tokyo-night-tmux_pane_id_style hsquare
          set -g @tokyo-night-tmux_zoom_id_style dsquare
          set -g @tokyo-night-tmux_show_datetime 1
          set -g @tokyo-night-tmux_date_format YMD
          set -g @tokyo-night-tmux_time_format 24H

          # Fuzzy session manager binding
          bind-key f run-shell "${tmux-sessionizer}/bin/tmux-sessionizer"
        '';
      };

      environment.systemPackages = with pkgs; [
        fzf
        libnotify
        tmux-sessionizer
        job-run
        ssh-tmux
      ];
    };
}
