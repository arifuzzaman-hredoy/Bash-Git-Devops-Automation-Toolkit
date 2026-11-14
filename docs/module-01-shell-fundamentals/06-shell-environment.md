# 06 — Shell Environment

[← Previous: Linux Command Execution](05-linux-command-execution.md) | [Module index](README.md) | [Next: Bash Script Structure →](07-bash-script-structure.md)

## 1. Overview

Every process on Linux runs with an *environment*: a set of name/value pairs inherited from its parent. The shell builds this environment at startup by reading configuration files, and passes it on to every program it launches. Understanding variables, `export`, inheritance and startup files explains why a script sees different values in SSH, cron, `sudo`, CI and containers.

## 2. Definition

- **Shell variable:** a name/value pair that exists only inside the current shell process.
- **Environment variable:** a variable that has been **exported**, so it is copied into the environment of child processes.
- **Shell environment:** the combined set of variables, options, aliases, functions, working directory and settings in which a shell and its children run.
- **Startup files:** scripts the shell reads automatically when it starts, to build that environment.

## 3. Detailed Explanation

### Shell variables vs environment variables

```bash
GREETING="hello"          # shell variable: visible only in this shell
export GREETING           # now also an environment variable
export NAME="Ops"         # create and export in one step
```

Child processes receive a **copy** of the exported variables. A child can change its own copy, but it can never change the parent's. This is why running a script cannot set variables in your interactive shell (unless the script is *sourced*, Topic 9).

### Important standard variables

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

### Shell types and startup files

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

### Inspecting environment and shell state

`env` and `printenv` list exported variables. `set` (with no arguments) lists *all* variables and functions. `declare -p NAME` shows a variable with its attributes. `echo $-` shows option flags: the letter `i` means interactive.

### Per-command and temporary variables

```bash
LC_ALL=C sort file.txt      # variable set only for this one command
```

### Sourcing

`source file` (or `. file`) runs the file's commands **in the current shell**, so variables, functions and `cd` persist. Executing a script (`./file`) runs it in a **child** process, so they do not.

## 4. How It Works

1. A login (or other) shell starts and determines its type.
2. It reads the startup files for that type, which set variables, aliases, functions and `PATH`.
3. Variables marked with `export` are placed in the shell's environment table.
4. When a command runs, `fork()` copies the shell, and `execve()` passes the environment array to the new program. The program reads it with `getenv()` or similar.
5. Changes the child makes affect only the child's copy and disappear when it exits.

Other tools build their own environment: `sudo` resets most variables by default, `cron` provides a minimal environment, `systemd` units use `Environment=` and `EnvironmentFile=`, and CI systems inject their own variables.

## 5. Why It Matters in DevOps

- "Works in SSH, fails in cron" is almost always an environment difference (`PATH`, missing variables, no aliases).
- CI/CD and deployment tools pass configuration through environment variables (`AWS_REGION`, `ENVIRONMENT`, `DATABASE_URL`).
- Twelve-factor application configuration relies on environment variables.
- Misplaced startup-file content breaks `scp`, `rsync`, Ansible and other non-interactive tools.
- A polluted or overly long `PATH` can run the wrong binary or slow down lookups.
- Secrets in environment variables can leak through process inspection, crash dumps and verbose logging.

## 6. Syntax and Commands

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

## 7. Command-by-Command Explanation

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

## 8. Practical Examples

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

## 9. Expected Output

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

## 10. Common Mistakes

- Putting spaces around `=` (`VAR = value` runs a command called `VAR`).
- Expecting a script to modify variables of the calling shell.
- Forgetting `export` and wondering why a child program cannot see the variable.
- Putting `echo` or other output in `~/.bashrc` unguarded, which breaks `scp` and `rsync`.
- Writing `PATH=$PATH:$HOME/bin` repeatedly so `PATH` grows with every nested shell.
- Writing shell syntax into `/etc/environment`.
- Assuming cron has your interactive `PATH` and aliases.
- Putting secrets into a startup file that is world-readable.

## 11. Troubleshooting

