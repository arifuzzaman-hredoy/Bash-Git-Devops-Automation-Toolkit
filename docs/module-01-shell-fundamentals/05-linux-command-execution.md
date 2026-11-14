# 05 — Linux Command Execution

[← Previous: Bash vs Other Shells](04-bash-vs-other-shells.md) | [Module index](README.md) | [Next: Shell Environment →](06-shell-environment.md)

## 1. Overview

Typing `ls -l` looks simple, but the shell performs many steps: parsing, expansion, command lookup, process creation and status reporting. Understanding this pipeline is the key to diagnosing `command not found`, `Permission denied`, surprising globbing, wrong program versions and many pipeline failures.

## 2. Definition

**Command execution** is the process by which the shell turns a line of text into running work: it parses the line, performs expansions, determines what kind of command each word names, and either runs it internally (keywords, functions, builtins) or starts an external program as a new process.

## 3. Detailed Explanation

### Types of commands

| Type | Description | Example | Runs in |
|------|-------------|---------|---------|
| Alias | Text substitution defined in the shell | `ll` → `ls -alF` | Shell (interactive only by default) |
| Keyword | Reserved word that is part of the language | `if`, `for`, `while`, `[[` | Shell |
| Function | Named block of shell code | `deploy() { commands; }` | Shell |
| Builtin | Command implemented inside Bash | `cd`, `echo`, `type`, `export` | Shell |
| External command | Executable file found on disk | `/usr/bin/ls`, `/usr/bin/git` | New child process |

### Lookup order

For a simple command name that contains no slash, Bash resolves it in this order:

1. Aliases (when alias expansion is enabled, which is the default for interactive shells).
2. Keywords are recognised by the parser as part of the grammar.
3. Shell functions.
4. Builtins.
5. External commands: the shell checks its **hash table** of remembered locations, then searches each directory in `$PATH` from left to right and uses the first executable match.

If the command name contains a slash (`./script.sh`, `/usr/bin/ls`) **no search is performed**; that exact path is used.

### The `PATH` variable

`PATH` is a colon-separated list of directories. The first match wins, so directory order has security and correctness implications. An empty entry or `.` in `PATH` means the current directory is searched, which is unsafe.

### Expansion order

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

### Exit status

Every command returns an integer 0–255, stored in `$?`.

| Status | Meaning |
|--------|---------|
| `0` | Success |
| `1`–`125` | Command-specific failure |
| `126` | Command found but not executable |
| `127` | Command not found |
| `128+N` | Terminated by signal N (for example `130` = `Ctrl+C`, `SIGINT`) |

### Command lists and pipelines

- `cmd1 ; cmd2` — run sequentially.
- `cmd1 && cmd2` — run `cmd2` only if `cmd1` succeeded.
- `cmd1 || cmd2` — run `cmd2` only if `cmd1` failed.
- `cmd1 | cmd2` — connect stdout of `cmd1` to stdin of `cmd2`; both run concurrently.
- `cmd &` — run in the background.

By default a pipeline's status is that of the **last** command; `set -o pipefail` makes it fail if any stage fails. `PIPESTATUS` holds each stage's status.

## 4. How It Works

For an external command such as `ls -l /var/log`:

1. Bash parses the line into the command `ls` with arguments `-l` and `/var/log`.
2. It resolves `ls` (alias? function? builtin? hash table? `PATH` search).
3. Bash calls `fork()`, creating a child process that is a copy of the shell.
4. In the child, Bash sets up redirections, then calls `execve("/usr/bin/ls", ["ls","-l","/var/log"], environment)`. The kernel loads the program in place of the child's code. If the file starts with `#!`, the kernel starts the interpreter instead (Topic 8).
5. The parent shell calls `wait()` (for foreground jobs) until the child exits.
6. The kernel reports the exit status, Bash stores it in `$?` and shows the next prompt.

Builtins and functions skip steps 3–4 because they run inside the current shell process.

## 5. Why It Matters in DevOps

- Explains why a pipeline step fails with `127` (missing tool or `PATH` issue) or `126` (permission problem).
- Explains "wrong version" bugs: an older binary earlier in `PATH` shadows the intended one.
- Alias definitions in `~/.bashrc` do not exist in scripts or cron jobs, which is a common cause of "works interactively only" failures.
- Understanding expansion and quoting prevents destructive bugs such as `rm -rf $dir/*` with an empty variable.
- Pipeline and exit-status knowledge is essential for reliable automation (`set -o pipefail`, `&&`, `||`).

