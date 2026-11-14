# 01 — What is a Shell?

[← Module index](README.md) | [Next: What is Bash? →](02-what-is-bash.md)

## 1. Overview

A shell is the program that sits between you and the Linux kernel. When you connect to an EC2 instance over SSH, the first thing you interact with is a shell: it displays a prompt, reads what you type, interprets it, asks the operating system to run the requested programs and shows you the results. It is also a programming language, which is what makes automation possible.

## 2. Definition

A **shell** is a command interpreter: a user-space program that reads commands (from a person at a keyboard or from a file), interprets them, and uses operating system services to execute programs on the user's behalf.

The shell is **not** part of the kernel. It is an ordinary program that runs with the privileges of the user who started it.

## 3. Detailed Explanation

### Where the shell fits

```text
  You (keyboard)
       │
       ▼
  Terminal / SSH client      ← displays text, sends keystrokes
       │
       ▼
  Shell (bash, dash, zsh)       ← interprets commands, runs programs
       │   system calls (fork, execve, wait, pipe, open and others)
       ▼
  Linux kernel               ← schedules processes, manages files, memory, devices
       │
       ▼
  Hardware / virtual hardware (EC2)
```

### What a shell does

- Displays a prompt and reads input (interactive use).
- Parses the input into words and operators, handling quoting and expansion.
- Locates and starts programs, or runs built-in commands itself.
- Connects programs together with pipes and redirections.
- Manages jobs (foreground and background processes).
- Holds variables and a working environment for the programs it starts.
- Provides programming constructs: variables, conditionals, loops and functions.

### Shell modes

| Mode | Description | Example |
|------|-------------|---------|
| Interactive | Reads commands interactively from the user; normally displays a prompt when connected to a terminal | An SSH session |
| Non-interactive | Reads commands from a script or `-c` string, no prompt | `bash backup.sh` |
| Login | The first shell of a session, reads login startup files | SSH login |
| Non-login | A shell started from within an existing session | Running `bash` inside SSH |

Modes combine. For example, an SSH login is an interactive login shell, while a cron job runs a non-interactive, non-login shell. Topic 6 explains the startup-file consequences.

### Command-line shells vs graphical shells

A *graphical shell* (for example the GNOME desktop) is a graphical user interface. In server administration "the shell" almost always means a command-line shell such as Bash. EC2 Ubuntu Server images have no desktop, so the shell is your primary interface.

## 4. How It Works

The shell runs a continuous **read–parse–expand–execute** loop:

1. **Prompt and read** — the shell prints the prompt (`PS1`) and reads a line.
2. **Parse** — it splits the line into tokens (words, operators such as `|`, `;`, `&&`, `>`), honouring quotes.
3. **Expand** — it performs expansions: braces, tilde, variables, command substitution, arithmetic, word splitting and filename globbing (see Topic 5).
4. **Resolve the command** — alias expansion happens where applicable; shell keywords are handled during parsing. Bash then checks functions, builtins and finally executable commands found through `PATH`.
5. **Execute** — for external programs, the shell typically creates a child process using `fork()` (or an equivalent mechanism). The child uses an `exec`-family system call such as `execve()` to run the program. The shell waits using wait-related system calls and collects the exit status.
6. **Report and repeat** — the exit status is stored in `$?` and the prompt returns.

Builtins such as `cd` run inside the shell process itself, because a child process could not change the shell's working directory.

## 5. Why It Matters in DevOps

- Servers are administered through shells over SSH, often with no graphical interface at all.
- Automation scripts, cron jobs, systemd `ExecStart` wrappers, EC2 user-data, Docker `RUN` steps and CI/CD pipeline steps are all executed by a shell.
- Understanding exit statuses, pipes and quoting explains why a pipeline step passes or fails.
- Fast, accurate shell work shortens incident response time.
- Because the shell runs with the user's privileges, mistakes (and malicious scripts) have real consequences.

## 6. Syntax and Commands

```bash
echo "$SHELL"                # login shell configured for the user
ps -p $$ -o comm=            # the shell process you are in right now
echo "$0"                    # name the current shell was invoked as
cat /etc/shells              # shells permitted as login shells
whoami                       # current user
uname -sr                    # kernel name and release
type cd                      # how the shell classifies a command
command -v bash              # path of the bash executable
```

## 7. Command-by-Command Explanation

| Command | Explanation |
|---------|-------------|
| `echo "$SHELL"` | Prints the `SHELL` environment variable, which holds the user's configured **login** shell. It is set at login and is **not** updated if you start a different shell later. |
| `ps -p $$ -o comm=` | `$$` expands to the PID of the current shell. `ps -p` selects that process, `-o comm=` prints only the command name without a header. This shows the shell actually running. |
| `echo "$0"` | In an interactive shell, `$0` is the name the shell was started as (for example `-bash` for a login shell, where the leading dash marks it as a login shell). |
| `cat /etc/shells` | Lists shells permitted for login on the system. `chsh` typically checks this list, subject to system configuration and policy. |
| `whoami` | Prints the effective user name. |
| `uname -sr` | Prints the kernel name and release, confirming the shell runs on top of Linux. |
| `type cd` | Reports whether `cd` is a builtin, alias, function, keyword or file. |
| `command -v bash` | Prints how the shell would resolve `bash`, normally `/usr/bin/bash`. |

