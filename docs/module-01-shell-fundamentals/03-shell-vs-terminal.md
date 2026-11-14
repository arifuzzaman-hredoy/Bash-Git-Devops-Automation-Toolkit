# 03 — Shell vs Terminal

[← Previous: What is Bash?](02-what-is-bash.md) | [Module index](README.md) | [Next: Bash vs Other Shells →](04-bash-vs-other-shells.md)

## 1. Overview

People often say "terminal" and "shell" as if they were the same thing. They are different layers. The **terminal** is the window or device that displays text and captures keystrokes; the **shell** is the program that interprets the commands. Understanding the split explains SSH sessions, `tty` devices, `tmux`, and why some scripts behave differently with and without a terminal attached.

## 2. Definition

- **Terminal (terminal emulator):** a program, or historically a hardware device, that provides text input and output. Modern examples: Windows Terminal, PuTTY, macOS Terminal, GNOME Terminal.
- **Shell:** the command interpreter that runs inside the terminal (Bash, dash, zsh and others).
- **Console:** the system's primary physical or virtual text interface (for example a VM's serial console or the EC2 serial console).
- **TTY (teletypewriter):** the kernel's terminal device abstraction, such as `/dev/tty1` or `/dev/pts/0`.
- **PTY (pseudo-terminal):** a software pair of devices (master and slave) that emulates a terminal; terminal emulators and `sshd` use it.

## 3. Detailed Explanation

### The layers

```text
 Your Windows PC                                    EC2 instance
┌──────────────────────────┐        SSH         ┌──────────────────────────────┐
│ Terminal emulator /      │  encrypted channel │ sshd                         │
│ OpenSSH client           │ ◄────────────────► │   │ allocates a PTY          │
└──────────────────────────┘                    │   ▼                          │
   shows text, sends keys                       │ /dev/pts/0 ◄► bash (shell)   │
                                                └──────────────────────────────┘
```

When you connect with SSH from Windows, your terminal program (Windows Terminal, PowerShell with OpenSSH, PuTTY) runs locally and displays the output. The shell runs on the **EC2 instance**, attached to a pseudo-terminal created by `sshd`.

### Related concepts

- **Terminal multiplexers** (`tmux`, `screen`) sit between the terminal and shell so sessions survive disconnects.
- **PowerShell** on Windows is itself a shell; Windows Terminal is a terminal that can host PowerShell, Command Prompt or an SSH session.
- A terminal can host **any** shell, and a shell can run in **any** terminal.
- Programs can detect whether they are attached to a terminal (`[ -t 0 ]`) and change behaviour, for example disabling colours or prompts when output is piped or run from cron.

### Control characters

The terminal's line discipline handles configured control characters: by default, `Ctrl+C` generates `SIGINT`, `Ctrl+Z` generates `SIGTSTP`, and `Ctrl+D` signals EOF to a read when the input buffer is empty. `Ctrl+S`/`Ctrl+Q` pause and resume terminal output when software flow control (`IXON`) is enabled.

## 4. How It Works

1. You type a key in your terminal emulator on Windows.
2. The SSH client sends it, encrypted, to `sshd` on EC2.
3. `sshd` writes it to the master side of a PTY.
4. The kernel's TTY layer passes it (after line-discipline processing) to the shell reading the slave side, e.g. `/dev/pts/0`.
5. The shell executes the command; output goes back through the PTY, over SSH and is drawn by your terminal.

Running `ssh host command` without `-t` normally allocates **no** PTY, so the remote command sees no terminal.

## 5. Why It Matters in DevOps

- Knowing where the shell actually runs (on the server) avoids confusion about local vs remote paths and environments.
- Scripts must behave correctly with no TTY: cron, CI runners, `ssh host cmd`, EC2 user-data and Docker builds have none. Commands that prompt for input will hang or fail there.
- `tmux` or `screen` protects long-running work from dropped connections.
- Interactive tools (`sudo` password prompts, `vim`, `top`) need a TTY; automation must use non-interactive alternatives.
- Terminal-related variables (`TERM`, `COLUMNS`) influence how tools format output and logs.

## 6. Syntax and Commands

```bash
tty                              # terminal device of this session
echo "$TERM"                     # terminal type
ps -o pid,tty,comm -p $$         # shell process and its terminal
who                              # users and their terminals
stty -a | head -n 1              # terminal line settings (first line)
[ -t 0 ] && echo "stdin is a terminal" || echo "stdin is not a terminal"
[ -t 1 ] && echo "stdout is a terminal" || echo "stdout is not a terminal"
ssh -t user@host 'command'       # force a PTY for a remote command (run from your PC)
```

## 7. Command-by-Command Explanation

| Command | Explanation |
|---------|-------------|
| `tty` | Prints the file name of the terminal connected to standard input, such as `/dev/pts/0`. Prints `not a tty` if there is none. |
| `echo "$TERM"` | Terminal type used by programs to choose control sequences (for example `xterm-256color`). |
| `ps -o pid,tty,comm -p $$` | Shows the shell's PID, controlling terminal and command name. |
| `who` | Lists logged-in sessions recorded in the system's `utmp` database, including their terminal (`pts/0`) and origin when available. |
| `stty -a \| head -n 1` | Displays line settings such as speed and size; `stty` only works when stdin is a terminal. |
| `[ -t 0 ]` / `[ -t 1 ]` | Tests whether file descriptor 0 (stdin) or 1 (stdout) is a terminal. |
| `ssh -t` | Requests a pseudo-terminal even when a command is given, needed for interactive programs. |