| Symptom | Likely cause | Safe next step |
|---------|--------------|----------------|
| Alias missing after SSH login | `~/.profile` not sourcing `~/.bashrc`, or `~/.bash_profile` shadows it | `ls -la ~`; check which login file exists |
| Variable empty in a script | Not exported, or set in an unread file | `declare -p VAR`; `export VAR` before the call |
| `PATH` contains duplicates | Startup file appends on every start | Use the `case` guard shown above |
| `scp`/`rsync` fails with "protocol error" | Output printed in startup files | Guard output with `[[ $- == *i* ]]` or move to interactive-only code |
| Cron job cannot find a command | Minimal cron `PATH` | Use absolute paths or set `PATH` in the script |
| Different values under `sudo` | `sudo` resets the environment | Do not widen `sudo` permissions; pass only needed values explicitly with a reviewed approach |
| Changes in `~/.bashrc` have no effect | Not reloaded | Start a new shell, or run `source ~/.bashrc` |

## 12. Security Best Practices

- Do **not** store secrets in startup files, exported variables or scripts in the repository. Use a secrets manager (for example AWS Secrets Manager or SSM Parameter Store), or a file readable only by the owner (`chmod 600`).
- Export a secret only for the single command that needs it (`TOKEN=value command`) when a variable is unavoidable, and avoid passing secrets as command-line arguments, which are visible in process listings.
- Remember that the environment of a process can be read by the same user and by root through `/proc/<pid>/environ`.
- Never commit `.env` files containing real values to Git; add them to `.gitignore`.
- Keep startup files owned by the user and not group- or world-writable (for example `644` or stricter).
- Avoid `.`, empty entries and writable directories in `PATH`.
- Never run `printenv`, `env` or `set` in shared logs or CI output without checking for secrets.
- Review the contents of `/etc/profile.d/` and your dotfiles when investigating suspicious behaviour.

## 13. Interview Questions

1. **What is the difference between a shell variable and an environment variable?** Environment variables are exported and inherited by child processes; shell variables are not.
2. **Can a child process change its parent's variables?** No; it modifies only its own copy.
3. **What is a login shell?** The shell started at login (or with `-l`), which reads `/etc/profile` and the user's login file.
4. **Which files does an interactive non-login Bash read?** `/etc/bash.bashrc` (on Debian/Ubuntu) and `~/.bashrc`.
5. **Does a non-interactive shell read `~/.bashrc`?** Not normally; only if `BASH_ENV` points to a file (with the special case of Bash started by `sshd`).
6. **What does `source` do differently from executing a script?** It runs in the current shell, so changes persist.
7. **Why is `/etc/environment` different from `/etc/profile`?** It is parsed by PAM as `KEY=value` pairs, not executed as shell code.
8. **How do you give a variable to one command only?** Prefix it: `VAR=value command`.
9. **Why are secrets in environment variables risky?** They can leak via `/proc`, logs, crash dumps and child processes.

## 14. Practical Exercises

1. Prove inheritance: set a variable, run `bash -c` with and without `export`, and record the results.
2. Determine whether your SSH shell is login and interactive using `shopt` and `$-`.
3. Identify which of `~/.bash_profile`, `~/.bash_login` and `~/.profile` exist on your server.
4. Create `~/practice/module-01/envdemo.sh` that prints `DEMO` and run it before and after `export DEMO`.
5. Source (not execute) a file that sets a variable and shows it persists, then compare with executing it.
6. Print `PATH` one directory per line and decide whether each entry is needed and safe.

## 15. Key Takeaways

- Environment variables are exported variables inherited by child processes as copies.
- A child can never change its parent's environment.
- Startup files depend on login vs non-login and interactive vs non-interactive status.
- Keep startup files quiet for non-interactive use and keep `PATH` clean.
- Cron, `sudo`, CI and containers each build different environments; be explicit in scripts.
- Do not store or print secrets carelessly.

---

[← Previous: Linux Command Execution](05-linux-command-execution.md) | [Module index](README.md) | [Next: Bash Script Structure →](07-bash-script-structure.md)