## 8. Practical Examples

**Example 1 — Inspect your session**

```bash
echo "Login shell : $SHELL"
echo "Current shell: $(ps -p $$ -o comm=)"
echo "User         : $(whoami)"
echo "Kernel       : $(uname -sr)"
```

**Example 2 — Run one command through a new, non-interactive shell**

```bash
bash -c 'echo "Hello from a non-interactive shell"; echo "Exit status inside: $?"'
```

**Example 3 — A pipeline built by the shell**

```bash
ps -eo comm | sort | uniq -c | sort -rn | head -n 5
```

The shell starts five external commands (`ps`, `sort`, `uniq`, `sort` and `head`), connects them with pipes and waits for the pipeline to finish.

**Example 4 — Observe exit statuses**

```bash
true;  echo "true returned $?"
false; echo "false returned $?"
```

## 9. Expected Output

Values such as user name and kernel release depend on your instance. On a default Ubuntu 24.04 EC2 instance you should see output similar to:

```text
Login shell : /bin/bash
Current shell: bash
User         : ubuntu
Kernel       : Linux 6.8.0-1021-aws
```

```text
Hello from a non-interactive shell
Exit status inside: 0
```

```text
true returned 0
false returned 1
```

`cat /etc/shells` typically lists entries such as `/bin/sh`, `/bin/bash`, `/usr/bin/bash`, `/bin/dash` and `/usr/bin/dash`, but the exact list can differ between images.

## 10. Common Mistakes

- Assuming `$SHELL` is the shell currently running. It is only the configured login shell.
- Confusing the shell with the terminal (see Topic 3).
- Believing the shell is part of the kernel. It is a normal user-space program.
- Forgetting that `cd` and variable assignments inside a child process do not affect the parent shell.
- Ignoring exit statuses and assuming a command succeeded because it printed something.
- Copy-pasting commands from the internet without understanding them.

## 11. Troubleshooting

| Symptom | Likely cause | Safe next step |
|---------|--------------|----------------|
| `-bash: foo: command not found` | Program missing or not in `PATH` | `type foo`; `echo "$PATH"` |
| Prompt looks different after login | A different shell or custom `PS1` | `ps -p $$ -o comm=` |
| `$SHELL` shows `/bin/bash` but behaviour is like `sh` | Script run with `sh` | Check the shebang and how it was run (Topics 4 and 8) |
| Session hangs after pasting | Unterminated quote or here-document | Press `Ctrl+C`, then re-check the pasted text |
| `Permission denied` | Missing permissions or ownership | `ls -l` the file; do **not** reach for `sudo` blindly (Topic 10) |

## 12. Security Best Practices

- Run as a regular user; use `sudo` only for specific administrative commands that need it.
- Read commands and scripts from the internet before running them. Never pipe unknown downloads straight into a shell.
- Use SSH key authentication and keep private keys readable only by you (`chmod 600`).
- Do not type secrets directly on the command line, where they may land in shell history and process listings.
- Log out of idle sessions on shared or production servers.

## 13. Interview Questions

1. **What is a shell?** A user-space command interpreter that reads commands, expands them and asks the kernel to run programs; it is also a scripting language.
2. **Is the shell part of the kernel?** No. It is an ordinary program running with the user's privileges.
3. **What happens when you run `ls`?** The shell parses and expands the command, checks applicable aliases, functions and builtins, then searches `PATH` if needed. For an external `ls`, it typically creates a child process, executes the program and collects its exit status.
4. **Why is `cd` a builtin?** Changing directory must affect the shell process itself; a child process cannot change its parent's working directory.
5. **What is the difference between `$SHELL` and `$0`?** `$SHELL` is the configured login shell from the environment; `$0` is how the current shell was invoked.
6. **What is an exit status?** An integer from 0–255 returned by a process; `0` conventionally means success.
7. **What is the difference between an interactive and a non-interactive shell?** Interactive shells read commands interactively from the user and normally display a prompt when connected to a terminal. Non-interactive shells execute commands from scripts or `-c` strings.

## 14. Practical Exercises

1. Show your login shell and your current shell. Are they the same?
2. Start a nested shell with `bash`, run `echo $SHLVL`, then `exit` and run it again. What changed and why?
3. Run `bash -c 'exit 7'; echo $?` and explain the output.
4. Use `type` on `cd`, `ls`, `echo` and `if`. Classify each result.
5. Run `ps -p $$ -o pid,ppid,comm` and identify the parent process of your shell.

## 15. Key Takeaways

- A shell is a user-space command interpreter and scripting language.
- It repeatedly reads, parses, expands, finds and executes commands.
- External commands run through `fork` and `exec`; builtins run inside the shell.
- Shells operate in interactive, non-interactive, login and non-login modes.
- Exit statuses drive automation logic, so always respect them.
- The shell runs with your privileges, so use it carefully.

---

[← Module index](README.md) | [Next: What is Bash? →](02-what-is-bash.md)
