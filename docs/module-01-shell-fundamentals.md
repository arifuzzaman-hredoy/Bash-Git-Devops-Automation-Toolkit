# Module 01 — Shell & Bash Fundamentals

> Part of the **Bash & Git DevOps Automation Toolkit**
> Repository: <https://github.com/arifuzzaman-hredoy/Bash-Git-Devops-Automation-Toolkit>

## Module Overview

Every Linux server, container, CI/CD runner and cloud instance you will ever manage is operated through a shell. This module builds the foundation for everything else in the toolkit: what a shell is, how Bash interprets and executes commands, how the shell environment is constructed, how a script is structured, how it is executed safely, and how to debug it when it misbehaves.

The material targets **Ubuntu 24.04 LTS** (Bash 5.2.x) on an AWS EC2 instance, working as the regular `ubuntu` user, and moves from beginner concepts to practical, production-minded habits.

## Learning Objectives

After completing this module you will be able to:

- Explain what a shell is and distinguish it from a terminal, a kernel and a console.
- Describe what Bash is, how it relates to POSIX `sh`, and when other shells are appropriate.
- Trace how Bash finds and runs a command (aliases, functions, builtins, `PATH`, `fork`/`exec`).
- Distinguish interactive, non-interactive, login and non-login shells, and know which startup files each reads.
- Explain environment variables, `export`, and how child processes inherit them.
- Write a well-structured Bash script with a correct shebang.
- Create, make executable, and run scripts in several ways, and know when each is appropriate.
- Apply file permissions with `chmod` safely and explain the principle of least privilege.
- Debug scripts using `bash -n`, `bash -x`, `set -x` and `set +x` without leaking secrets.

## Prerequisites

- An AWS EC2 instance (or any Linux machine) running Ubuntu 24.04 LTS, reachable over SSH.
- The ability to log in as a regular, non-root user (this project uses `ubuntu`).
- A text editor available on the server (`nano` or `vim`).
- Basic comfort with typing commands. No prior scripting experience is required.
- Git installed and this repository cloned at `~/bash-script`.

## Topics