## 8. Practical Examples

**Example 1 — Identify your terminal and shell**

```bash
tty
ps -o pid,tty,comm -p $$
echo "TERM=$TERM"
```

**Example 2 — See the difference when output is piped**

```bash
[ -t 1 ] && echo "stdout is a terminal" || echo "stdout is not a terminal"
{ [ -t 1 ] && echo "stdout is a terminal" || echo "stdout is not a terminal"; } | cat
```

**Example 3 — A script that adapts to terminal presence**

```bash
#!/usr/bin/env bash
if [[ -t 1 ]]; then
    echo "Interactive output: colours are safe"
else
    echo "Redirected output: plain text only"
fi
```

**Example 4 — Run a remote command without and with a PTY (from your PC)**

```bash
ssh ubuntu@<EC2-PUBLIC-IP> tty
ssh -t ubuntu@<EC2-PUBLIC-IP> tty
```

## 9. Expected Output

```text
/dev/pts/0
    PID TTY          COMMAND
   1234 pts/0    bash
TERM=xterm-256color
```

(PID, `pts` number and `TERM` value will differ.)

```text
stdout is a terminal
stdout is not a terminal
```

```text
not a tty
/dev/pts/1
```

The first `ssh` command typically reports `not a tty` because no PTY was allocated; the second reports a `pts` device. You may also see an extra message such as `Connection to <host> closed.` with `-t`.

## 10. Common Mistakes

- Saying "I opened Bash" when you opened a terminal (or vice versa).
- Believing closing the terminal window always stops remote work; without `tmux`, `screen` or `nohup`, the shell may receive `SIGHUP` and end its jobs.
- Writing scripts that prompt for input and then running them from cron or CI.
- Assuming a script sees the same `TERM`, colours and width in automation as in an SSH session.
- Using `ssh -t` in automated scripts, which can corrupt output with terminal control characters.

## 11. Troubleshooting

| Symptom | Likely cause | Safe next step |
|---------|--------------|----------------|
| `stty: 'standard input': Inappropriate ioctl for device` | Not attached to a TTY | Run it in an interactive session or skip it in automation |
| `the input device is not a TTY` (Docker, `sudo` prompts) | No PTY allocated | Add the correct TTY option only where interaction is needed |
| Garbled characters or wrong colours | Wrong `TERM` | `echo "$TERM"`; set it to a value your terminal supports |
| Session freezes after `Ctrl+S` | Flow control paused output | Press `Ctrl+Q` |
| Long job died when connection dropped | No multiplexer or `nohup` | Use `tmux` (if installed) or restart under an approved job runner |
| Wrong window size in `vim`/`top` | PTY size not updated | Resize the window or run `resize` if available |

## 12. Security Best Practices

- Use SSH keys and protect the private key. On Linux/WSL, use restrictive permissions such as `chmod 600`; on Windows, configure appropriate NTFS access-control permissions (ACLs).
- Keep your terminal and SSH client updated.
- Be cautious pasting multi-line commands from the web: hidden characters can run unintended commands. Paste into an editor first to inspect.
- Lock or exit sessions on shared workstations; idle root or production sessions are a risk.
- Avoid displaying secrets in terminal output. Terminal scrollback and `tmux` buffers may retain sensitive text; clearing the visible screen does not securely erase stored scrollback or logs.
- Never use `chmod 666 /dev/pts/*` or similar to "fix" terminal problems.

## 13. Interview Questions

1. **What is the difference between a shell and a terminal?** The terminal handles text I/O display and keystrokes; the shell interprets and runs commands.
2. **What is a PTY?** A software pseudo-terminal pair used by terminal emulators and `sshd` to emulate a physical terminal.
3. **What does `tty` print?** The device file of the terminal attached to standard input, or `not a tty`.
4. **Why might a script work interactively but hang in cron?** It prompts for input or needs a TTY, which cron does not provide.
5. **How can a script detect it is running in a terminal?** `[ -t 0 ]` or `[[ -t 1 ]]`.
6. **What does a terminal multiplexer do?** Keeps shell sessions running independently of the terminal connection.
7. **Is PowerShell a terminal or a shell?** A shell. Windows Terminal is the terminal.

## 14. Practical Exercises

1. Run `tty` in your SSH session, open a second session, run `tty` again and compare.
2. Use `who` to list sessions and match them to terminals.
3. Write a script that prints "interactive" or "non-interactive" depending on `[ -t 0 ]`; run it normally and as `echo | ./script.sh`.
4. Run `ssh ubuntu@<EC2-PUBLIC-IP> tty` from your PC (replace the placeholder with your instance address) and explain the output.
5. Explain in your own words why `ps -o tty -p $$` shows `pts/N` in SSH.

## 15. Key Takeaways

- Terminal = input/output window; shell = command interpreter.
- SSH gives your local terminal a remote shell connected through a PTY.
- Many automation contexts have no TTY, so scripts must not depend on interaction.
- `[ -t N ]` and `tty` reveal whether a terminal is attached.
- Protect keys, paste carefully and close idle sessions.

---

[← Previous: What is Bash?](02-what-is-bash.md) | [Module index](README.md) | [Next: Bash vs Other Shells →](04-bash-vs-other-shells.md)