## 6. Syntax and Commands

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

## 7. Command-by-Command Explanation

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

## 8. Practical Examples

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

## 9. Expected Output

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

## 10. Common Mistakes

- Running `script.sh` instead of `./script.sh`, or adding `.` to `PATH` to avoid typing `./`.
- Forgetting that `$?` changes after every command.
- Using `which` to understand shell behaviour; it ignores builtins, aliases and functions.
- Leaving variables unquoted: `rm -rf $dir/*` with `dir` empty becomes `rm -rf /*`.
- Assuming a pipeline fails if the first command fails (it does not unless `pipefail` is set).
- Expecting `cd` in a script to change the directory of the *calling* shell.
- Relying on aliases in scripts.
- Forgetting `hash -r` after installing a tool into an earlier `PATH` directory.

## 11. Troubleshooting

| Symptom | Likely cause | Safe next step |
|---------|--------------|----------------|
| `command not found` (127) | Not installed, typo, or not in `PATH` | `type name`; `echo "$PATH"`; check spelling |
| `Permission denied` (126) | File not executable, or directory not searchable | `ls -l file`; fix with `chmod u+x` only if the file is trusted |
| Old version of a tool runs | Earlier `PATH` entry or stale hash | `type -a tool`; `hash -r` |
| Command works interactively, fails in cron | `PATH` and aliases differ | Use absolute paths; set `PATH` in the script |
| `No such file or directory` for an existing script | Wrong shebang path or CRLF endings | `head -n 1 script \| cat -A` |
| Glob matches nothing and prints literally | No matching files, `nullglob` off | `ls` the directory; use `shopt -s nullglob` when intended |
| Unexpected splitting of file names | Unquoted variable | Quote it: `"$var"` |

## 12. Security Best Practices

- Never put `.` or an empty element in `PATH`; an attacker-writable directory earlier in `PATH` enables command hijacking.
- In privileged scripts set a known-safe `PATH` explicitly or call programs by absolute path.
- Quote all expansions, and use `--` to end options when handling untrusted file names (`rm -- "$file"`).
- Do not use `eval` or `bash -c "$untrusted"`.
- Do not use `sudo` unless a command truly needs elevated rights, and never `sudo` a script you have not read.
- Treat command substitution of untrusted data with care; validate before use.
- Check that files in `PATH` directories are owned by root and not world-writable.

## 13. Interview Questions

1. **What happens between pressing Enter and a program running?** Parse, expand, resolve, `fork`, `execve`, `wait`, store the exit status.
2. **What is the command lookup order?** Alias, function, builtin, then `PATH`/hash table for external commands (keywords are handled by the parser).
3. **Difference between a builtin and an external command?** Builtins run inside the shell; external commands run in a child process.
4. **What do exit statuses 126 and 127 mean?** Not executable and not found respectively.
5. **Why is `command -v` preferred over `which`?** It understands aliases, functions and builtins and is standardised.
6. **What does `set -o pipefail` do?** Makes a pipeline return the status of the rightmost failing command.
7. **Why can unquoted variables be dangerous?** They undergo word splitting and globbing, which can change the meaning of commands.
8. **Why is `.` in `PATH` unsafe?** A malicious file in the current directory could run in place of a legitimate command.

## 14. Practical Exercises

1. Use `type -a` on `ls`, `echo`, `printf` and `test`. Which have both builtin and file versions?
2. Print `PATH` one directory per line and note the order.
3. Create a function `hello() { echo "hi"; }`, run `type hello`, then `unset -f hello`.
4. Trigger exit status 127 and 126 deliberately, and show both with `echo $?`.
5. Run `false | true` with and without `pipefail` and compare.
6. Create a file called `a b.txt` and show why `rm $f` fails but `rm -- "$f"` works (remove only the file you created).

## 15. Key Takeaways

- Commands are aliases, keywords, functions, builtins or external programs.
- Lookup order and `PATH` order decide which program runs.
- External commands run via `fork` and `execve`; builtins run in the shell.
- Expansion happens before execution; quoting controls it.
- Exit statuses (`0`, `126`, `127`, `128+N`) drive automation decisions.
- Keep `PATH` clean and quote everything.

---

[← Previous: Bash vs Other Shells](04-bash-vs-other-shells.md) | [Module index](README.md) | [Next: Shell Environment →](06-shell-environment.md)