- [01 — What is a Shell?](#01-what-is-a-shell)
- [02 — What is Bash?](#02-what-is-bash)
- [03 — Shell vs Terminal](#03-shell-vs-terminal)
- [04 — Bash vs Other Shells](#04-bash-vs-other-shells)
- [05 — Linux Command Execution](#05-linux-command-execution)
- [06 — Shell Environment](#06-shell-environment)
- [07 — Bash Script Structure](#07-bash-script-structure)
- [08 — Shebang](#08-shebang)
- [09 — Creating and Executing Bash Scripts](#09-creating-and-executing-bash-scripts)
- [10 — Executable Permissions](#10-executable-permissions)
- [11 — Bash Script Debugging Fundamentals](#11-bash-script-debugging-fundamentals)

## Recommended Learning Sequence

Follow the topics in numeric order. They are designed to build on one another:

1. **Concepts first (Topics 1–4):** understand the shell, Bash, the terminal and how Bash compares with other shells.
2. **How the shell works (Topics 5–6):** learn command lookup and execution, then the environment that every process inherits.
3. **Writing scripts (Topics 7–9):** learn script structure, the shebang, and the different ways to create and run a script.
4. **Safe operation (Topics 10–11):** apply permissions correctly and learn to debug without exposing sensitive data.

For each topic: read the document, type every example yourself on the EC2 instance, compare your output with the expected output, then complete the practical exercises before moving on. Practise in a scratch directory such as `~/practice/module-01` rather than inside the Git repository, so experiments never end up in a commit.

## Practical Learning Outcomes

By the end of this module you will have practised:

- Inspecting your shell, its version, its options and its startup behaviour.
- Using `type`, `command -v`, `hash` and `PATH` to explain exactly which program runs for a given command.
- Creating and exporting variables and proving how child processes inherit them.
- Writing a reusable script skeleton with a shebang, strict-mode options, functions, a `main` entry point and cleanup traps.
- Setting permissions such as `644`, `700` and `755` deliberately, and finding unsafe permissions.
- Validating a script with `bash -n` and tracing it with `bash -x` and a custom `PS4`.

## DevOps Relevance

- **Automation** — provisioning, deployments, backups, log rotation and health checks are all shell scripts at their core.
- **CI/CD** — pipeline steps in GitHub Actions, GitLab CI and Jenkins run commands through a shell; knowing how it behaves explains many "works on my machine" failures.
- **Cloud and containers** — EC2 user-data, Dockerfile `RUN` instructions and Kubernetes entrypoints rely on shell semantics.
- **Incident response** — fast, accurate command-line work and debugging skills reduce downtime.
- **Security** — correct permissions, careful handling of secrets and cautious execution of untrusted scripts prevent real incidents.

## Completion Checklist

Tick each item when you can do it without looking at the notes.

- [ ] I can explain what a shell is and what happens between pressing Enter and a command running.
- [ ] I can state what Bash stands for and check which Bash version is installed.
- [ ] I can explain the difference between a shell and a terminal.
- [ ] I can explain why `sh script.sh` and `bash script.sh` may behave differently on Ubuntu.
- [ ] I can tell whether a command is an alias, keyword, function, builtin or external program.
- [ ] I can explain login, non-login, interactive and non-interactive shells and their startup files.
- [ ] I can explain why a child process cannot change its parent's variables.
- [ ] I can write a script skeleton from memory, including a correct shebang.
- [ ] I can explain the difference between `bash script.sh`, `./script.sh` and `source script.sh`.
- [ ] I can set and read permissions in symbolic and octal form and explain why `777` is unsafe.
- [ ] I can use `bash -n`, `bash -x`, `set -x` and `set +x`, and I know why tracing can leak secrets.
- [ ] I have completed the practical exercises for every topic.

## Next Module Preview

**Module 02 — Variables & User Input** *(planned; documentation not yet part of this repository)*

The next module covers shell and environment variables in depth, quoting rules, parameter expansion, command-line arguments, the `read` builtin, input validation and safe handling of user-supplied data.

---

*All commands in this module are intended to be run as a regular user. None require `sudo`.*

---

## 01 — What is a Shell?


### 1. Overview

A shell is the program that sits between you and the Linux kernel. When you connect to an EC2 instance over SSH, the first thing you interact with is a shell: it displays a prompt, reads what you type, interprets it, asks the operating system to run the requested programs and shows you the results. It is also a programming language, which is what makes automation possible.

### 2. Definition

A **shell** is a command interpreter: a user-space program that reads commands (from a person at a keyboard or from a file), interprets them, and uses operating system services to execute programs on the user's behalf.

The shell is **not** part of the kernel. It is an ordinary program that runs with the privileges of the user who started it.

### 3. Detailed Explanation

#### Where the shell fits

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

#### What a shell does

- Displays a prompt and reads input (interactive use).
- Parses the input into words and operators, handling quoting and expansion.
- Locates and starts programs, or runs built-in commands itself.
- Connects programs together with pipes and redirections.
- Manages jobs (foreground and background processes).
- Holds variables and a working environment for the programs it starts.
- Provides programming constructs: variables, conditionals, loops and functions.

#### Shell modes

| Mode | Description | Example |
|------|-------------|---------|
| Interactive | Reads commands interactively from the user; normally displays a prompt when connected to a terminal | An SSH session |
| Non-interactive | Reads commands from a script or `-c` string, no prompt | `bash backup.sh` |
| Login | The first shell of a session, reads login startup files | SSH login |
| Non-login | A shell started from within an existing session | Running `bash` inside SSH |

Modes combine. For example, an SSH login is an interactive login shell, while a cron job runs a non-interactive, non-login shell. Topic 6 explains the startup-file consequences.

#### Command-line shells vs graphical shells

A *graphical shell* (for example the GNOME desktop) is a graphical user interface. In server administration "the shell" almost always means a command-line shell such as Bash. EC2 Ubuntu Server images have no desktop, so the shell is your primary interface.

### 4. How It Works

The shell runs a continuous **read–parse–expand–execute** loop:

1. **Prompt and read** — the shell prints the prompt (`PS1`) and reads a line.
2. **Parse** — it splits the line into tokens (words, operators such as `|`, `;`, `&&`, `>`), honouring quotes.
3. **Expand** — it performs expansions: braces, tilde, variables, command substitution, arithmetic, word splitting and filename globbing (see Topic 5).
4. **Resolve the command** — alias expansion happens where applicable; shell keywords are handled during parsing. Bash then checks functions, builtins and finally executable commands found through `PATH`.
5. **Execute** — for external programs, the shell typically creates a child process using `fork()` (or an equivalent mechanism). The child uses an `exec`-family system call such as `execve()` to run the program. The shell waits using wait-related system calls and collects the exit status.
6. **Report and repeat** — the exit status is stored in `$?` and the prompt returns.

Builtins such as `cd` run inside the shell process itself, because a child process could not change the shell's working directory.

### 5. Why It Matters in DevOps

- Servers are administered through shells over SSH, often with no graphical interface at all.
- Automation scripts, cron jobs, systemd `ExecStart` wrappers, EC2 user-data, Docker `RUN` steps and CI/CD pipeline steps are all executed by a shell.
- Understanding exit statuses, pipes and quoting explains why a pipeline step passes or fails.
- Fast, accurate shell work shortens incident response time.
- Because the shell runs with the user's privileges, mistakes (and malicious scripts) have real consequences.

### 6. Syntax and Commands

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

### 7. Command-by-Command Explanation

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

### 8. Practical Examples

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

### 9. Expected Output

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

### 10. Common Mistakes

- Assuming `$SHELL` is the shell currently running. It is only the configured login shell.
- Confusing the shell with the terminal (see Topic 3).
- Believing the shell is part of the kernel. It is a normal user-space program.
- Forgetting that `cd` and variable assignments inside a child process do not affect the parent shell.
- Ignoring exit statuses and assuming a command succeeded because it printed something.
- Copy-pasting commands from the internet without understanding them.

### 11. Troubleshooting

| Symptom | Likely cause | Safe next step |
|---------|--------------|----------------|
| `-bash: foo: command not found` | Program missing or not in `PATH` | `type foo`; `echo "$PATH"` |
| Prompt looks different after login | A different shell or custom `PS1` | `ps -p $$ -o comm=` |
| `$SHELL` shows `/bin/bash` but behaviour is like `sh` | Script run with `sh` | Check the shebang and how it was run (Topics 4 and 8) |
| Session hangs after pasting | Unterminated quote or here-document | Press `Ctrl+C`, then re-check the pasted text |
| `Permission denied` | Missing permissions or ownership | `ls -l` the file; do **not** reach for `sudo` blindly (Topic 10) |

### 12. Security Best Practices

- Run as a regular user; use `sudo` only for specific administrative commands that need it.
- Read commands and scripts from the internet before running them. Never pipe unknown downloads straight into a shell.
- Use SSH key authentication and keep private keys readable only by you (`chmod 600`).
- Do not type secrets directly on the command line, where they may land in shell history and process listings.
- Log out of idle sessions on shared or production servers.

### 13. Interview Questions

1. **What is a shell?** A user-space command interpreter that reads commands, expands them and asks the kernel to run programs; it is also a scripting language.
2. **Is the shell part of the kernel?** No. It is an ordinary program running with the user's privileges.
3. **What happens when you run `ls`?** The shell parses and expands the command, checks applicable aliases, functions and builtins, then searches `PATH` if needed. For an external `ls`, it typically creates a child process, executes the program and collects its exit status.
4. **Why is `cd` a builtin?** Changing directory must affect the shell process itself; a child process cannot change its parent's working directory.
5. **What is the difference between `$SHELL` and `$0`?** `$SHELL` is the configured login shell from the environment; `$0` is how the current shell was invoked.
6. **What is an exit status?** An integer from 0–255 returned by a process; `0` conventionally means success.
7. **What is the difference between an interactive and a non-interactive shell?** Interactive shells read commands interactively from the user and normally display a prompt when connected to a terminal. Non-interactive shells execute commands from scripts or `-c` strings.

### 14. Practical Exercises

1. Show your login shell and your current shell. Are they the same?
2. Start a nested shell with `bash`, run `echo $SHLVL`, then `exit` and run it again. What changed and why?
3. Run `bash -c 'exit 7'; echo $?` and explain the output.
4. Use `type` on `cd`, `ls`, `echo` and `if`. Classify each result.
5. Run `ps -p $$ -o pid,ppid,comm` and identify the parent process of your shell.

### 15. Key Takeaways

- A shell is a user-space command interpreter and scripting language.
- It repeatedly reads, parses, expands, finds and executes commands.
- External commands run through `fork` and `exec`; builtins run inside the shell.
- Shells operate in interactive, non-interactive, login and non-login modes.
- Exit statuses drive automation logic, so always respect them.
- The shell runs with your privileges, so use it carefully.

---

---

## 02 — What is Bash?


### 1. Overview

Bash is the default interactive shell on Ubuntu and the most widely used shell for Linux automation. It is both the program you type commands into over SSH and the interpreter that runs most of the scripts in this toolkit. Ubuntu 24.04 LTS ships Bash 5.2.x.

### 2. Definition

**Bash** stands for **Bourne-Again SHell**. It is the GNU Project's shell, written as a free replacement and extension of the original Bourne shell (`sh`). It supports many features defined by the POSIX shell standard and adds many extensions, often called *bashisms*. Bash is not limited to POSIX syntax.

### 3. Detailed Explanation

#### Origin

Brian Fox wrote Bash for the GNU Project, with its first release in 1989. It has been maintained for many years by Chet Ramey. The name is a pun on the Bourne shell written by Stephen Bourne.

#### Key features

- **Command-line editing and history** — arrow keys, `Ctrl+R` reverse search, the `history` builtin.
- **Tab completion** — for commands, file names and, with the `bash-completion` package, command options.
- **Variables, arrays and associative arrays** — indexed arrays and `declare -A` maps (Bash 4+).
- **Extended tests** — `[[ expression ]]` with pattern matching and regular expressions.
- **Expansions** — brace expansion (`{a,b}`), parameter expansion (`${var:-default}`), arithmetic expansion (`$(( ))`) and process substitution (`<( )`).
- **Functions, loops, conditionals and `case`** — a complete scripting language.
- **Job control** — `&`, `jobs`, `fg`, `bg`.
- **Here-documents and here-strings** — `<<EOF` and `<<<`.
- **Shell options** — `set -o` and `shopt` switches to change behaviour.

#### Bash and POSIX

POSIX defines a portable shell language. Bash implements it and extends it. Scripts that use only portable POSIX shell features can generally run on `dash`, `ash` and other POSIX-oriented shells. Scripts that use Bash-specific features must be run by Bash. Bash can follow POSIX-oriented behaviour more closely with `set -o posix` or when invoked as `sh`, although this does not turn every Bash script into a portable POSIX script.

#### Bash on Ubuntu

- `/bin/bash` (a symlink to `/usr/bin/bash` on current Ubuntu) is normally the default login shell for the `ubuntu` user on a standard Ubuntu EC2 image. Check the configured login shell with `getent passwd ubuntu`.
- `/bin/sh` is **not** Bash; on Ubuntu it points to `dash` (Topic 4).
- Bash reads `~/.bashrc` for interactive non-login shells, and Ubuntu's default `~/.profile` sources it for login shells.

#### Version information

Bash exposes its version in `BASH_VERSION` and the array `BASH_VERSINFO`. Ubuntu backports security fixes without always changing the upstream version number, so use the distribution package version for patch tracking rather than the number alone.

### 4. How It Works

1. Bash starts, determines whether it is interactive and/or a login shell, and reads the appropriate startup files.
2. It sets up its internal state: variables, options (`$-`), aliases, functions and the command hash table.
3. For each command line it performs the read–parse–expand–execute cycle described in Topics 1 and 5.
4. For scripts it reads the file (or `-c` string) one complete command at a time and executes it, so a syntax error late in a file may only appear after earlier commands have already run. This is why `bash -n` is valuable (Topic 11).
5. On exit it returns the exit status of the last command (or the value given to `exit`) to its parent.

### 5. Why It Matters in DevOps

- Bash is available on virtually every Linux server, cloud image and CI runner, so scripts need no extra runtime.
- It excels at gluing tools together: `aws`, `git`, `curl`, `systemctl`, `docker`, `kubectl`.
- Its features (arrays, `[[ ]]`, parameter expansion, `trap`) make scripts shorter and safer than strict POSIX `sh` equivalents.
- It is the language of cron jobs, EC2 user-data scripts, Dockerfile `RUN` lines and many pipeline steps.
- Knowing Bash precisely lets you decide when to stay portable and when a different tool (Python, for example) is the better choice.

### 6. Syntax and Commands

```bash
bash --version | head -n 1       # version banner
echo "$BASH_VERSION"             # version string
echo "${BASH_VERSINFO[0]}"       # major version number
type -a bash                     # all bash executables found
help | head -n 10                # builtin command summary
help cd                          # help for one builtin
man bash                         # full manual (press q to quit)
compgen -b | wc -l               # count of builtin commands
set -o | head -n 5               # some shell option states
shopt | head -n 5                # some shopt option states
```

### 7. Command-by-Command Explanation

| Command | Explanation |
|---------|-------------|
| `bash --version \| head -n 1` | Prints the version banner; `head -n 1` keeps only the first line. |
| `echo "$BASH_VERSION"` | Shell variable set by Bash itself containing the version string. |
| `echo "${BASH_VERSINFO[0]}"` | Element 0 of an array holding the major version; useful for feature checks in scripts. |
| `type -a bash` | `-a` shows every match, in lookup order. |
| `help` / `help cd` | Documentation for **builtins**. Builtins have no separate man pages; `help` is the right tool. |
| `man bash` | The authoritative reference. Search with `/` and quit with `q`. |
| `compgen -b` | Lists the names of all builtins; `wc -l` counts them. |
| `set -o` | Shows the state of options controlled by `set` (`errexit`, `nounset`, `pipefail`, `posix` and others). |
| `shopt` | Shows Bash-specific options controlled by `shopt` (`login_shell`, `nullglob`, `extglob` and others). |

### 8. Practical Examples

**Example 1 — Indexed array**

```bash
servers=(web-01 web-02 db-01)
echo "First : ${servers[0]}"
echo "Count : ${#servers[@]}"
for s in "${servers[@]}"; do echo "Checking $s"; done
```

**Example 2 — Associative array (Bash 4+)**

```bash
declare -A ports=([http]=80 [https]=443 [ssh]=22)
echo "SSH uses port ${ports[ssh]}"
```

**Example 3 — Extended test with pattern and regex**

```bash
file="backup-2025-01-15.tar.gz"
if [[ "$file" == backup-*.tar.gz ]]; then echo "pattern match"; fi
if [[ "$file" =~ ([0-9]{4})-([0-9]{2})-([0-9]{2}) ]]; then
    echo "year=${BASH_REMATCH[1]} month=${BASH_REMATCH[2]}"
fi
```

**Example 4 — Parameter expansion with a default**

```bash
unset ENVIRONMENT
echo "Deploying to ${ENVIRONMENT:-staging}"
```

**Example 5 — Feature check inside a script**

```bash
if (( BASH_VERSINFO[0] < 4 )); then
    echo "Bash 4 or newer is required" >&2
    exit 1
fi
```

### 9. Expected Output

```text
GNU bash, version 5.2.21(1)-release (x86_64-pc-linux-gnu)
```

(The patch level may differ on your system; Ubuntu 24.04 uses the 5.2.x series.)

```text
First : web-01
Count : 3
Checking web-01
Checking web-02
Checking db-01
```

```text
SSH uses port 22
```

```text
pattern match
year=2025 month=01
```

```text
Deploying to staging
```

### 10. Common Mistakes

- Writing Bash-specific syntax (`[[ ]]`, arrays) in a script run with `sh`.
- Forgetting quotes around `"${array[@]}"`, which breaks elements containing spaces.
- Assuming associative arrays work in very old Bash (macOS ships Bash 3.2 by default).
- Using `==` inside single brackets `[ ]` and expecting pattern matching; use `[[ ]]` for patterns.
- Trying to use `man cd`; builtins are documented with `help cd` and in `man bash`.
- Assuming `/bin/sh` is Bash on Ubuntu.

### 11. Troubleshooting

| Symptom | Likely cause | Safe next step |
|---------|--------------|----------------|
| `declare: -A: invalid option` | Running a very old Bash | `bash --version`; run with a newer Bash |
| `[[: not found` | Script executed by `sh`/`dash` | Run with `bash script.sh` or fix the shebang |
| `syntax error near unexpected token` | Unbalanced quotes, missing `fi`/`done`, CRLF line endings | `bash -n script.sh`; `file script.sh` |
| `bad substitution` | Bash-only parameter expansion run under `sh` | Confirm the interpreter with `ps -p $$ -o comm=` inside the script |
| Different behaviour in cron | Different environment and `PATH` | Use absolute paths; set `PATH` explicitly (Topic 6) |

### 12. Security Best Practices

- Quote every variable expansion (`"$var"`) to avoid word splitting and glob expansion on untrusted data.
- Never use `eval` on user-supplied or external input.
- Prefer `[[ ]]` over `[ ]` for tests on variables, and validate input before use.
- Keep Ubuntu packages updated through the normal, approved update process so Bash receives security fixes.
- Do not hardcode secrets in scripts; load them from protected files or a secrets manager.
- Avoid running scripts as root unless the specific task requires it.

### 13. Interview Questions

1. **What does Bash stand for?** Bourne-Again SHell.
2. **Is Bash the same as `sh`?** No. `sh` is the POSIX shell interface. On Ubuntu `/bin/sh` is `dash`; Bash is a separate, richer shell.
3. **Name three Bash features that are not in POSIX `sh`.** Arrays, `[[ ]]`, process substitution, brace expansion, `${var,,}` case conversion.
4. **How do you check the Bash version inside a script?** Use `BASH_VERSION` or `BASH_VERSINFO`.
5. **What is a builtin and how do you read its documentation?** A command implemented inside the shell; use `help <name>`.
6. **Why use `[[ ]]` instead of `[ ]`?** It does not perform word splitting or pathname expansion on its expressions and supports pattern matching with `==` and regular-expression matching with `=~`.
7. **How can Bash be made to follow POSIX behaviour?** `set -o posix`, `bash --posix`, or being invoked as `sh`.

### 14. Practical Exercises

1. Record your Bash version using both `BASH_VERSION` and `BASH_VERSINFO`.
2. Create an array of three directory names and loop over it, printing each.
3. Create an associative array mapping service names to ports and print one value.
4. Use `[[ =~ ]]` to extract the year from `report-2025-03-01.csv`.
5. Run `compgen -b | wc -l` and `help type`. Explain what `type` is documented as.

### 15. Key Takeaways

- Bash is the GNU "Bourne-Again SHell", the default Ubuntu interactive shell.
- It is mostly POSIX-compatible and adds arrays, `[[ ]]`, process substitution and more.
- `/bin/sh` is a different shell (`dash`) on Ubuntu.
- Use `help` for builtins and `man bash` for the full reference.
- Quote variables and avoid `eval` to keep scripts safe.

---

---

## 03 — Shell vs Terminal


### 1. Overview

People often say "terminal" and "shell" as if they were the same thing. They are different layers. The **terminal** is the window or device that displays text and captures keystrokes; the **shell** is the program that interprets the commands. Understanding the split explains SSH sessions, `tty` devices, `tmux`, and why some scripts behave differently with and without a terminal attached.

### 2. Definition

- **Terminal (terminal emulator):** a program, or historically a hardware device, that provides text input and output. Modern examples: Windows Terminal, PuTTY, macOS Terminal, GNOME Terminal.
- **Shell:** the command interpreter that runs inside the terminal (Bash, dash, zsh and others).
- **Console:** the system's primary physical or virtual text interface (for example a VM's serial console or the EC2 serial console).
- **TTY (teletypewriter):** the kernel's terminal device abstraction, such as `/dev/tty1` or `/dev/pts/0`.
- **PTY (pseudo-terminal):** a software pair of devices (master and slave) that emulates a terminal; terminal emulators and `sshd` use it.

### 3. Detailed Explanation

#### The layers

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

#### Related concepts

- **Terminal multiplexers** (`tmux`, `screen`) sit between the terminal and shell so sessions survive disconnects.
- **PowerShell** on Windows is itself a shell; Windows Terminal is a terminal that can host PowerShell, Command Prompt or an SSH session.
- A terminal can host **any** shell, and a shell can run in **any** terminal.
- Programs can detect whether they are attached to a terminal (`[ -t 0 ]`) and change behaviour, for example disabling colours or prompts when output is piped or run from cron.

#### Control characters

The terminal's line discipline handles configured control characters: by default, `Ctrl+C` generates `SIGINT`, `Ctrl+Z` generates `SIGTSTP`, and `Ctrl+D` signals EOF to a read when the input buffer is empty. `Ctrl+S`/`Ctrl+Q` pause and resume terminal output when software flow control (`IXON`) is enabled.

### 4. How It Works

1. You type a key in your terminal emulator on Windows.
2. The SSH client sends it, encrypted, to `sshd` on EC2.
3. `sshd` writes it to the master side of a PTY.
4. The kernel's TTY layer passes it (after line-discipline processing) to the shell reading the slave side, e.g. `/dev/pts/0`.
5. The shell executes the command; output goes back through the PTY, over SSH and is drawn by your terminal.

Running `ssh host command` without `-t` normally allocates **no** PTY, so the remote command sees no terminal.

### 5. Why It Matters in DevOps

- Knowing where the shell actually runs (on the server) avoids confusion about local vs remote paths and environments.
- Scripts must behave correctly with no TTY: cron, CI runners, `ssh host cmd`, EC2 user-data and Docker builds have none. Commands that prompt for input will hang or fail there.
- `tmux` or `screen` protects long-running work from dropped connections.
- Interactive tools (`sudo` password prompts, `vim`, `top`) need a TTY; automation must use non-interactive alternatives.
- Terminal-related variables (`TERM`, `COLUMNS`) influence how tools format output and logs.

### 6. Syntax and Commands

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

### 7. Command-by-Command Explanation

| Command | Explanation |
|---------|-------------|
| `tty` | Prints the file name of the terminal connected to standard input, such as `/dev/pts/0`. Prints `not a tty` if there is none. |
| `echo "$TERM"` | Terminal type used by programs to choose control sequences (for example `xterm-256color`). |
| `ps -o pid,tty,comm -p $$` | Shows the shell's PID, controlling terminal and command name. |
| `who` | Lists logged-in sessions recorded in the system's `utmp` database, including their terminal (`pts/0`) and origin when available. |
| `stty -a \| head -n 1` | Displays line settings such as speed and size; `stty` only works when stdin is a terminal. |
| `[ -t 0 ]` / `[ -t 1 ]` | Tests whether file descriptor 0 (stdin) or 1 (stdout) is a terminal. |
| `ssh -t` | Requests a pseudo-terminal even when a command is given, needed for interactive programs. |

### 8. Practical Examples

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

### 9. Expected Output

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

### 10. Common Mistakes

- Saying "I opened Bash" when you opened a terminal (or vice versa).
- Believing closing the terminal window always stops remote work; without `tmux`, `screen` or `nohup`, the shell may receive `SIGHUP` and end its jobs.
- Writing scripts that prompt for input and then running them from cron or CI.
- Assuming a script sees the same `TERM`, colours and width in automation as in an SSH session.
- Using `ssh -t` in automated scripts, which can corrupt output with terminal control characters.

### 11. Troubleshooting

| Symptom | Likely cause | Safe next step |
|---------|--------------|----------------|
| `stty: 'standard input': Inappropriate ioctl for device` | Not attached to a TTY | Run it in an interactive session or skip it in automation |
| `the input device is not a TTY` (Docker, `sudo` prompts) | No PTY allocated | Add the correct TTY option only where interaction is needed |
| Garbled characters or wrong colours | Wrong `TERM` | `echo "$TERM"`; set it to a value your terminal supports |
| Session freezes after `Ctrl+S` | Flow control paused output | Press `Ctrl+Q` |
| Long job died when connection dropped | No multiplexer or `nohup` | Use `tmux` (if installed) or restart under an approved job runner |
| Wrong window size in `vim`/`top` | PTY size not updated | Resize the window or run `resize` if available |

### 12. Security Best Practices

- Use SSH keys and protect the private key. On Linux/WSL, use restrictive permissions such as `chmod 600`; on Windows, configure appropriate NTFS access-control permissions (ACLs).
- Keep your terminal and SSH client updated.
- Be cautious pasting multi-line commands from the web: hidden characters can run unintended commands. Paste into an editor first to inspect.
- Lock or exit sessions on shared workstations; idle root or production sessions are a risk.
- Avoid displaying secrets in terminal output. Terminal scrollback and `tmux` buffers may retain sensitive text; clearing the visible screen does not securely erase stored scrollback or logs.
- Never use `chmod 666 /dev/pts/*` or similar to "fix" terminal problems.

### 13. Interview Questions

1. **What is the difference between a shell and a terminal?** The terminal handles text I/O display and keystrokes; the shell interprets and runs commands.
2. **What is a PTY?** A software pseudo-terminal pair used by terminal emulators and `sshd` to emulate a physical terminal.
3. **What does `tty` print?** The device file of the terminal attached to standard input, or `not a tty`.
4. **Why might a script work interactively but hang in cron?** It prompts for input or needs a TTY, which cron does not provide.
5. **How can a script detect it is running in a terminal?** `[ -t 0 ]` or `[[ -t 1 ]]`.
6. **What does a terminal multiplexer do?** Keeps shell sessions running independently of the terminal connection.
7. **Is PowerShell a terminal or a shell?** A shell. Windows Terminal is the terminal.

### 14. Practical Exercises

1. Run `tty` in your SSH session, open a second session, run `tty` again and compare.
2. Use `who` to list sessions and match them to terminals.
3. Write a script that prints "interactive" or "non-interactive" depending on `[ -t 0 ]`; run it normally and as `echo | ./script.sh`.
4. Run `ssh ubuntu@<EC2-PUBLIC-IP> tty` from your PC (replace the placeholder with your instance address) and explain the output.
5. Explain in your own words why `ps -o tty -p $$` shows `pts/N` in SSH.

### 15. Key Takeaways

- Terminal = input/output window; shell = command interpreter.
- SSH gives your local terminal a remote shell connected through a PTY.
- Many automation contexts have no TTY, so scripts must not depend on interaction.
- `[ -t N ]` and `tty` reveal whether a terminal is attached.
- Protect keys, paste carefully and close idle sessions.

---

---

## 04 — Bash vs Other Shells


### 1. Overview

Bash is not the only shell. Ubuntu itself uses two different shells for different jobs: **Bash** for interactive use and most user scripts, and **dash** as `/bin/sh` for fast, minimal system scripts. Other shells such as zsh, fish, ksh and PowerShell exist for different audiences. Knowing the differences prevents the classic "it works in my terminal but fails in the pipeline" problem.

### 2. Definition

A *shell family* describes shells that share a common language lineage:

- **Bourne family:** `sh`, `bash`, `dash`, `ksh`, `zsh`, `ash`/BusyBox `sh`.
- **C shell family:** `csh`, `tcsh`.
- **Others:** `fish`, PowerShell (`pwsh`), `nushell`.

**POSIX `sh`** is the portable, standardised subset of the Bourne-family shell language. **Bashism** means a feature that works in Bash but is not guaranteed in POSIX `sh`.

### 3. Detailed Explanation

#### Comparison

| Shell | Typical role | Notes |
|-------|--------------|-------|
| `bash` | Commonly the default interactive shell on Ubuntu; verify the configured login shell for a specific user | Rich features, implements POSIX shell functionality with additional Bash extensions, widely available on Linux but not guaranteed in minimal images |
| `dash` | `/bin/sh` on Ubuntu/Debian | Small and fast, close to POSIX only; no arrays, no `[[ ]]` |
| `zsh` | Interactive shell (macOS default); powerful customisation | Mostly Bourne-compatible but differs in array indexing, word splitting and globbing |
| `fish` | Friendly interactive shell | Not POSIX-compatible; different syntax; unsuitable for portable scripts |
| `ksh` | Traditional UNIX shell | Origin of many features Bash adopted |
| `csh`/`tcsh` | Legacy | Different syntax; rarely used for scripting |
| `ash`/BusyBox `sh` | Minimal environments, Alpine Linux containers | Small POSIX-like shell; no Bash by default on Alpine |
| PowerShell | Windows (and cross-platform) automation | Object-based pipeline, completely different language |

#### Why Ubuntu uses dash for `/bin/sh`

Debian and Ubuntu moved `/bin/sh` to dash to speed up boot and package scripts. Consequences:

- A script with `#!/bin/sh` runs under dash on Ubuntu, so Bash-only syntax fails.
- `sh script.sh` ignores the script's shebang and uses `sh` explicitly.
- Interactive use still defaults to Bash because the user's login shell is `/bin/bash`.

#### Common bashisms that fail in dash

| Bash feature | Problem under `sh` (dash) |
|--------------|---------------------------|
| `[[ expression ]]` | `[[: not found` |
| Arrays `arr=(a b)` | Syntax error |
| `${var,,}` / `${var^^}` | `Bad substitution` |
| `echo -e` | Behaviour differs; dash prints `-e` literally. Prefer `printf` |
| Process substitution `<( )` | Syntax error |
| `source file` | Use `. file` in POSIX `sh` |
| `function name { }` | Use `name() { }` |
| `&>` redirection | Use `> file 2>&1` |

#### Choosing a shell for scripts

- Use **`#!/usr/bin/env bash`** (or `#!/bin/bash`) when you want Bash features. This is the default recommendation for this toolkit.
- Use **`#!/bin/sh`** only when the script must be portable to minimal environments (Alpine, BusyBox, some init scripts) and you have limited yourself to POSIX features.
- Use **Python or another language** when logic becomes complex (heavy data structures, JSON handling, large programs).

### 4. How It Works

When a script is executed, the **kernel** reads its shebang and starts the named interpreter (Topic 8). The interpreter, not your login shell, determines the syntax rules. Your login shell only matters for interactive use and for scripts that have no shebang (in which case a shell such as Bash may be used to run them as a fallback).

When Bash is invoked with the name `sh`, it enters POSIX-compatibility mode and changes some behaviour. On Ubuntu, however, `/bin/sh` is dash, not Bash in that mode.

### 5. Why It Matters in DevOps

- CI/CD systems, container images and `cron` commonly use `/bin/sh` by default, so a Bash-only snippet may fail there even though it works in your SSH session.
- Dockerfile `RUN` instructions use `/bin/sh -c` by default; Alpine images often have no Bash at all.
- EC2 user-data, `systemd` units and Ansible tasks each choose their own interpreter; being explicit avoids surprises.
- Portable scripts reduce incidents when workloads move between Ubuntu, Amazon Linux, Debian and Alpine.
- Choosing deliberately between Bash and POSIX `sh` is part of professional script design.

### 6. Syntax and Commands

```bash
ls -l /bin/sh                         # what /bin/sh points to
readlink -f /bin/sh                   # fully resolved target
cat /etc/shells                       # installed login shells
getent passwd "$USER" | cut -d: -f7   # your configured login shell
sh -c '[[ 1 == 1 ]]'                  # a bashism under sh
bash -c '[[ 1 == 1 ]]; echo "rc=$?"'  # the same test under Bash
sh -c 'echo "$0"'                     # name used by sh
command -v dash bash zsh fish         # which of these exist
```

### 7. Command-by-Command Explanation

| Command | Explanation |
|---------|-------------|
| `ls -l /bin/sh` | Shows the symlink; on Ubuntu 24.04 it points to `dash`. |
| `readlink -f /bin/sh` | Resolves all symlinks; usually prints `/usr/bin/dash`. |
| `cat /etc/shells` | Lists permitted login shells. |
| `getent passwd "$USER" \| cut -d: -f7` | Reads your account entry and prints field 7, the login shell. |
| `sh -c '[[ 1 == 1 ]]'` | Runs the test in `sh` (dash); it fails because `[[` does not exist there. |
| `bash -c '[[ 1 == 1 ]]; echo "rc=$?"'` | Same test in Bash; succeeds with status 0. |
| `command -v dash bash zsh fish` | Prints the path for each installed shell; missing ones print nothing. |

### 8. Practical Examples

**Example 1 — Prove which shell `/bin/sh` is**

```bash
ls -l /bin/sh
readlink -f /bin/sh
```

**Example 2 — Same script, different interpreter**

```bash
mkdir -p ~/practice/module-01 && cd ~/practice/module-01
printf '%s\n' '#!/usr/bin/env bash' 'if [[ -n "${BASH_VERSION:-}" ]]; then echo "Running in Bash $BASH_VERSION"; else echo "Not Bash"; fi' > which-shell.sh
bash which-shell.sh
sh which-shell.sh
```

**Example 3 — Portable replacement for `echo -e`**

```bash
printf 'Line 1\nLine 2\n'
```

**Example 4 — POSIX-compatible test**

```bash
#!/bin/sh
if [ -f /etc/os-release ]; then
    echo "os-release exists"
fi
```

### 9. Expected Output

```text
lrwxrwxrwx 1 root root 4 Mar 31  2024 /bin/sh -> dash
/usr/bin/dash
```

(Date and size values vary by image.)

```text
sh: 1: [[: not found
```

```text
rc=0
```

For Example 2:

```text
Running in Bash 5.2.21(1)-release
Not Bash
```

The first line comes from `bash which-shell.sh`; the second from `sh which-shell.sh`, because dash does not set `BASH_VERSION`.

### 10. Common Mistakes

- Using `#!/bin/sh` and then writing Bash-only code.
- Running `sh script.sh` on a Bash script and being surprised by errors.
- Assuming `/bin/sh` is Bash on every distribution (it is on some, not on Ubuntu or Debian).
- Assuming Bash exists in every container image; minimal images may only have `sh`.
- Changing the system `/bin/sh` symlink to Bash "to fix" a script. This alters system behaviour and is unnecessary; fix the script's shebang instead.
- Using `echo -e` and `echo -n` in portable scripts instead of `printf`.

### 11. Troubleshooting

| Symptom | Likely cause | Safe next step |
|---------|--------------|----------------|
| `[[: not found` | Run by dash | Use a Bash shebang or run with `bash` |
| `Bad substitution` | Bash expansion under `sh` | Same as above, or rewrite using POSIX constructs |
| `Syntax error: "(" unexpected` | Array syntax under dash | Run with Bash |
| `bash: not found` in a container | Minimal image without Bash | Write POSIX `sh` or use an image that includes Bash |
| Script works via SSH but not in CI | Different default shell | Specify the shell explicitly in the pipeline step |

### 12. Security Best Practices

- Do not replace or re-link system shells (`/bin/sh`) to work around script problems.
- Only change a user's login shell to entries listed in `/etc/shells`.
- Be wary of `#!/usr/bin/env` shebangs in privileged contexts, because they depend on `PATH` (Topic 8).
- In minimal containers, remember that fewer shells mean a smaller attack surface; do not add Bash unless needed.
- Quote variables in every shell. The quoting rules differ in subtle ways in zsh and fish; never copy scripts between shells without review.
- Do not run unreviewed scripts with *any* shell.

### 13. Interview Questions

1. **What is `/bin/sh` on Ubuntu?** A symlink to `dash`.
2. **Why does Ubuntu use dash?** It is smaller and faster for system scripts and boot.
3. **What is a bashism?** A Bash feature that is not part of POSIX `sh`.
4. **Give three bashisms.** `[[ ]]`, arrays, `${var,,}`, `<( )`, `&>`.
5. **How does `sh script.sh` differ from `./script.sh`?** `sh script.sh` forces `sh` and ignores the shebang; `./script.sh` honours the shebang.
6. **When would you choose POSIX `sh` over Bash?** For maximum portability, minimal containers or init-style scripts.
7. **Is fish suitable for portable automation scripts?** No; it is not POSIX-compatible.

### 14. Practical Exercises

1. Show what `/bin/sh` and your login shell are on your EC2 instance.
2. Write a three-line script using `[[ ]]`, run it with `bash` and with `sh`, and record both results.
3. Replace `echo -e "a\tb"` with a `printf` equivalent and test it in both shells.
4. Rewrite a `[[ -f file ]]` test as a POSIX `[ -f file ]` test.
5. List which of dash, bash, zsh and fish are installed on your server without installing anything.

### 15. Key Takeaways

- Ubuntu: Bash is interactive and the default for this toolkit; `/bin/sh` is dash.
- The shebang and the way a script is started decide which interpreter runs it.
- Bashisms fail under `sh`; use `printf`, `[ ]` and `.` for portable code.
- Choose the interpreter deliberately and state it explicitly in scripts and pipelines.
- Do not alter system shells to fix script bugs.

---

---

## 05 — Linux Command Execution


### 1. Overview

Typing `ls -l` looks simple, but the shell performs many steps: parsing, expansion, command lookup, process creation and status reporting. Understanding this pipeline is the key to diagnosing `command not found`, `Permission denied`, surprising globbing, wrong program versions and many pipeline failures.

### 2. Definition

**Command execution** is the process by which the shell turns a line of text into running work: it parses the line, performs expansions, determines what kind of command each word names, and either runs it internally (keywords, functions, builtins) or starts an external program as a new process.

### 3. Detailed Explanation

#### Types of commands

| Type | Description | Example | Runs in |
|------|-------------|---------|---------|
| Alias | Text substitution defined in the shell | `ll` → `ls -alF` | Shell (interactive only by default) |
| Keyword | Reserved word that is part of the language | `if`, `for`, `while`, `[[` | Shell |
| Function | Named block of shell code | `deploy() { commands; }` | Shell |
| Builtin | Command implemented inside Bash | `cd`, `echo`, `type`, `export` | Shell |
| External command | Executable file found on disk | `/usr/bin/ls`, `/usr/bin/git` | New child process |

#### Lookup order

For a simple command name that contains no slash, Bash resolves it in this order:

1. Aliases (when alias expansion is enabled, which is the default for interactive shells).
2. Keywords are recognised by the parser as part of the grammar.
3. Shell functions.
4. Builtins.
5. External commands: the shell checks its **hash table** of remembered locations, then searches each directory in `$PATH` from left to right and uses the first executable match.

If the command name contains a slash (`./script.sh`, `/usr/bin/ls`) **no search is performed**; that exact path is used.

#### The `PATH` variable

`PATH` is a colon-separated list of directories. The first match wins, so directory order has security and correctness implications. An empty entry or `.` in `PATH` means the current directory is searched, which is unsafe.

#### Expansion order

Bash processes a command line in this order before running it:

1. Brace expansion — `file{1,2}.txt`
2. Tilde expansion — `~`
3. Parameter and variable expansion — `$HOME`, `${var:-x}`
4. Command substitution — `$(date)`
5. Arithmetic expansion — `$((2+3))`
6. Word splitting (on unquoted results)
7. Filename expansion (globbing) — `*.log`
8. Quote removal

Quoting suppresses steps: `"$var"` prevents word splitting and globbing of the value.

#### Exit status

Every command returns an integer 0–255, stored in `$?`.

| Status | Meaning |
|--------|---------|
| `0` | Success |
| `1`–`125` | Command-specific failure |
| `126` | Command found but not executable |
| `127` | Command not found |
| `128+N` | Terminated by signal N (for example `130` = `Ctrl+C`, `SIGINT`) |

#### Command lists and pipelines

- `cmd1 ; cmd2` — run sequentially.
- `cmd1 && cmd2` — run `cmd2` only if `cmd1` succeeded.
- `cmd1 || cmd2` — run `cmd2` only if `cmd1` failed.
- `cmd1 | cmd2` — connect stdout of `cmd1` to stdin of `cmd2`; both run concurrently.
- `cmd &` — run in the background.

By default a pipeline's status is that of the **last** command; `set -o pipefail` makes it fail if any stage fails. `PIPESTATUS` holds each stage's status.

### 4. How It Works

For an external command such as `ls -l /var/log`:

1. Bash parses the line into the command `ls` with arguments `-l` and `/var/log`.
2. It resolves `ls` (alias? function? builtin? hash table? `PATH` search).
3. Bash calls `fork()`, creating a child process that is a copy of the shell.
4. In the child, Bash sets up redirections, then calls `execve("/usr/bin/ls", ["ls","-l","/var/log"], environment)`. The kernel loads the program in place of the child's code. If the file starts with `#!`, the kernel starts the interpreter instead (Topic 8).
5. The parent shell calls `wait()` (for foreground jobs) until the child exits.
6. The kernel reports the exit status, Bash stores it in `$?` and shows the next prompt.

Builtins and functions skip steps 3–4 because they run inside the current shell process.

### 5. Why It Matters in DevOps

- Explains why a pipeline step fails with `127` (missing tool or `PATH` issue) or `126` (permission problem).
- Explains "wrong version" bugs: an older binary earlier in `PATH` shadows the intended one.
- Alias definitions in `~/.bashrc` do not exist in scripts or cron jobs, which is a common cause of "works interactively only" failures.
- Understanding expansion and quoting prevents destructive bugs such as `rm -rf $dir/*` with an empty variable.
- Pipeline and exit-status knowledge is essential for reliable automation (`set -o pipefail`, `&&`, `||`).

### 6. Syntax and Commands

```bash
type ls cd if                    # classify commands
type -a echo                     # every match, in lookup order
type -t cd                       # one-word classification
command -v git                   # how git would be resolved
which -a python3                 # files named python3 in PATH
hash                             # commands remembered by the shell
hash -r                          # clear the remembered locations
echo "$PATH" | tr ':' '\n'       # PATH, one directory per line
echo hello; echo "status=$?"     # exit status of the previous command
ls /nonexistent; echo "status=$?"
nosuchcommand; echo "status=$?"
false | true; echo "${PIPESTATUS[@]}"
alias ll                         # show an alias definition
unalias ll                       # remove alias for this session (if defined)
```

### 7. Command-by-Command Explanation

| Command | Explanation |
|---------|-------------|
| `type ls cd if` | For each name prints how Bash classifies it (alias, builtin, keyword, file). |
| `type -a echo` | Lists **all** resolutions: the builtin first, then files such as `/usr/bin/echo`. |
| `type -t cd` | Prints just `alias`, `keyword`, `function`, `builtin` or `file`. Handy in scripts. |
| `command -v git` | POSIX-friendly way to find a command; prints nothing and returns non-zero if it is not found. Preferred over `which` in scripts. |
| `which -a python3` | Searches `PATH` for executables; does not know about aliases, builtins or functions. |
| `hash` / `hash -r` | Shows or clears the remembered command locations. Useful after installing a program into an earlier `PATH` directory. |
| `tr ':' '\n'` | Translates colons to newlines so each `PATH` entry is on its own line. |
| `echo "status=$?"` | `$?` must be read immediately; the next command overwrites it. |
| `"${PIPESTATUS[@]}"` | Array of exit statuses of every stage in the most recent pipeline. |
| `alias` / `unalias` | Inspect or remove aliases for the current shell session only. |

### 8. Practical Examples

**Example 1 — Why `echo` can mean three things**

```bash
type -a echo
```

**Example 2 — Aliases do not apply inside scripts**

```bash
mkdir -p ~/practice/module-01 && cd ~/practice/module-01
alias greet='echo hello from alias'
greet
printf '%s\n' '#!/usr/bin/env bash' 'greet' > alias-test.sh
bash alias-test.sh
```

**Example 3 — Safe command existence check in a script**

```bash
if ! command -v git >/dev/null 2>&1; then
    echo "git is required" >&2
    exit 1
fi
```

**Example 4 — Local script needs a path**

```bash
printf '%s\n' '#!/usr/bin/env bash' 'echo "ran"' > run-me.sh
chmod 755 run-me.sh
run-me.sh
./run-me.sh
```

**Example 5 — Pipeline status**

```bash
false | true; echo "plain status: $?"
set -o pipefail
false | true; echo "pipefail status: $?"
set +o pipefail
```

**Example 6 — Expansion order demonstration**

```bash
echo file{1,2}.txt
echo "Today is $(date +%A)"
echo $((6 * 7))
```

### 9. Expected Output

```text
echo is a shell builtin
echo is /usr/bin/echo
echo is /bin/echo
```

```text
hello from alias
alias-test.sh: line 2: greet: command not found
```

Bash prefixes the script path it was given; here the file was run as `bash alias-test.sh`, so it appears as `alias-test.sh`.

```text
run-me.sh: command not found
ran
```

The first message appears because the current directory is not in `PATH`. The exact wording can vary: an interactive Bash prefixed with its name may print `bash: run-me.sh: command not found`, and Ubuntu's command-not-found helper may append suggestions.

```text
plain status: 0
pipefail status: 1
```

```text
file1.txt file2.txt
Today is Wednesday
42
```

(The weekday depends on when you run it.)

### 10. Common Mistakes

- Running `script.sh` instead of `./script.sh`, or adding `.` to `PATH` to avoid typing `./`.
- Forgetting that `$?` changes after every command.
- Using `which` to understand shell behaviour; it ignores builtins, aliases and functions.
- Leaving variables unquoted: `rm -rf $dir/*` with `dir` empty becomes `rm -rf /*`.
- Assuming a pipeline fails if the first command fails (it does not unless `pipefail` is set).
- Expecting `cd` in a script to change the directory of the *calling* shell.
- Relying on aliases in scripts.
- Forgetting `hash -r` after installing a tool into an earlier `PATH` directory.

### 11. Troubleshooting

| Symptom | Likely cause | Safe next step |
|---------|--------------|----------------|
| `command not found` (127) | Not installed, typo, or not in `PATH` | `type name`; `echo "$PATH"`; check spelling |
| `Permission denied` (126) | File not executable, or directory not searchable | `ls -l file`; fix with `chmod u+x` only if the file is trusted |
| Old version of a tool runs | Earlier `PATH` entry or stale hash | `type -a tool`; `hash -r` |
| Command works interactively, fails in cron | `PATH` and aliases differ | Use absolute paths; set `PATH` in the script |
| `No such file or directory` for an existing script | Wrong shebang path or CRLF endings | `head -n 1 script \| cat -A` |
| Glob matches nothing and prints literally | No matching files, `nullglob` off | `ls` the directory; use `shopt -s nullglob` when intended |
| Unexpected splitting of file names | Unquoted variable | Quote it: `"$var"` |

### 12. Security Best Practices

- Never put `.` or an empty element in `PATH`; an attacker-writable directory earlier in `PATH` enables command hijacking.
- In privileged scripts set a known-safe `PATH` explicitly or call programs by absolute path.
- Quote all expansions, and use `--` to end options when handling untrusted file names (`rm -- "$file"`).
- Do not use `eval` or `bash -c "$untrusted"`.
- Do not use `sudo` unless a command truly needs elevated rights, and never `sudo` a script you have not read.
- Treat command substitution of untrusted data with care; validate before use.
- Check that files in `PATH` directories are owned by root and not world-writable.

### 13. Interview Questions

1. **What happens between pressing Enter and a program running?** Parse, expand, resolve, `fork`, `execve`, `wait`, store the exit status.
2. **What is the command lookup order?** Alias, function, builtin, then `PATH`/hash table for external commands (keywords are handled by the parser).
3. **Difference between a builtin and an external command?** Builtins run inside the shell; external commands run in a child process.
4. **What do exit statuses 126 and 127 mean?** Not executable and not found respectively.
5. **Why is `command -v` preferred over `which`?** It understands aliases, functions and builtins and is standardised.
6. **What does `set -o pipefail` do?** Makes a pipeline return the status of the rightmost failing command.
7. **Why can unquoted variables be dangerous?** They undergo word splitting and globbing, which can change the meaning of commands.
8. **Why is `.` in `PATH` unsafe?** A malicious file in the current directory could run in place of a legitimate command.

### 14. Practical Exercises

1. Use `type -a` on `ls`, `echo`, `printf` and `test`. Which have both builtin and file versions?
2. Print `PATH` one directory per line and note the order.
3. Create a function `hello() { echo "hi"; }`, run `type hello`, then `unset -f hello`.
4. Trigger exit status 127 and 126 deliberately, and show both with `echo $?`.
5. Run `false | true` with and without `pipefail` and compare.
6. Create a file called `a b.txt` and show why `rm $f` fails but `rm -- "$f"` works (remove only the file you created).

### 15. Key Takeaways

- Commands are aliases, keywords, functions, builtins or external programs.
- Lookup order and `PATH` order decide which program runs.
- External commands run via `fork` and `execve`; builtins run in the shell.
- Expansion happens before execution; quoting controls it.
- Exit statuses (`0`, `126`, `127`, `128+N`) drive automation decisions.
- Keep `PATH` clean and quote everything.

---

---

## 06 — Shell Environment


### 1. Overview

Every process on Linux runs with an *environment*: a set of name/value pairs inherited from its parent. The shell builds this environment at startup by reading configuration files, and passes it on to every program it launches. Understanding variables, `export`, inheritance and startup files explains why a script sees different values in SSH, cron, `sudo`, CI and containers.

### 2. Definition

- **Shell variable:** a name/value pair that exists only inside the current shell process.
- **Environment variable:** a variable that has been **exported**, so it is copied into the environment of child processes.
- **Shell environment:** the combined set of variables, options, aliases, functions, working directory and settings in which a shell and its children run.
- **Startup files:** scripts the shell reads automatically when it starts, to build that environment.

### 3. Detailed Explanation

#### Shell variables vs environment variables

```bash
GREETING="hello"          # shell variable: visible only in this shell
export GREETING           # now also an environment variable
export NAME="Ops"         # create and export in one step
```

Child processes receive a **copy** of the exported variables. A child can change its own copy, but it can never change the parent's. This is why running a script cannot set variables in your interactive shell (unless the script is *sourced*, Topic 9).

#### Important standard variables

| Variable | Meaning |
|----------|---------|
| `HOME` | Home directory of the user |
| `USER` / `LOGNAME` | User name |
| `SHELL` | Configured login shell |
| `PATH` | Directories searched for commands |
| `PWD` / `OLDPWD` | Current and previous directory |
| `LANG`, `LC_*` | Locale settings |
| `TERM` | Terminal type |
| `PS1` | Interactive prompt string |
| `EDITOR` / `VISUAL` | Preferred editor |
| `SHLVL` | Nesting depth of shells |
| `$$`, `$?`, `$-` | Current PID, last exit status, active shell option flags |

#### Shell types and startup files

A shell can be **interactive or not** and **login or not**. Four combinations occur in practice.

| Shell type | Typical example | Startup files read by Bash |
|------------|-----------------|----------------------------|
| Interactive **login** | SSH login, `bash -l`, `su -` | `/etc/profile`, then the first found of `~/.bash_profile`, `~/.bash_login`, `~/.profile` |
| Interactive **non-login** | Opening `bash` inside an SSH session, a desktop terminal window | `~/.bashrc` (which sources `/etc/bash.bashrc` in the default Ubuntu configuration) |
| **Non-interactive** | `bash script.sh`, cron, `bash -c 'commands'` | None, unless the variable `BASH_ENV` names a file to read |
| Non-interactive **login** | `bash -l -c 'commands'` | Same as interactive login |

Notes for Ubuntu 24.04:

- `/etc/profile` also sources files in `/etc/profile.d/`.
- The default `~/.profile` sources `~/.bashrc` when the shell is Bash, and adds `~/bin` and `~/.local/bin` to `PATH` if those directories exist. This is why login shells also get your aliases.
- The default `~/.bashrc` begins with a guard that returns immediately when the shell is not interactive. This is intentional: never print output or assume a terminal in startup files, as it can break `scp`, `rsync` and remote commands.
- When Bash is started by `sshd` to run a remote command (`ssh host cmd`), it attempts to detect that and may read `~/.bashrc`; the Ubuntu guard still prevents interactive-only settings from applying.
- `/etc/environment` is **not** a shell script. It is read by PAM for login sessions as simple `KEY=value` lines; shell syntax such as `$PATH` expansion does not work there.
- `~/.bash_logout` runs when a login shell exits.

#### Inspecting environment and shell state

`env` and `printenv` list exported variables. `set` (with no arguments) lists *all* variables and functions. `declare -p NAME` shows a variable with its attributes. `echo $-` shows option flags: the letter `i` means interactive.

#### Per-command and temporary variables

```bash
LC_ALL=C sort file.txt      # variable set only for this one command
```

#### Sourcing

`source file` (or `. file`) runs the file's commands **in the current shell**, so variables, functions and `cd` persist. Executing a script (`./file`) runs it in a **child** process, so they do not.

### 4. How It Works

1. A login (or other) shell starts and determines its type.
2. It reads the startup files for that type, which set variables, aliases, functions and `PATH`.
3. Variables marked with `export` are placed in the shell's environment table.
4. When a command runs, `fork()` copies the shell, and `execve()` passes the environment array to the new program. The program reads it with `getenv()` or similar.
5. Changes the child makes affect only the child's copy and disappear when it exits.

Other tools build their own environment: `sudo` resets most variables by default, `cron` provides a minimal environment, `systemd` units use `Environment=` and `EnvironmentFile=`, and CI systems inject their own variables.

### 5. Why It Matters in DevOps

- "Works in SSH, fails in cron" is almost always an environment difference (`PATH`, missing variables, no aliases).
- CI/CD and deployment tools pass configuration through environment variables (`AWS_REGION`, `ENVIRONMENT`, `DATABASE_URL`).
- Twelve-factor application configuration relies on environment variables.
- Misplaced startup-file content breaks `scp`, `rsync`, Ansible and other non-interactive tools.
- A polluted or overly long `PATH` can run the wrong binary or slow down lookups.
- Secrets in environment variables can leak through process inspection, crash dumps and verbose logging.

### 6. Syntax and Commands

```bash
env | sort | head -n 10               # exported variables (first 10)
printenv HOME                         # one variable's value
echo "$PATH" | tr ':' '\n'            # PATH, one entry per line
declare -p HOME PATH                  # attributes and values
MYVAR="local value"; echo "$MYVAR"    # shell variable only
bash -c 'echo "child sees: [$MYVAR]"' # child does not see it
export MYVAR; bash -c 'echo "child sees: [$MYVAR]"'
unset MYVAR                           # remove the variable
echo "$-"                             # option flags (i = interactive)
shopt login_shell                     # on/off: is this a login shell?
echo "$SHLVL"                         # shell nesting level
bash -l -c 'shopt login_shell'        # login, non-interactive
bash -c 'echo "$-"'                   # non-interactive flags
ls -la ~ | grep -E '\.(profile|bashrc|bash_logout|bash_profile)$'
```

### 7. Command-by-Command Explanation

| Command | Explanation |
|---------|-------------|
| `env \| sort \| head -n 10` | Prints exported variables, sorted, limited to ten lines. |
| `printenv HOME` | Prints the value of one exported variable (and nothing if unset). |
| `declare -p HOME PATH` | Shows variables in a re-usable form; includes the `-x` attribute when exported. |
| `MYVAR="local value"` | Creates a **shell** variable. No spaces around `=`. |
| `bash -c 'commands'` | Starts a **child** Bash, which receives only exported variables. |
| `export MYVAR` | Marks an existing variable for export to children. |
| `unset MYVAR` | Deletes the variable from the shell. |
| `echo "$-"` | Current option flags. `i` appears in interactive shells; `h`, `B` and others are defaults. |
| `shopt login_shell` | Reports whether Bash considers itself a login shell. |
| `bash -l -c 'commands'` | Runs a login shell (reads login startup files) non-interactively. |
| `ls -la ~ \| grep PATTERN` | Shows which startup files exist in your home directory. |

### 8. Practical Examples

**Example 1 — Inheritance proof**

```bash
unset DEMO
DEMO="shell-only"
bash -c 'echo "child 1 sees: [${DEMO:-}]"'
export DEMO
bash -c 'echo "child 2 sees: [${DEMO:-}]"'
bash -c 'DEMO="changed in child"; echo "child changed it"'
echo "parent still has: $DEMO"
```

**Example 2 — Temporary variable for one command**

```bash
TZ=UTC date +"%H:%M %Z"
TZ=Asia/Dhaka date +"%H:%M %Z"
```

**Example 3 — Detect the shell type**

```bash
[[ $- == *i* ]] && echo "interactive" || echo "non-interactive"
shopt -q login_shell && echo "login shell" || echo "non-login shell"
```

**Example 4 — Safe `PATH` for a script**

```bash
#!/usr/bin/env bash
set -Eeuo pipefail
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export PATH
```

**Example 5 — Safely add a personal bin directory in `~/.bashrc` (only when you intend to)**

```bash
case ":$PATH:" in
    *":$HOME/bin:"*) ;;                 # already present
    *) PATH="$HOME/bin:$PATH" ;;
esac
export PATH
```

**Example 6 — Reading startup-file behaviour**

```bash
bash -c 'echo "non-interactive flags: $-"'
bash -ic 'echo "interactive flags: $-"' 2>/dev/null
```

### 9. Expected Output

```text
child 1 sees: []
child 2 sees: [shell-only]
child changed it
parent still has: shell-only
```

```text
10:30 UTC
16:30 +06
```

(Time values depend on when you run it; a zone abbreviation such as `+06` may be displayed as a numeric offset.)

```text
interactive
login shell
```

In an SSH session you normally see `interactive` and `login shell`. In a nested `bash` it will report `non-login shell`.

```text
non-interactive flags: hBc
interactive flags: himBHc
```

Flag letters differ by shell and version. The second command normally shows an `i` in the flags (for example `himBHc`) and the first does not.

### 10. Common Mistakes

- Putting spaces around `=` (`VAR = value` runs a command called `VAR`).
- Expecting a script to modify variables of the calling shell.
- Forgetting `export` and wondering why a child program cannot see the variable.
- Putting `echo` or other output in `~/.bashrc` unguarded, which breaks `scp` and `rsync`.
- Writing `PATH=$PATH:$HOME/bin` repeatedly so `PATH` grows with every nested shell.
- Writing shell syntax into `/etc/environment`.
- Assuming cron has your interactive `PATH` and aliases.
- Putting secrets into a startup file that is world-readable.

### 11. Troubleshooting

| Symptom | Likely cause | Safe next step |
|---------|--------------|----------------|
| Alias missing after SSH login | `~/.profile` not sourcing `~/.bashrc`, or `~/.bash_profile` shadows it | `ls -la ~`; check which login file exists |
| Variable empty in a script | Not exported, or set in an unread file | `declare -p VAR`; `export VAR` before the call |
| `PATH` contains duplicates | Startup file appends on every start | Use the `case` guard shown above |
| `scp`/`rsync` fails with "protocol error" | Output printed in startup files | Guard output with `[[ $- == *i* ]]` or move to interactive-only code |
| Cron job cannot find a command | Minimal cron `PATH` | Use absolute paths or set `PATH` in the script |
| Different values under `sudo` | `sudo` resets the environment | Do not widen `sudo` permissions; pass only needed values explicitly with a reviewed approach |
| Changes in `~/.bashrc` have no effect | Not reloaded | Start a new shell, or run `source ~/.bashrc` |

### 12. Security Best Practices

- Do **not** store secrets in startup files, exported variables or scripts in the repository. Use a secrets manager (for example AWS Secrets Manager or SSM Parameter Store), or a file readable only by the owner (`chmod 600`).
- Export a secret only for the single command that needs it (`TOKEN=value command`) when a variable is unavoidable, and avoid passing secrets as command-line arguments, which are visible in process listings.
- Remember that the environment of a process can be read by the same user and by root through `/proc/<pid>/environ`.
- Never commit `.env` files containing real values to Git; add them to `.gitignore`.
- Keep startup files owned by the user and not group- or world-writable (for example `644` or stricter).
- Avoid `.`, empty entries and writable directories in `PATH`.
- Never run `printenv`, `env` or `set` in shared logs or CI output without checking for secrets.
- Review the contents of `/etc/profile.d/` and your dotfiles when investigating suspicious behaviour.

### 13. Interview Questions

1. **What is the difference between a shell variable and an environment variable?** Environment variables are exported and inherited by child processes; shell variables are not.
2. **Can a child process change its parent's variables?** No; it modifies only its own copy.
3. **What is a login shell?** The shell started at login (or with `-l`), which reads `/etc/profile` and the user's login file.
4. **Which files does an interactive non-login Bash read?** `/etc/bash.bashrc` (on Debian/Ubuntu) and `~/.bashrc`.
5. **Does a non-interactive shell read `~/.bashrc`?** Not normally; only if `BASH_ENV` points to a file (with the special case of Bash started by `sshd`).
6. **What does `source` do differently from executing a script?** It runs in the current shell, so changes persist.
7. **Why is `/etc/environment` different from `/etc/profile`?** It is parsed by PAM as `KEY=value` pairs, not executed as shell code.
8. **How do you give a variable to one command only?** Prefix it: `VAR=value command`.
9. **Why are secrets in environment variables risky?** They can leak via `/proc`, logs, crash dumps and child processes.

### 14. Practical Exercises

1. Prove inheritance: set a variable, run `bash -c` with and without `export`, and record the results.
2. Determine whether your SSH shell is login and interactive using `shopt` and `$-`.
3. Identify which of `~/.bash_profile`, `~/.bash_login` and `~/.profile` exist on your server.
4. Create `~/practice/module-01/envdemo.sh` that prints `DEMO` and run it before and after `export DEMO`.
5. Source (not execute) a file that sets a variable and shows it persists, then compare with executing it.
6. Print `PATH` one directory per line and decide whether each entry is needed and safe.

### 15. Key Takeaways

- Environment variables are exported variables inherited by child processes as copies.
- A child can never change its parent's environment.
- Startup files depend on login vs non-login and interactive vs non-interactive status.
- Keep startup files quiet for non-interactive use and keep `PATH` clean.
- Cron, `sudo`, CI and containers each build different environments; be explicit in scripts.
- Do not store or print secrets carelessly.

---

---

## 07 — Bash Script Structure


### 1. Overview

A Bash script is a text file of commands. A *good* script is predictable: it declares its interpreter, fails safely, keeps its logic in functions, cleans up after itself and reports meaningful exit codes. A consistent skeleton makes scripts easier to read, review, test and maintain, which matters when the same pattern is repeated across an entire automation toolkit.

### 2. Definition

**Script structure** is the conventional ordering of elements in a Bash script: shebang, header comments, safety options, constants, helper functions, the main logic, and the entry-point call.

### 3. Detailed Explanation

#### Recommended layout

1. **Shebang** — first line, selects the interpreter (Topic 8).
2. **Header comment** — purpose, usage, requirements, exit codes.
3. **Safety settings** — `set -Eeuo pipefail` and, optionally, `IFS` and `umask`.
4. **Constants and configuration** — `readonly` values, defaults, overridable settings.
5. **Helper functions** — logging, usage, validation, cleanup.
6. **Traps** — cleanup on `EXIT`, diagnostics on `ERR`.
7. **Main logic** — a `main()` function that orchestrates work.
8. **Entry point** — `main "$@"`.

#### The strict-mode options

| Option | Effect | Caveat |
|--------|--------|--------|
| `set -e` (`errexit`) | Exit when a simple command fails | Not triggered inside `if`/`while` conditions, `&&`/`||` lists, or negated commands, so it is a safety net, not a substitute for checking results |
| `set -u` (`nounset`) | Treat expansion of unset variables as an error | Use `${var:-default}` when a variable may legitimately be unset |
| `set -o pipefail` | Pipeline fails if any stage fails | A stage that exits non-zero by design (for example `grep` with no match) can now fail the script |
| `set -E` (`errtrace`) | `ERR` traps are inherited by functions and subshells | Needed for a useful `ERR` trap |

#### Other recommended practices

- Quote all variable expansions: `"$var"`, `"${array[@]}"`.
- Use `local` for variables inside functions and `readonly` for constants.
- Use `[[ ]]` for tests and `$(command)` for command substitution (not backticks).
- Use `printf` rather than `echo` when output must be exact.
- Send errors to standard error (`>&2`).
- Return meaningful exit codes: `0` for success, non-zero for failure.
- Avoid parsing `ls`; use globs or `find -print0` with `read -d ''` instead.
- Use `mktemp` for temporary files and remove them in an `EXIT` trap.
- Use a "main guard" if a file may be both sourced and executed.

#### Main guard (optional)

```bash
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

### 4. How It Works

1. The kernel reads the shebang and starts Bash with the script path as its argument.
2. Bash reads the file and executes commands in order, one complete command at a time.
3. Functions are only *defined* when Bash reaches them; they must be defined **before** the call that uses them executes. That is why the layout places `main "$@"` at the very bottom.
4. `set` options take effect immediately for every following command.
5. Traps register handlers that run when the shell exits or when a command fails.
6. When the script ends, Bash returns the status of the last command or the argument of `exit`.

### 5. Why It Matters in DevOps

- Production scripts run unattended, so they must fail loudly and early rather than continuing in a bad state.
- A uniform skeleton makes code review and onboarding faster across a toolkit.
- Cleanup traps prevent leftover temp files, locks and partial outputs after failures.
- Correct exit codes let CI/CD pipelines, cron monitoring and orchestration tools react properly.
- Functions and `main` make scripts testable and reusable.
- Logging to stderr/stdout in a consistent format makes troubleshooting simpler.

### 6. Syntax and Commands

```bash
#!/usr/bin/env bash                  # shebang
set -Eeuo pipefail                   # strict mode
readonly NAME="value"                # constant
local var="value"                    # inside a function only
my_func() { commands; }                     # function definition
trap 'cleanup' EXIT                  # run cleanup at exit
trap 'on_error $LINENO' ERR          # run on failing command
mktemp -d                            # secure temporary directory
exit 0                               # explicit success
return 1                             # inside a function only
"$@"                                 # all arguments, individually quoted
```

### 7. Command-by-Command Explanation

| Element | Explanation |
|---------|-------------|
| `#!/usr/bin/env bash` | Tells the kernel to run the script with the first `bash` found in `PATH`. |
| `set -Eeuo pipefail` | Combines `-E`, `-e`, `-u` and `-o pipefail` in one line. |
| `readonly` | Makes a variable immutable; accidental reassignment becomes an error. |
| `local` | Limits a variable to the function (and its callees), preventing global side effects. |
| `trap 'commands' EXIT` | Runs the handler whenever the shell exits, including after errors. |
| `trap 'commands' ERR` | Runs the handler when a command fails (subject to the `set -e` rules). |
| `mktemp -d` | Creates a uniquely named private directory under `/tmp` (mode `0700`). |
| `"$@"` | Expands to each positional argument as a separate word, preserving spaces. |
| `exit` / `return` | `exit` ends the script; `return` ends only the current function. |
| `>&2` | Redirects output to standard error. |

### 8. Practical Examples

**Example 1 — A complete, safe script skeleton: a disk-usage check**

Create it in a scratch directory (not inside the Git repository):

```bash
mkdir -p ~/practice/module-01 && cd ~/practice/module-01
cat > disk-check.sh <<'EOF'
#!/usr/bin/env bash
#
# disk-check.sh - Warn when the root filesystem usage exceeds a threshold.
#
# Usage:   ./disk-check.sh [THRESHOLD_PERCENT]
# Exit:    0 = usage at or below threshold
#          1 = usage above threshold
#          2 = invalid argument
set -Eeuo pipefail

readonly SCRIPT_NAME="${0##*/}"
readonly DEFAULT_THRESHOLD=80

TMP_DIR=""

log() {
    printf '[%s] %s: %s\n' "$(date -Is)" "$1" "$2"
}

die() {
    log ERROR "$1" >&2
    exit "${2:-1}"
}

cleanup() {
    if [[ -n "${TMP_DIR}" && -d "${TMP_DIR}" ]]; then
        rm -rf -- "${TMP_DIR}"
    fi
}

on_error() {
    log ERROR "${SCRIPT_NAME} failed near line $1" >&2
}

trap cleanup EXIT
trap 'on_error $LINENO' ERR

usage() {
    printf 'Usage: %s [THRESHOLD_PERCENT]\n' "${SCRIPT_NAME}"
}

main() {
    local threshold="${1:-${DEFAULT_THRESHOLD}}"
    local usage_percent

    if [[ ! "${threshold}" =~ ^[0-9]+$ ]] || (( threshold < 1 || threshold > 100 )); then
        usage >&2
        die "Threshold must be an integer from 1 to 100" 2
    fi

    TMP_DIR="$(mktemp -d)"
    df --output=pcent / | tail -n 1 | tr -dc '0-9' > "${TMP_DIR}/usage"
    usage_percent="$(< "${TMP_DIR}/usage")"

    if (( usage_percent > threshold )); then
        log WARN "Root filesystem usage ${usage_percent}% exceeds threshold ${threshold}%"
        return 1
    fi

    log INFO "Root filesystem usage ${usage_percent}% (threshold ${threshold}%)"
}

main "$@"
EOF
chmod 755 disk-check.sh
./disk-check.sh
./disk-check.sh 10; echo "exit status: $?"
./disk-check.sh abc; echo "exit status: $?"
```

**Example 2 — Why `set -e` is not enough**

```bash
set -e
if false; then :; fi          # does NOT exit: false is in an if-condition
false || echo "handled"       # does NOT exit: part of a || list
```

**Example 3 — Argument handling**

```bash
#!/usr/bin/env bash
set -Eeuo pipefail
if (( $# != 1 )); then
    echo "Usage: ${0##*/} <name>" >&2
    exit 2
fi
printf 'Hello, %s\n' "$1"
```

### 9. Expected Output

Timestamps and the usage percentage depend on your system. A typical run looks like:

```text
[2026-01-15T10:30:00+00:00] INFO: Root filesystem usage 23% (threshold 80%)
```

With a very low threshold:

```text
[2026-01-15T10:30:05+00:00] WARN: Root filesystem usage 23% exceeds threshold 10%
exit status: 1
```

Because the script's `ERR` trap fires when `main` returns non-zero, you may also see a line such as `[timestamp] ERROR: disk-check.sh failed near line <N>` on standard error. With an invalid argument:

```text
Usage: disk-check.sh [THRESHOLD_PERCENT]
[2026-01-15T10:30:09+00:00] ERROR: Threshold must be an integer from 1 to 100
exit status: 2
```

### 10. Common Mistakes

- Omitting the shebang or putting something (even a blank line) before it.
- Believing `set -e` catches every error.
- Leaving variables unquoted.
- Using unset variables with `set -u` active, without defaults.
- Defining functions after the code that calls them.
- Using globals everywhere instead of `local`.
- Using backticks and `ls` parsing.
- Using `cd` without checking it succeeded (`cd dir || exit 1`).
- Writing temp files to predictable names such as `/tmp/output.txt`.
- Mixing tabs and spaces inside here-documents with `<<-`.
- Returning no exit code or always exiting 0 even on failure.

### 11. Troubleshooting

| Symptom | Likely cause | Safe next step |
|---------|--------------|----------------|
| `unbound variable` | `set -u` with an unset variable | Initialise it or use `${var:-}` |
| Script exits silently mid-way | `set -e` triggered by a command returning non-zero | Run `bash -x script.sh` and look at the last traced command |
| `command not found` for a function | Function defined after its call | Move definitions above `main "$@"` |
| `syntax error: unexpected end of file` | Missing `fi`, `done`, `esac` or `}` | `bash -n script.sh` |
| Pipeline unexpectedly fails | `pipefail` plus `grep` finding nothing | Handle explicitly: `grep PATTERN \|\| true` where no-match is acceptable |
| ERR trap not firing in functions | Missing `-E` | Use `set -E` |
| Leftover temp files | No `EXIT` trap | Add a `cleanup` trap |

### 12. Security Best Practices

- Never hardcode passwords, tokens or keys; read them from a protected source at runtime.
- Validate every input (arguments, environment, files) before use, as `disk-check.sh` does with its threshold.
- Quote expansions and use `--` before user-supplied file names.
- Use `mktemp` for temporary files; never predictable names in shared directories.
- Set a restrictive `umask` (for example `umask 077`) when a script creates sensitive files.
- Avoid `eval`; avoid running with `sudo` unless needed, and then limit the privileged part.
- Set an explicit `PATH` in privileged scripts.
- Do not echo secrets into logs; avoid `set -x` around sensitive operations.
- Keep scripts in version control and review changes before they run in production.

### 13. Interview Questions

1. **What belongs at the top of every Bash script?** A shebang, then a header comment and safety options.
2. **What does `set -Eeuo pipefail` do?** Enables errtrace, errexit, nounset and pipefail.
3. **Name situations where `set -e` does not stop the script.** Conditions in `if`/`while`, commands in `&&`/`||` lists, negated commands, and some subshell/function contexts.
4. **Why use `main "$@"` at the bottom?** All functions are defined before execution begins, and arguments are passed through intact.
5. **What is the difference between `exit` and `return`?** `exit` ends the shell/script; `return` leaves a function.
6. **Why use `local`?** To avoid leaking variables into the global scope.
7. **Why use `trap handler EXIT`?** To guarantee cleanup even when the script fails or is interrupted.
8. **Why prefer `$(command)` to backticks?** It nests cleanly and is easier to read.
9. **Why should you not parse `ls`?** File names with spaces or newlines break it; use globs or `find`.

### 14. Practical Exercises

1. Create `disk-check.sh` from Example 1, run it three times (default, low threshold, invalid argument) and record the exit codes.
2. Add a `-h` option that prints usage and exits `0`.
3. Add a second check for `/var` and report both.
4. Remove the `EXIT` trap, create a temp directory and observe what is left behind after an error; then restore the trap.
5. Run the script with `bash -n` and `bash -x` and describe the difference.
6. Rewrite a script of your own so every variable is quoted and every function uses `local`.

### 15. Key Takeaways

- Use a consistent skeleton: shebang, header, safety options, constants, functions, traps, `main`, entry point.
- `set -Eeuo pipefail` helps but is not a complete safety net.
- Quote everything, use `local`, `readonly` and `[[ ]]`.
- Clean up with traps and create temporary files with `mktemp`.
- Return meaningful exit codes and write errors to stderr.
- Never hardcode secrets and always validate input.

---

---

## 08 — Shebang


### 1. Overview

The shebang is the very first line of an executable script. It tells the Linux kernel which interpreter should run the file. Without it, or with a wrong one, a script may run under the wrong shell, fail with a cryptic `bad interpreter` message, or behave differently between your terminal and an automated pipeline.

### 2. Definition

A **shebang** (also called *hashbang*, from "hash" `#` and "bang" `!`) is the two-character sequence `#!` at the very start of a file, followed by the absolute path of an interpreter and, optionally, one argument:

```text
#!/path/to/interpreter [optional-argument]
```

To the shell and to Bash itself, the line is just a comment because it starts with `#`. The meaning comes from the **kernel**.

### 3. Detailed Explanation

#### Who reads the shebang?

The kernel does, during the `execve()` system call. If the first two bytes of an executable file are `#!`, the kernel reads the rest of the line, starts that interpreter, and passes it the script's path as an argument. The shell is not involved in interpreting the shebang when a script is run directly (`./script.sh`).

#### Common shebangs

| Shebang | Meaning | Typical use |
|---------|---------|-------------|
| `#!/bin/bash` | Use Bash at a fixed path | Servers where Bash is known to be at `/bin/bash` |
| `#!/usr/bin/env bash` | Find `bash` in `PATH` | Portable across systems with Bash in different locations |
| `#!/bin/sh` | POSIX shell | Portable scripts; dash on Ubuntu |
| `#!/usr/bin/env python3` | Python 3 from `PATH` | Python scripts |
| `#!/usr/bin/env -S bash -e` | GNU `env -S` splits the arguments | Passing multiple interpreter arguments where supported |

#### `/bin/bash` vs `/usr/bin/env bash`

| Aspect | `#!/bin/bash` | `#!/usr/bin/env bash` |
|--------|---------------|------------------------|
| Predictability | Always that exact binary | Whichever `bash` is first in `PATH` |
| Portability | Fails where Bash is elsewhere (some BSD systems, Nix, some containers) | Works wherever `/usr/bin/env` exists and Bash is in `PATH` |
| Security in privileged contexts | Stronger: not influenced by `PATH` | A user-controlled `PATH` can substitute another `bash` |
| Newer Bash from a package manager | Ignored | Used if earlier in `PATH` |

This toolkit uses `#!/usr/bin/env bash` for portability. For scripts that run as root or from a restricted, security-sensitive context, prefer an absolute interpreter path.

#### Rules and limits

- `#!` must be the **first two bytes** of the file: no leading blank line, space or Byte Order Mark (BOM).
- The kernel passes everything after the interpreter path as **one single argument**, so `#!/usr/bin/env bash -e` does not work as expected. Use `env -S`, or call `set -e` inside the script.
- The interpreter must be an absolute path (the `env` trick is how `PATH` lookup is achieved).
- Historically the shebang line was limited to 127 characters; modern Linux kernels allow longer lines, but keep it short.
- Files with **Windows (CRLF) line endings** add a hidden carriage return to the interpreter name and break the shebang.
- The shebang only applies when the file is **executed directly**. `bash script.sh`, `sh script.sh` and `source script.sh` ignore it.

#### No shebang

If an executable text file has no shebang, `execve()` fails with `ENOEXEC`. Bash then typically runs the file itself as a shell script, but other callers (cron wrappers, Python's `subprocess`, other languages) may not. Always include a shebang.

### 4. How It Works

1. You run `./deploy.sh`.
2. Bash calls `execve("./deploy.sh", args, environment)`.
3. The kernel opens the file, sees `#!`, and extracts the interpreter and optional argument.
4. The kernel replaces the new process with the interpreter and calls it as `interpreter [optional-arg] ./deploy.sh args`.
5. The interpreter reads the file. The shebang line is ignored as a comment.
6. The script runs; its exit status is returned to the parent shell.

With `#!/usr/bin/env bash` there is one more hop: the kernel starts `/usr/bin/env`, which searches `PATH` for `bash` and then executes it with the script path.

### 5. Why It Matters in DevOps

- Scripts run from cron, CI/CD, systemd, Ansible and `ssh host ./script` rely on the shebang rather than the user's shell.
- A wrong shebang is a classic cause of pipeline failures on different runner images.
- Windows-to-Linux transfers (as in this project's workflow) often introduce CRLF line endings that silently break shebangs.
- Using a consistent, correct shebang across the toolkit makes behaviour predictable across Ubuntu, Debian, Amazon Linux and containers.
- It documents the interpreter's expected language, helping linters, editors and reviewers.

### 6. Syntax and Commands

```bash
head -n 1 script.sh                  # view the shebang line
file script.sh                       # file type; reveals CRLF line endings
cat -A script.sh | head -n 2         # show hidden characters ($ = LF, ^M = CR)
command -v bash                      # where bash is found in PATH
command -v env                       # confirm /usr/bin/env
printf '#!/usr/bin/env bash\necho ok\n' > t.sh   # create a minimal script
bash -n script.sh                    # syntax check; does not execute
sed -i 's/\r$//' script.sh           # remove CRs (modifies the file; keep a copy first)
```

### 7. Command-by-Command Explanation

| Command | Explanation |
|---------|-------------|
| `head -n 1 script.sh` | Prints the first line only, which should be the shebang. |
| `file script.sh` | Identifies the file; for a script it reports the interpreter and adds `with CRLF line terminators` if Windows line endings are present. |
| `cat -A` | Makes invisible characters visible. `$` marks the end of each line, `^M` marks a carriage return. |
| `command -v env` | Confirms `/usr/bin/env` is where the kernel expects it. |
| `printf 'line1\nline2' > t.sh` | Creates a file; `printf` interprets `\n` as newlines. |
| `sed -i 's/\r$//'` | Edits the file in place, deleting a trailing carriage return from every line. Make a copy first (`cp script.sh script.sh.bak`). |

### 8. Practical Examples

**Example 1 — Direct vs interpreter execution**

```bash
mkdir -p ~/practice/module-01 && cd ~/practice/module-01
printf '%s\n' '#!/usr/bin/env bash' 'echo "interpreter: $BASH_VERSION"' > shebang-demo.sh
chmod 755 shebang-demo.sh
./shebang-demo.sh
sh shebang-demo.sh
```

**Example 2 — Locate the interpreter that `env` will find**

```bash
head -n 1 shebang-demo.sh
command -v env bash
```

**Example 3 — Reproduce and diagnose a CRLF problem**

```bash
printf '#!/usr/bin/env bash\r\necho hi\r\n' > crlf-demo.sh
chmod 755 crlf-demo.sh
./crlf-demo.sh
file crlf-demo.sh
head -n 1 crlf-demo.sh | cat -A
cp crlf-demo.sh crlf-demo.sh.bak
sed -i 's/\r$//' crlf-demo.sh
./crlf-demo.sh
```

**Example 4 — Script written in a different language**

```bash
printf '%s\n' '#!/usr/bin/env python3' 'print("hello from python")' > py-demo.py
chmod 755 py-demo.py
./py-demo.py
```

**Example 5 — Passing multiple interpreter arguments portably**

```bash
#!/usr/bin/env -S bash -e
echo "env -S splits the arguments"
```

### 9. Expected Output

```text
interpreter: 5.2.21(1)-release
interpreter:
```

`./shebang-demo.sh` uses Bash. `sh shebang-demo.sh` ignores the shebang and runs dash, where `BASH_VERSION` is empty.

```text
#!/usr/bin/env bash
/usr/bin/env
/usr/bin/bash
```

For the CRLF example, the first execution fails. The exact wording depends on the coreutils version:

```text
/usr/bin/env: ‘bash\r’: No such file or directory
```

Newer versions may append a hint such as `/usr/bin/env: use -[v]S to pass options in shebang lines`. Then:

```text
crlf-demo.sh: Bourne-Again shell script, ASCII text executable, with CRLF line terminators
#!/usr/bin/env bash^M$
hi
```

After `sed` removes the carriage returns, the script prints `hi`. With a direct `#!/bin/bash` shebang the same fault produces `bad interpreter: No such file or directory` and the interpreter name shown as `/bin/bash^M`.

### 10. Common Mistakes

- A blank line or space before `#!`.
- Misspelling the interpreter path (`#!/bin/bsh`) or using a path that does not exist.
- Saving the script with Windows line endings (CRLF) or a UTF-8 BOM.
- Expecting `#!/usr/bin/env bash -e` to pass `-e`.
- Using `#!/bin/sh` for scripts with Bash-only syntax.
- Believing the shebang takes effect with `bash script.sh` or `source script.sh`.
- Putting the shebang on line 2 after a comment.
- Hardcoding `/home/user/venv/bin/python` interpreters or virtual-environment paths in shared scripts.

### 11. Troubleshooting

| Symptom | Likely cause | Safe next step |
|---------|--------------|----------------|
| `bad interpreter: No such file or directory` | Wrong path, or `^M` at the end of the line | `head -n 1 script \| cat -A`; `file script` |
| `/usr/bin/env: ‘bash\r’: No such file or directory` | CRLF line endings | Convert line endings after making a backup |
| `Exec format error` | Binary for wrong architecture, or no shebang in a non-shell caller | Check `file` output and the first line |
| `Permission denied` | Missing execute bit, or `noexec` mount | `ls -l`; `findmnt -T .` (Topic 10) |
| `[[: not found` | `#!/bin/sh` with Bash syntax | Change to `#!/usr/bin/env bash` |
| Different behaviour in cron | Different `PATH` found a different `bash` | Use an absolute interpreter path or set `PATH` |
| Script ignores the shebang | Run as `bash script` or `sh script` | Execute it directly with `./script` |

### 12. Security Best Practices

- In scripts that run as root or via `sudo`, use an absolute interpreter (`#!/bin/bash`) so a manipulated `PATH` cannot substitute a malicious `bash`.
- Never place `.` or world-writable directories in `PATH`.
- Do not make scripts `setuid`: Linux ignores the `setuid` bit on interpreted scripts for good reason, and trying to work around it is dangerous.
- Inspect a downloaded script's first line and entire contents before executing it.
- Ensure scripts are not writable by other users, so nobody can replace the interpreter line or code.
- Verify files transferred from Windows (checksums, line endings) before running them on servers.
- Avoid shebangs that point to user-writable locations (`/tmp/script-dir`, home directories).

### 13. Interview Questions

1. **What is a shebang?** `#!` followed by an interpreter path at the start of a script, read by the kernel.
2. **Who interprets the shebang, the shell or the kernel?** The kernel, during `execve()`.
3. **Difference between `#!/bin/bash` and `#!/usr/bin/env bash`?** Fixed path versus `PATH` lookup; the latter is more portable, the former is safer for privileged scripts.
4. **Does the shebang apply to `bash script.sh`?** No, the explicitly named interpreter is used.
5. **Why does `#!/usr/bin/env bash -e` not work on Linux?** The kernel passes `bash -e` as one argument; use `env -S` or `set -e`.
6. **How do CRLF line endings break a script?** The carriage return becomes part of the interpreter name.
7. **How do you detect CRLF endings?** `file script.sh` or `cat -A script.sh`.
8. **What happens if a script has no shebang?** `execve` fails with `ENOEXEC`; Bash may fall back to running it itself, other callers may not.

### 14. Practical Exercises

1. Create a script with `#!/usr/bin/env bash`, run it with `./` and with `sh`, and explain any difference.
2. Intentionally write `#!/bin/bsh`, run it, and record the error message.
3. Create a CRLF script, diagnose it with `file` and `cat -A`, then repair a **copy** of it.
4. Write a one-line Python script with an `env` shebang and run it directly.
5. Find the first line of every `.sh` file in a practice directory: `for f in *.sh; do printf '%s: ' "$f"; head -n 1 "$f"; done`.

### 15. Key Takeaways

- The shebang is read by the kernel and must be the first two bytes of the file.
- `#!/usr/bin/env bash` favours portability; an absolute path favours security in privileged contexts.
- The kernel passes only one argument after the interpreter.
- CRLF line endings are a frequent, easily diagnosed cause of failures after Windows transfers.
- The shebang is ignored when you call the interpreter explicitly.
- Never rely on `setuid` scripts and keep scripts non-writable by others.

---

---

## 09 — Creating and Executing Bash Scripts


### 1. Overview

Writing a script is simple; running it **correctly and safely** requires understanding the different ways to execute it. This topic covers creating scripts with an editor or a here-document, running them via an explicit interpreter, directly through the shebang, or by sourcing, and getting scripts onto an EC2 server from a Windows PC without breaking them.

### 2. Definition

A **Bash script** is a plain-text file containing shell commands, normally with a `.sh` extension (the extension is a convention, not a requirement). **Executing** a script means starting a process that reads and runs those commands. **Sourcing** a script means running its commands inside the *current* shell process.

### 3. Detailed Explanation

#### Creating a script

| Method | When to use |
|--------|-------------|
| `nano script.sh` or `vim script.sh` | Normal editing on the server |
| `cat > script.sh <<'EOF'` (text) `EOF` | Quickly creating a file from a pasted block; the quoted `'EOF'` prevents expansion |
| `printf 'text' > script.sh` | One-liners and tests |
| Copy from your PC with `scp` | Scripts maintained on Windows; check line endings and checksums |
| `git clone` / `git pull` | Normal workflow for repository-managed scripts |

#### Ways to run a script

| Method | Command | Needs exec bit? | Uses shebang? | Runs in |
|--------|---------|-----------------|---------------|---------|
| Explicit interpreter | `bash script.sh` | No | No (Bash is explicit) | Child process |
| Direct execution (relative) | `./script.sh` | Yes | Yes | Child process |
| Direct execution (absolute) | `/home/ubuntu/bin/script.sh` | Yes | Yes | Child process |
| Through `PATH` | `script.sh` | Yes | Yes | Child process |
| Sourcing | `source script.sh` or `. script.sh` | No | No | **Current shell** |
| Using `sh` | `sh script.sh` | No | No (`sh` is explicit; Dash on Ubuntu) | Child process (selected `sh` implementation) |

#### Child process vs sourcing

A script executed normally runs in a child process: its variables and `cd` commands vanish when it ends. A **sourced** script alters the current shell: it can set variables, define functions and change directory. Source only files that you trust and that are designed to be sourced (for example environment setup files).

#### Positional parameters and status

| Item | Meaning |
|------|---------|
| `$0` | Name or path used to start the script |
| `$1`, `$2`, `$3` and so on | Arguments |
| `$#` | Number of arguments |
| `"$@"` | All arguments, each quoted separately |
| `$?` | Exit status of the last command |
| `$$` | PID of the running shell |

#### Placing scripts on `PATH`

To run a script by name, install it in a directory listed in `PATH`. On Ubuntu, `~/bin` and `~/.local/bin` are added to `PATH` by `~/.profile` at login **if the directory exists** (open a new login session after creating it). Use a personal directory rather than system locations, so no `sudo` is needed.

#### Transferring from Windows to EC2

```text
KEY_FILE="/path/to/key.pem"
EC2_PUBLIC_IP="203.0.113.10"  # Replace with the actual server IP
scp -i "$KEY_FILE" 01-module-01-docs.sh "ubuntu@${EC2_PUBLIC_IP}:~/"
```

- Replace the key path and address with your own values; keep the `.pem` file private.
- Compare checksums before and after transfer: `Get-FileHash <file> -Algorithm SHA256` in Windows PowerShell and `sha256sum <file>` on Linux.
- Check line endings with `file` and `cat -A` (Topic 8).
- Review the script (`less script.sh`) and syntax-check it (`bash -n script.sh`) before running it.

### 4. How It Works

**`./script.sh`:** Bash checks the file exists and has the execute bit, calls `fork()`, the child calls `execve()`, the kernel reads the shebang and starts the interpreter, which reads and runs the file. Bash waits and stores the exit status in `$?`.

**`bash script.sh`:** `bash` itself is the executable that the kernel starts; the script is merely a data file passed as an argument, so the execute bit and the shebang are unnecessary (read permission is enough).

**`source script.sh`:** The current shell opens the file and executes each command itself. No new process is created, so changes persist.

### 5. Why It Matters in DevOps

- Deployment, backup and maintenance scripts are run in all of these ways by different tools (cron, CI, systemd, humans).
- Mixing up `source` and execution causes mysterious "variable not set" or "directory did not change" bugs.
- Understanding Windows-to-Linux transfer problems saves hours when moving scripts to servers.
- Verifying integrity and reading scripts before executing them is a core security habit.
- Placing scripts in a controlled location with appropriate permissions supports repeatable operations.

### 6. Syntax and Commands

```bash
mkdir -p ~/practice/module-01 && cd ~/practice/module-01
nano hello.sh                         # create with an editor
chmod u+x hello.sh                    # add execute permission for the owner
./hello.sh                            # run via shebang
bash hello.sh                         # run via explicit interpreter
source ./setvars.sh                   # run in the current shell
. ./setvars.sh                        # POSIX equivalent of source
bash -n hello.sh                      # syntax check only
less hello.sh                         # read before running
sha256sum hello.sh                    # integrity checksum
./hello.sh arg1 "arg two"; echo $?    # arguments and exit status
```

### 7. Command-by-Command Explanation

| Command | Explanation |
|---------|-------------|
| `mkdir -p DIR && cd DIR` | Creates the scratch directory if needed (`-p` avoids errors if it exists) and enters it only if creation succeeded. |
| `chmod u+x hello.sh` | Adds execute permission for the **u**ser/owner only; safer than `a+x` or `777`. |
| `./hello.sh` | The `./` supplies a path, so no `PATH` search occurs and the current directory's file is used. |
| `bash hello.sh` | Starts Bash explicitly; works even without the execute bit. |
| `source ./setvars.sh` | Reads the file in the current shell. Using `./` avoids `PATH` lookup ambiguity. |
| `bash -n hello.sh` | Parses without executing. Catches syntax errors only. |
| `less hello.sh` | Lets you read the script safely (`q` to quit). |
| `sha256sum hello.sh` | Prints a SHA-256 checksum for comparison with the source machine. |
| `echo $?` | Immediately shows the exit status of the script. |

### 8. Practical Examples

**Example 1 — Create and run a first script**

```bash
mkdir -p ~/practice/module-01 && cd ~/practice/module-01
cat > hello.sh <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail

name="${1:-World}"
printf 'Hello, %s!\n' "${name}"
printf 'Script name : %s\n' "$0"
printf 'Arguments   : %d\n' "$#"
EOF
chmod u+x hello.sh
./hello.sh
./hello.sh "Cloud Ops"
```

**Example 2 — Compare execution methods**

```bash
cat > setvars.sh <<'EOF'
#!/usr/bin/env bash
DEMO_VAR="set by script"
cd /tmp
EOF
chmod u+x setvars.sh

./setvars.sh
echo "After executing: DEMO_VAR=[${DEMO_VAR:-}] PWD=$PWD"

cd ~/practice/module-01
source ./setvars.sh
echo "After sourcing:  DEMO_VAR=[${DEMO_VAR:-}] PWD=$PWD"
cd ~/practice/module-01
```

**Example 3 — Missing execute permission**

```bash
printf '%s\n' '#!/usr/bin/env bash' 'echo "no exec bit needed with bash"' > noexec.sh
./noexec.sh; echo "status: $?"
bash noexec.sh
```

**Example 4 — Install a personal script into `~/bin`**

```bash
mkdir -p ~/bin
cp hello.sh ~/bin/hello
chmod 755 ~/bin/hello
# Open a new login session (so ~/.profile adds ~/bin to PATH), then:
hello "from PATH"
```

**Example 5 — Check a transferred script before running it**

```bash
file 01-module-01-docs.sh
head -n 1 01-module-01-docs.sh
sha256sum 01-module-01-docs.sh
bash -n 01-module-01-docs.sh && echo "syntax OK"
less 01-module-01-docs.sh
```

### 9. Expected Output

```text
Hello, World!
Script name : ./hello.sh
Arguments   : 0
Hello, Cloud Ops!
Script name : ./hello.sh
Arguments   : 1
```

```text
After executing: DEMO_VAR=[] PWD=/home/ubuntu/practice/module-01
After sourcing:  DEMO_VAR=[set by script] PWD=/tmp
```

The directory shown for `PWD` reflects your home directory. Executing leaves the parent unchanged; sourcing changes it.

```text
bash: ./noexec.sh: Permission denied
status: 126
no exec bit needed with bash
```

`sha256sum` prints a 64-character hexadecimal digest followed by the file name, and `syntax OK` appears only if `bash -n` finds no syntax errors.

### 10. Common Mistakes

- Typing `script.sh` instead of `./script.sh` when the current directory is not in `PATH`.
- Forgetting `chmod u+x` (error `Permission denied`) or granting too much (`chmod 777`).
- Running a script with `sh script.sh` and being surprised by Bash-only features failing.
- Expecting `cd` or variable assignments in an executed script to affect the calling shell.
- Sourcing scripts that were not designed to be sourced (they may call `exit` and close your session).
- Editing a script on Windows and saving with CRLF line endings.
- Running a script with `sudo` "just to make it work".
- Putting practice scripts inside the Git repository and committing them by accident.
- Adding `.` to `PATH` to avoid typing `./`.

### 11. Troubleshooting

| Symptom | Likely cause | Safe next step |
|---------|--------------|----------------|
| `command not found` for `script.sh` | Not in `PATH` | Run `./script.sh` or install into a `PATH` directory |
| `Permission denied` | No execute bit, or `noexec` mount | `ls -l script.sh`; run with `bash script.sh` as a test; `findmnt -T .` |
| `bad interpreter` / `^M` | CRLF endings or wrong shebang | `file script.sh`; `cat -A script.sh \| head -n 1` |
| `No such file or directory` for an existing script | Interpreter path in shebang is wrong | `head -n 1 script.sh`; `command -v bash` |
| Variables not available afterwards | Script was executed, not sourced | Use `source` only if the script is designed for it |
| Terminal closed after running a script | Sourced script called `exit` | Run it as a child process instead |
| Script works manually, fails in cron | Different `PATH`/environment | Use absolute paths; set `PATH` explicitly |
| Checksums differ after transfer | Corrupted or altered file, or wrong version | Re-transfer; do not execute until they match |

### 12. Security Best Practices

- Never execute a script you have not read, especially downloads. Avoid `curl URL | bash`; download first, inspect, then run.
- Verify transferred scripts with checksums, and keep private keys (`.pem`) at `chmod 400` or `600`.
- Use the narrowest permissions that work: `chmod 700` for personal scripts, `chmod 755` for shared read-only tools; never `777`.
- Do not run scripts with `sudo` unless the script genuinely needs elevated rights, and then read it first.
- Source only trusted files, and prefer an absolute or `./` path when sourcing.
- Never hardcode credentials in scripts; avoid passing secrets as command-line arguments.
- Keep scripts in directories that only you (or trusted administrators) can write to.
- Delete installer or helper scripts after verified use if they are no longer needed.

### 13. Interview Questions

1. **How can you run a Bash script?** `bash script.sh`, `./script.sh` (with execute bit), through `PATH`, or `source script.sh`.
2. **Difference between `./script.sh` and `bash script.sh`?** The first needs the execute bit and uses the shebang; the second needs only read permission and explicitly selects Bash.
3. **Difference between executing and sourcing?** Execution uses a child process; sourcing runs in the current shell, so changes persist.
4. **Why does `script.sh` fail while `./script.sh` works?** The current directory is not in `PATH`.
5. **What does exit status 126 mean?** The command was found but could not be executed (often permissions).
6. **What do `$0`, `$1`, `$#` and `"$@"` represent?** Script name, first argument, argument count, all arguments quoted.
7. **Why avoid `curl URL | bash`?** You execute unseen code, possibly modified or incomplete, with your privileges.
8. **How would you check a script transferred from Windows?** Compare checksums, check line endings, run `bash -n`, read it.

### 14. Practical Exercises

1. Create `hello.sh` as in Example 1 and run it with no argument and with two arguments.
2. Run it with `bash hello.sh`, `./hello.sh` and `sh hello.sh`. Record any differences.
3. Remove the execute bit (`chmod u-x hello.sh`), run `./hello.sh`, record the status, then restore it.
4. Demonstrate execute-versus-source with a script that sets a variable and changes directory.
5. Copy a script to `~/bin`, open a new login session and run it by name.
6. Generate a checksum on Windows and on EC2 for the same file and confirm they match.

### 15. Key Takeaways

- Create scripts with an editor or a quoted here-document, and practise outside the Git repository.
- `./script.sh` uses the shebang and execute bit; `bash script.sh` does not need either.
- Executing runs a child process; sourcing changes the current shell.
- Always read, syntax-check and verify scripts before running them, especially transferred or downloaded ones.
- Use the narrowest permissions and avoid `sudo` unless necessary.
- Watch for CRLF line endings when moving files from Windows.

---

---

## 10 — Executable Permissions


### 1. Overview

Linux controls who may read, modify and run every file through a compact permission model. A script cannot be run directly (`./script.sh`) unless the executing user has the **execute** permission on it. Setting permissions correctly, and no more broadly than necessary, is a core security skill and a daily DevOps task.

### 2. Definition

**File permissions** are attributes stored with each file that define what the **owner**, the file's **group**, and **others** (everyone else) may do: **r**ead, **w**rite and e**x**ecute. The command `chmod` ("change mode") modifies them.

### 3. Detailed Explanation

#### Reading `ls -l`

```text
-rwxr-xr-x 1 ubuntu ubuntu 214 Jan 15 10:30 deploy.sh
│└┬┘└┬┘└┬┘   │      │
│ │  │  │    │      └─ group
│ │  │  │    └──────── owner
│ │  │  └───────────── others:  r-x
│ │  └──────────────── group:   r-x
│ └─────────────────── owner:   rwx
└───────────────────── file type: - regular file, d directory, l symbolic link
```

#### What each permission means

| Permission | On a file | On a directory |
|------------|-----------|----------------|
| `r` (read) | Read the contents | List the names inside |
| `w` (write) | Modify the contents | Create, rename or delete entries inside (also needs `x`) |
| `x` (execute) | Run the file as a program or script | Enter (traverse) the directory and access items by name |

For a script run **directly** on Linux, the user needs `x` on the file and `x` on every directory in its path. For a shebang-based interpreted script, the kernel starts the interpreter and provides access to the script; the caller does not generally need a separate `r` permission on the script. Running `bash script.sh` requires `r` permission because Bash must read the script.

#### Octal (numeric) notation

Read = 4, write = 2, execute = 1; add them for each class.

| Octal | Symbolic | Typical use |
|-------|----------|-------------|
| `600` | `rw-------` | Private files, SSH private keys |
| `644` | `rw-r--r--` | Normal documents (including Markdown) |
| `700` | `rwx------` | Private scripts and private directories |
| `750` | `rwxr-x---` | Scripts shared with a group |
| `755` | `rwxr-xr-x` | Shared, read-only tools and public directories |
| `777` | `rwxrwxrwx` | **Avoid**: anyone can modify and execute |

#### Symbolic notation with `chmod`

```text
chmod u+x file         add execute for the owner (user)
chmod g-w file         remove write for the group
chmod o-rwx file       remove all access for others
chmod a+r file         add read for all (a = u+g+o)
chmod u=rwx,go=rx file set exact permissions
```

#### `umask`

The `umask` masks permission bits when files and directories are created. New files normally start from a base mode of `666` and directories from `777`; the resulting permissions are calculated by applying the bitwise operation `base_mode & ~umask`. A umask of `022` produces files `644` and directories `755`; `002` produces `664` and `775`; `077` produces `600` and `700`. Ubuntu commonly uses `002` for regular users with private user groups, but this can vary by configuration; check with `umask`.

#### Ownership

`ls -l` shows the owner and group. Changing ownership with `chown` normally requires administrator privileges and is rarely needed for personal scripts. If a file is owned by the wrong user, fix the cause (for example, a previous `sudo` run) rather than loosening permissions.

#### Special bits (awareness only)

| Bit | Effect | Note |
|-----|--------|------|
| `setuid` | Run with the file owner's identity | **Ignored for interpreted scripts on Linux**; do not use for scripts |
| `setgid` | Run with the group, or inherit group on directories | Used on shared directories |
| sticky | Restricts deleting or renaming entries to the file owner, directory owner, or a privileged process | Used on `/tmp` |

#### Git and the execute bit

Git records whether a file is executable (mode `100755` vs `100644`). Check with `git ls-files --stage <file>`. A file that loses its execute bit in a commit will fail when others clone it and run `./script.sh`.

#### Mount options

A filesystem mounted with `noexec` refuses to run programs from it, even with `x` set. `findmnt -T <path>` shows the options. This is a security hardening measure (commonly applied to `/tmp` and data volumes).

### 4. How It Works

1. When a process calls `execve()` on a file, the kernel checks the file's mode bits against the process's effective user ID and group IDs.
2. The kernel picks **one** class: owner if the user owns the file, otherwise group if the user is in the group, otherwise others. Only that class's bits apply.
3. If the `x` bit is missing for that class, the call fails with `EACCES` and Bash reports `Permission denied` with exit status `126`.
4. The kernel also checks directory traversal (`x`) along the path and the mount's `noexec` flag.
5. `chmod` changes the mode bits stored in the file's inode; only the owner (or an administrator) can change them.

### 5. Why It Matters in DevOps

- Deployment and automation scripts must be executable by the right account (and by no one else).
- Overly broad permissions are a common finding in security audits and a route for privilege escalation.
- SSH refuses private keys that are too open, and many tools refuse world-writable config files.
- Lost execute bits in Git cause "Permission denied" failures in CI and on freshly cloned servers.
- Correct permissions on directories and logs ensure services can write where they must and nowhere else.

### 6. Syntax and Commands

```bash
ls -l script.sh                        # show permissions, owner, group
ls -ld ~/practice                      # permissions of the directory itself
stat -c '%a %A %U:%G %n' script.sh     # octal, symbolic, owner:group, name
chmod u+x script.sh                    # owner may execute
chmod 700 script.sh                    # rwx for owner only
chmod 755 tool.sh                      # rwx owner, r-x group and others
chmod 644 notes.md                     # normal document
chmod go-w script.sh                   # remove group/other write
umask                                  # show the current umask
find . -type f -name '*.sh' ! -perm -u+x          # scripts missing the owner execute bit
find . -xdev -type f -perm -0002                  # world-writable files
git ls-files --stage script.sh                    # mode recorded by Git
findmnt -T .                                      # mount options for the current path
```

### 7. Command-by-Command Explanation

| Command | Explanation |
|---------|-------------|
| `ls -l` | Long listing with permission string, link count, owner, group, size and date. |
| `ls -ld dir` | Shows the directory's own entry rather than its contents. |
| `stat -c '%a %A %U:%G %n'` | Prints octal mode (`%a`), symbolic mode (`%A`), owner and group, and file name. |
| `chmod u+x` | Adds execute for the owner; the narrowest change that lets you run your own script. |
| `chmod 700` / `755` / `644` | Sets all nine bits explicitly in octal. |
| `chmod go-w` | Removes write permission from group and others. |
| `umask` | Prints the mask applied to new files, such as `0002` or `0022`. |
| `find DIR ! -perm -u+x` | Finds `.sh` files where the owner's execute bit is **not** set (`!` negates, `-perm -u+x` means "at least these bits"). |
| `find DIR -perm -0002` | Finds files whose "other write" bit is set; `-xdev` stays on one filesystem. |
| `git ls-files --stage` | Shows the mode Git stores (`100755` executable, `100644` not). |
| `findmnt -T .` | Displays the mount containing the path and its options, such as `noexec`. |

### 8. Practical Examples

**Example 1 — Observe permissions changing**

```bash
mkdir -p ~/practice/module-01 && cd ~/practice/module-01
printf '%s\n' '#!/usr/bin/env bash' 'echo "permission demo"' > perm-demo.sh
ls -l perm-demo.sh
./perm-demo.sh; echo "status: $?"
chmod u+x perm-demo.sh
ls -l perm-demo.sh
./perm-demo.sh
```

**Example 2 — Symbolic and numeric forms are equivalent**

```bash
chmod 700 perm-demo.sh && stat -c '%a %A' perm-demo.sh
chmod u=rwx,go= perm-demo.sh && stat -c '%a %A' perm-demo.sh
chmod 755 perm-demo.sh && stat -c '%a %A' perm-demo.sh
```

**Example 3 — Read permission matters for `bash script.sh`**

```bash
chmod 300 perm-demo.sh       # write + execute, no read
./perm-demo.sh; echo "status: $?"  # Linux shebang execution can succeed
bash perm-demo.sh; echo "status: $?"  # Bash cannot read the script
chmod 700 perm-demo.sh       # restore
```

**Example 4 — Audit a directory for risky permissions**

```bash
find ~/practice -xdev -type f -perm -0002
find ~/practice -type f -name '*.sh' ! -perm -u+x
```

**Example 5 — Effect of `umask`**

```bash
(umask 077; touch private.txt; mkdir private-dir; stat -c '%a %n' private.txt private-dir)
(umask 022; touch shared.txt;  mkdir shared-dir;  stat -c '%a %n' shared.txt  shared-dir)
```

**Example 6 — Check how Git sees the execute bit (inside a repository, read-only commands)**

```bash
git -C ~/bash-script ls-files --stage | head -n 5
git -C ~/bash-script config core.fileMode
```

### 9. Expected Output

```text
-rw-rw-r-- 1 ubuntu ubuntu 53 Jan 15 10:30 perm-demo.sh
bash: ./perm-demo.sh: Permission denied
status: 126
-rwxrw-r-- 1 ubuntu ubuntu 53 Jan 15 10:30 perm-demo.sh
permission demo
```

(The initial mode depends on your `umask`; it may be `-rw-r--r--` if the umask is `022`.)

```text
700 rwx------
700 rwx------
755 rwxr-xr-x
```

```text
permission demo
status: 0
bash: perm-demo.sh: Permission denied
status: 126
```

In Example 3, direct execution can succeed on Linux because the kernel can invoke the shebang interpreter without requiring the caller to have separate read permission. However, `bash perm-demo.sh` fails because Bash cannot read the script. Exact behaviour can depend on the operating system and filesystem.

```text
600 private.txt
700 private-dir
644 shared.txt
755 shared-dir
```

`git ls-files --stage` prints entries such as `100644 <hash> 0 README.md`; executable files show `100755`. `core.fileMode` normally prints `true` on Linux.

### 10. Common Mistakes

- Using `chmod 777` (or `chmod -R 777`) to "fix" a permissions error.
- Running `chmod +x` on every file recursively, making data and documents executable.
- Forgetting directory execute permission, then being unable to enter or access files in it.
- Using `sudo` to run or edit files, leaving root-owned files in your home directory.
- Making a script writable by group or others so it can be tampered with.
- Setting `644` on SSH private keys (SSH rejects it; use `600`).
- Assuming `setuid` works on shell scripts.
- Ignoring `noexec` mounts when `x` appears to be set but execution still fails.
- Forgetting that `chmod` changes do not "stick" for Windows-mounted or special filesystems.

### 11. Troubleshooting

| Symptom | Likely cause | Safe next step |
|---------|--------------|----------------|
| `Permission denied` running `./script.sh` | Missing `x` for your user | `ls -l script.sh`; `chmod u+x script.sh` if you trust the script |
| `Permission denied` even with `x` set | Parent directory lacks `x`, or `noexec` mount | `namei -l /full/path/script.sh`; `findmnt -T /full/path` |
| `chmod: changing permissions of 'commands': Operation not permitted` | You do not own the file | `ls -l`; check who owns it and why; avoid blanket `sudo` |
| File owned by `root` in your home | A previous command was run with `sudo` | Identify the cause; ask whether an administrator should correct ownership |
| `WARNING: UNPROTECTED PRIVATE KEY FILE!` | Key permissions too open | `chmod 600 key.pem` (or `400`) |
| `bash script.sh` fails with `Permission denied` | No read permission | Restore `r` for the owner, e.g. `chmod u+r script.sh` |
| Script not executable after `git clone` | Execute bit not committed | Check `git ls-files --stage`; fix in a deliberate, reviewed commit |
| New files have unexpected permissions | Unexpected `umask` | `umask`; set it appropriately in the script or startup file |

### 12. Security Best Practices

- Apply the **principle of least privilege**: grant the minimum permissions required, to the fewest users.
- Prefer `700` for personal scripts, `750` for group-shared scripts and `755` only for intentionally shared tools; never `777` or world-writable files.
- Keep SSH private keys at `600` or `400`, and the `~/.ssh` directory at `700`.
- Keep files that hold secrets at `600` and out of version control.
- Use `chmod u+x` for a single file instead of recursive `chmod -R +x`.
- Do not run scripts as root unless needed; never make a script `setuid`.
- Regularly audit for world-writable files and unexpected executables (`find DIR -perm -0002`).
- Treat `sudo chmod` and `sudo chown` as exceptional operations that require understanding of the cause and effect.
- Consider `noexec` on temporary and data mounts as part of system hardening (changing mount options is an administrator decision outside this module).

### 13. Interview Questions

1. **What do `r`, `w` and `x` mean for files and directories?** Read/write/execute for files; list/modify entries/traverse for directories.
2. **What does `chmod 755` mean?** Owner `rwx`, group and others `r-x`.
3. **What is the difference between `chmod u+x` and `chmod a+x`?** The first grants execute only to the owner; the second to everyone.
4. **Why is `chmod 777` dangerous?** Any user or process can modify and execute the file, enabling tampering and privilege escalation.
5. **How does `umask` work?** It removes permission bits from the default `666` (files) and `777` (directories).
6. **What does exit status 126 mean?** The command was found but cannot be executed.
7. **Why does a directory need `x`?** To traverse it and access items by name.
8. **Does `setuid` work on shell scripts in Linux?** No, it is ignored for interpreted scripts.
9. **How do you find world-writable files?** `find <dir> -xdev -type f -perm -0002`.
10. **How does Git track executability?** Through mode `100755` vs `100644` stored for each file.

### 14. Practical Exercises

1. Create a script, observe `Permission denied`, add execute with `chmod u+x`, and run it.
2. Express `rwxr-x---` in octal and set it on a practice script, verifying with `stat`.
3. Create files under `umask 077` and `umask 022` in subshells and compare their modes.
4. Use `find` to locate `.sh` files in `~/practice` that are not executable by their owner.
5. Create a file with `chmod 666`, find it with the world-writable `find` command, then correct it to `644`.
6. Use `namei -l` on a path to see the permissions of each directory component.

### 15. Key Takeaways

- Permissions are `rwx` for owner, group and others; the kernel applies only the first matching class.
- `chmod u+x` is the minimal change to make your own script runnable.
- Common modes: `600`, `644`, `700`, `750`, `755`; avoid `777`.
- Directories need `x` to be entered; `noexec` mounts block execution regardless of `x`.
- Exit status `126` signals a "cannot execute" problem.
- Least privilege, no unnecessary `sudo`, and regular audits keep systems safe.

---

---

## 11 — Bash Script Debugging Fundamentals


### 1. Overview

Every script fails eventually. Debugging is the disciplined process of finding out *why*, quickly and without making things worse. Bash gives you built-in tools: a syntax checker (`bash -n`), an execution tracer (`bash -x`, `set -x`), verbose mode (`set -v`), strict-mode options and traps. Used well, they turn "it doesn't work" into a precise line number and a concrete cause.

### 2. Definition

**Debugging** is the systematic identification and correction of defects. In Bash this means:

- **Static checking:** parsing a script for syntax errors without running it (`bash -n`).
- **Tracing:** printing each command, after expansion, as it executes (`-x` / `xtrace`).
- **Verbose mode:** printing each line as it is read, before expansion (`-v` / `verbose`).
- **Defensive options and traps:** making failures visible early (`set -Eeuo pipefail`, `trap handler ERR`).

### 3. Detailed Explanation

#### The main tools

| Tool | Command | What it does | Runs the script? |
|------|---------|--------------|------------------|
| Syntax check | `bash -n script.sh` | Reads and parses; reports syntax errors | **No** |
| Trace | `bash -x script.sh` | Prints each command after expansion, prefixed with `+` | Yes |
| Trace a region | `set -x` and `set +x` | Turns tracing on and off inside the script | Yes |
| Verbose | `bash -v script.sh` / `set -v` | Prints each input line before execution | Yes |
| Combined | `bash -nv script.sh` | Syntax check with echoed lines | No |
| Strict mode | `set -Eeuo pipefail` | Fails on errors, unset variables and pipeline failures | Yes |
| Error trap | `trap 'echo "line $LINENO"' ERR` | Reports where a failing command occurred | Yes |

#### What `bash -n` can and cannot do

`bash -n` finds problems such as an unterminated `if` (missing `fi`), unbalanced quotes or a stray parenthesis. It **cannot** find runtime problems: misspelled command names, missing files, wrong variable values, logic errors or permission issues.

#### Understanding the trace

Each traced line begins with the value of `PS4` (default `+ `). Repeated characters show nesting depth, for example `++` for a command inside a command substitution or function call. Variable values appear **after** expansion, so you see exactly what Bash will run. Trace output goes to standard error.

#### Making traces informative with `PS4`

```bash
export PS4='+ ${BASH_SOURCE##*/}:${LINENO}: ${FUNCNAME[0]:-main}: '
```

This prints the file, line number and function for every traced command. Tracing uses the **first character** of `PS4` repeated to show nesting depth.

#### Useful special variables

| Variable | Meaning |
|----------|---------|
| `LINENO` | Current line number |
| `BASH_SOURCE` | Array of source file names for the call stack |
| `FUNCNAME` | Array of function names in the call stack |
| `BASH_COMMAND` | The command currently executing (useful inside traps) |
| `PIPESTATUS` | Array of exit statuses of the last pipeline |
| `$?` | Exit status of the last command |

#### Redirecting the trace

```bash
bash -x script.sh 2> trace.log                 # trace plus other stderr to a file
exec 9> trace-fd.log; BASH_XTRACEFD=9; set -x  # dedicated trace file descriptor
```

#### A repeatable debugging method

1. **Reproduce** the problem and record the exact command and exit status.
2. **Check syntax:** `bash -n script.sh`.
3. **Check the basics:** shebang, line endings (`file`), permissions, `PATH`, working directory.
4. **Trace:** `bash -x script.sh`, then focus on the failing area with `set -x` / `set +x`.
5. **Inspect values:** print variables with `declare -p var` or `printf '%q\n' "$var"` to expose spaces and special characters.
6. **Isolate:** reduce the script to the smallest failing case.
7. **Fix, rerun, and keep the test:** confirm the fix and record how to prevent recurrence.

### 4. How It Works

- `bash -n` makes Bash read and parse the whole script without executing commands.
- With `-x`, Bash sets the `xtrace` option. Before executing each simple command, it expands the words, then writes `PS4` plus the expanded command to standard error, and only then runs it.
- `set -x` and `set +x` toggle the same option at runtime; the trace includes the `set +x` command itself when turning tracing off.
- `trap handler ERR` registers a handler that runs when a command fails under the same conditions in which `set -e` would trigger; `set -E` (`errtrace`) extends ERR-trap inheritance to functions, command substitutions and subshell environments.
- `-u` makes the expansion of an unset variable a fatal error, converting silent empty strings into a clear message with the line number.

### 5. Why It Matters in DevOps

- Production automation fails at inconvenient times; fast diagnosis reduces downtime.
- CI/CD logs often show only the last error line; traces and clear exit statuses reveal the cause.
- Syntax checking in a pipeline step catches broken scripts before they reach a server.
- Disciplined debugging avoids risky "try random fixes on production" behaviour.
- Trace logs are valuable for post-incident reviews, but they must be handled carefully because they can expose secrets.

### 6. Syntax and Commands

```bash
bash -n script.sh                         # syntax check only
bash -x script.sh                         # trace the whole script
bash -x script.sh arg1 arg2               # trace with arguments
bash -nv script.sh                        # verbose syntax check
bash -x script.sh 2> trace.log            # save trace and errors
export PS4='+ ${BASH_SOURCE##*/}:${LINENO}: ${FUNCNAME[0]:-main}: '
set -x                                    # in a script: start tracing
set +x                                    # in a script: stop tracing
set -Eeuo pipefail                        # fail fast
trap 'echo "ERR at line $LINENO: $BASH_COMMAND" >&2' ERR
declare -p variable_name                  # show a variable exactly
printf '%q\n' "$value"                    # shell-quoted, reveals hidden characters
echo "${PIPESTATUS[@]}"                   # statuses of each pipeline stage
file script.sh; cat -A script.sh | head   # line endings and invisible characters
```

### 7. Command-by-Command Explanation

| Command | Explanation |
|---------|-------------|
| `bash -n script.sh` | Parse only. Exit status `0` means no syntax errors were found; it says nothing about runtime behaviour. |
| `bash -x script.sh` | Run with `xtrace`; each command is printed (after expansion) to stderr with the `PS4` prefix. |
| `bash -nv script.sh` | Combine `-n` (no execution) and `-v` (echo lines as read). |
| `2> trace.log` | Redirects standard error (where traces go) to a file. Treat the file as sensitive. |
| `export PS4=<prefix>` | Customises the trace prefix with file, line and function. |
| `set -x` / `set +x` | Enable or disable tracing for a region of the script. |
| `set -Eeuo pipefail` | Strict mode (see Topic 7). |
| `trap 'commands' ERR` | Runs the handler when a command fails; `$BASH_COMMAND` holds the failing command. |
| `declare -p var` | Prints the variable's attributes and value precisely. |
| `printf '%q\n' "$value"` | Prints the value escaped so spaces, tabs and newlines become visible. |
| `${PIPESTATUS[@]}` | Shows which stage of a pipeline failed. |
| `cat -A` | Shows line endings and non-printing characters. |

### 8. Practical Examples

**Example 1 — Catch a syntax error without running anything**

```bash
mkdir -p ~/practice/module-01 && cd ~/practice/module-01
printf '%s\n' '#!/usr/bin/env bash' 'if [[ -f /etc/os-release ]]; then' '  echo "found"' > broken.sh
bash -n broken.sh; echo "status: $?"
```

**Example 2 — Trace a working script**

```bash
cat > trace-demo.sh <<'EOF'
#!/usr/bin/env bash
name="Cloud Ops"
echo "Hello, $name"
count=3
echo "Count is $count"
EOF
bash -x trace-demo.sh
```

**Example 3 — Trace only a region with a helpful `PS4`**

```bash
cat > region-demo.sh <<'EOF'
#!/usr/bin/env bash
export PS4='+ ${BASH_SOURCE##*/}:${LINENO}: ${FUNCNAME[0]:-main}: '

greet() { echo "in greet"; }

echo "not traced"
set -x
greet
set +x
echo "not traced again"
EOF
bash region-demo.sh
```

**Example 4 — Catch an unset variable**

```bash
cat > unset-demo.sh <<'EOF'
#!/usr/bin/env bash
set -u
echo "start"
echo "$undefined_var"
echo "never reached"
EOF
bash unset-demo.sh; echo "status: $?"
```

**Example 5 — Find the failing stage of a pipeline**

```bash
bash -c 'false | true | cat; echo "stages: ${PIPESTATUS[@]}"'
```

**Example 6 — Report the failing line with an `ERR` trap**

```bash
cat > err-demo.sh <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail
trap 'echo "ERR at line $LINENO: $BASH_COMMAND" >&2' ERR
echo "step 1"
ls /nonexistent-directory
echo "step 2"
EOF
bash err-demo.sh; echo "status: $?"
```

**Example 7 — Keep secrets out of traces**

```bash
#!/usr/bin/env bash
set -Eeuo pipefail
set -x
echo "tracing is on for normal work"
set +x                      # turn tracing off before handling a secret
TOKEN="$(cat "$HOME/.example-token")"
call_api_with_token "${TOKEN}"  # keep tracing disabled: the expanded token is sensitive
unset TOKEN                 # remove the secret from the shell variable
set -x                      # optionally turn tracing back on after secret handling
```

### 9. Expected Output

```text
broken.sh: line 4: syntax error: unexpected end of file
status: 2
```

(Bash reports the line where it reached the end of file; the number can differ slightly with other mistakes.)

```text
+ name='Cloud Ops'
+ echo 'Hello, Cloud Ops'
Hello, Cloud Ops
+ count=3
+ echo 'Count is 3'
Count is 3
```

```text
not traced
+ region-demo.sh:8: main: greet
+ region-demo.sh:4: greet: echo 'in greet'
in greet
+ region-demo.sh:9: main: set +x
not traced again
```

```text
start
unset-demo.sh: line 4: undefined_var: unbound variable
status: 1
```

```text
stages: 1 0 0
```

```text
step 1
ls: cannot access '/nonexistent-directory': No such file or directory
ERR at line 5: ls /nonexistent-directory
status: 2
```

(`ls` returns 2 for a missing operand, and `set -e` exits the script with that status.)

### 10. Common Mistakes

- Assuming `bash -n` proves a script works; it checks syntax only.
- Leaving `set -x` enabled around secrets, so tokens and passwords appear in logs.
- Debugging by editing production scripts directly instead of copying and testing safely.
- Ignoring the **first** error message; later errors are often consequences.
- Forgetting to quote variables, then misreading the trace because spaces split words.
- Reading `set -e` as a guarantee; failures in conditions or `||` lists do not abort.
- Using `echo` to inspect values when `declare -p` or `printf '%q'` would expose hidden characters.
- Forgetting that trace output goes to **stderr**, so `> file` does not capture it.
- Testing with a different user, directory or environment than the failing run (cron, CI).

### 11. Troubleshooting

| Symptom | Likely cause | Safe next step |
|---------|--------------|----------------|
| `syntax error: unexpected end of file` | Missing `fi`, `done`, `esac` or `}`, or unbalanced quotes | `bash -n script.sh`; check indentation and matching keywords |
| `syntax error near unexpected token` | Stray character, CRLF line endings, missing `;` | `cat -A script.sh`; `file script.sh` |
| `unbound variable` | `set -u` with a misspelled or unset variable | Initialise it or use `${var:-default}` |
| Script stops silently | `set -e` after a non-zero status | `bash -x script.sh`; inspect the last traced command |
| Works manually, fails in cron/CI | Different environment | Compare `env`, `PATH` and working directory; log them (without secrets) |
| Variable looks right but test fails | Hidden whitespace or CR characters | `printf '%q\n' "$var"`; `declare -p var` |
| `command not found` | Typo or `PATH` | `type name`; `command -v name` |
| Trace too noisy | Whole script traced | Use `set -x` / `set +x` around the suspicious region |
| `Permission denied` | Mode bits or `noexec` mount | Topic 10 checks: `ls -l`, `namei -l`, `findmnt -T` |

### 12. Security Best Practices

- **Treat trace output as sensitive.** `xtrace` prints expanded values, which can include passwords, API keys and tokens. Turn it off (`set +x`) around any command that handles secrets, and never ship trace logs to shared locations without reviewing them.
- Do not paste traces or logs into public tickets, chats or repositories before removing credentials.
- Restrict trace and debug files to the owner (`chmod 600 trace.log`) and delete them when finished.
- Debug on a copy of the script and, where possible, a non-production system.
- Do not run unknown scripts "to see what happens"; read them and use `bash -n` first.
- Avoid `sudo` while debugging unless the failure itself concerns privileged access, and keep the privileged section minimal.
- Do not add temporary insecure workarounds (`chmod 777`, disabling checks) and forget to remove them.
- Prefer secrets from protected files or secret managers over command-line arguments, which appear in process listings and traces.

### 13. Interview Questions

1. **What does `bash -n` do?** Parses the script and reports syntax errors without executing it.
2. **What does `bash -x` do?** Traces each command after expansion to standard error with a `+` prefix.
3. **Difference between `set -x` and `bash -x`?** `bash -x` traces the whole run; `set -x` / `set +x` trace a chosen region.
4. **What is `PS4`?** The prompt prefix used for trace lines; customise it with `LINENO` and `FUNCNAME`.
5. **What is the difference between `-x` and `-v`?** `-v` prints lines as read (before expansion); `-x` prints commands as executed (after expansion).
6. **Why can `set -x` be a security risk?** It writes expanded secrets into logs.
7. **How do you find which command in a pipeline failed?** Use `PIPESTATUS`, or `set -o pipefail` to make the pipeline fail.
8. **Why might `bash -n` pass while the script still fails?** It does not detect runtime errors such as missing files or logic bugs.
9. **How do you show where an error occurred?** An `ERR` trap that prints `$LINENO` and `$BASH_COMMAND`, with `set -E`.
10. **Why are traces sent to stderr?** So they do not mix with the script's normal output on stdout.

### 14. Practical Exercises

1. Create a script with a missing `fi`; use `bash -n` to find the problem, then fix it.
2. Trace `trace-demo.sh` with `bash -x` and explain each traced line, including the quotes.
3. Add a custom `PS4` and trace only a function using `set -x` / `set +x`.
4. Create a script that uses an unset variable with and without `set -u`; compare behaviour.
5. Write a script with an `ERR` trap that prints the failing line and command, and trigger it with a missing file.
6. Run a script with `bash -x script.sh 2> trace.log`, secure the file with `chmod 600`, review it for sensitive values and delete it.

### 15. Key Takeaways

- `bash -n` checks syntax without running; `bash -x` and `set -x` / `set +x` trace execution.
- Use a custom `PS4` for file, line and function context.
- Combine strict mode and an `ERR` trap to expose failures early.
- Follow a method: reproduce, check syntax, check basics, trace, inspect values, isolate, fix.
- Traces go to stderr and can leak secrets, so turn tracing off around sensitive commands.
- Debug safely: copy scripts, avoid unnecessary `sudo`, and never leave insecure workarounds behind.

---
