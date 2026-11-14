# 11 — Bash Script Debugging Fundamentals

[← Previous: Executable Permissions](10-executable-permissions.md) | [Module index](README.md)

## 1. Overview

Every script fails eventually. Debugging is the disciplined process of finding out *why*, quickly and without making things worse. Bash gives you built-in tools: a syntax checker (`bash -n`), an execution tracer (`bash -x`, `set -x`), verbose mode (`set -v`), strict-mode options and traps. Used well, they turn "it doesn't work" into a precise line number and a concrete cause.

## 2. Definition

**Debugging** is the systematic identification and correction of defects. In Bash this means:

- **Static checking:** parsing a script for syntax errors without running it (`bash -n`).
- **Tracing:** printing each command, after expansion, as it executes (`-x` / `xtrace`).
- **Verbose mode:** printing each line as it is read, before expansion (`-v` / `verbose`).
- **Defensive options and traps:** making failures visible early (`set -Eeuo pipefail`, `trap handler ERR`).

## 3. Detailed Explanation

### The main tools

| Tool | Command | What it does | Runs the script? |
|------|---------|--------------|------------------|
| Syntax check | `bash -n script.sh` | Reads and parses; reports syntax errors | **No** |
| Trace | `bash -x script.sh` | Prints each command after expansion, prefixed with `+` | Yes |
| Trace a region | `set -x` and `set +x` | Turns tracing on and off inside the script | Yes |
| Verbose | `bash -v script.sh` / `set -v` | Prints each input line before execution | Yes |
| Combined | `bash -nv script.sh` | Syntax check with echoed lines | No |
| Strict mode | `set -Eeuo pipefail` | Fails on errors, unset variables and pipeline failures | Yes |
| Error trap | `trap 'echo "line $LINENO"' ERR` | Reports where a failing command occurred | Yes |

### What `bash -n` can and cannot do

`bash -n` finds problems such as an unterminated `if` (missing `fi`), unbalanced quotes or a stray parenthesis. It **cannot** find runtime problems: misspelled command names, missing files, wrong variable values, logic errors or permission issues.

### Understanding the trace

Each traced line begins with the value of `PS4` (default `+ `). Repeated characters show nesting depth, for example `++` for a command inside a command substitution or function call. Variable values appear **after** expansion, so you see exactly what Bash will run. Trace output goes to standard error.

### Making traces informative with `PS4`

```bash
export PS4='+ ${BASH_SOURCE##*/}:${LINENO}: ${FUNCNAME[0]:-main}: '
```

This prints the file, line number and function for every traced command. Tracing uses the **first character** of `PS4` repeated to show nesting depth.

### Useful special variables

| Variable | Meaning |
|----------|---------|
| `LINENO` | Current line number |
| `BASH_SOURCE` | Array of source file names for the call stack |
| `FUNCNAME` | Array of function names in the call stack |
| `BASH_COMMAND` | The command currently executing (useful inside traps) |
| `PIPESTATUS` | Array of exit statuses of the last pipeline |
| `$?` | Exit status of the last command |

### Redirecting the trace

```bash
bash -x script.sh 2> trace.log                 # trace plus other stderr to a file
exec 9> trace-fd.log; BASH_XTRACEFD=9; set -x  # dedicated trace file descriptor
```

### A repeatable debugging method

1. **Reproduce** the problem and record the exact command and exit status.
2. **Check syntax:** `bash -n script.sh`.
3. **Check the basics:** shebang, line endings (`file`), permissions, `PATH`, working directory.
4. **Trace:** `bash -x script.sh`, then focus on the failing area with `set -x` / `set +x`.
5. **Inspect values:** print variables with `declare -p var` or `printf '%q\n' "$var"` to expose spaces and special characters.
6. **Isolate:** reduce the script to the smallest failing case.
7. **Fix, rerun, and keep the test:** confirm the fix and record how to prevent recurrence.

## 4. How It Works

- `bash -n` makes Bash read and parse the whole script without executing commands.
- With `-x`, Bash sets the `xtrace` option. Before executing each simple command, it expands the words, then writes `PS4` plus the expanded command to standard error, and only then runs it.
- `set -x` and `set +x` toggle the same option at runtime; the trace includes the `set +x` command itself when turning tracing off.
- `trap handler ERR` registers a handler that runs when a command fails under the same conditions in which `set -e` would trigger; `set -E` (`errtrace`) extends ERR-trap inheritance to functions, command substitutions and subshell environments.
- `-u` makes the expansion of an unset variable a fatal error, converting silent empty strings into a clear message with the line number.

## 5. Why It Matters in DevOps

- Production automation fails at inconvenient times; fast diagnosis reduces downtime.
- CI/CD logs often show only the last error line; traces and clear exit statuses reveal the cause.
- Syntax checking in a pipeline step catches broken scripts before they reach a server.
- Disciplined debugging avoids risky "try random fixes on production" behaviour.
- Trace logs are valuable for post-incident reviews, but they must be handled carefully because they can expose secrets.

## 6. Syntax and Commands

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

## 7. Command-by-Command Explanation

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

## 8. Practical Examples

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

## 9. Expected Output

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

## 10. Common Mistakes

- Assuming `bash -n` proves a script works; it checks syntax only.
- Leaving `set -x` enabled around secrets, so tokens and passwords appear in logs.
- Debugging by editing production scripts directly instead of copying and testing safely.
- Ignoring the **first** error message; later errors are often consequences.
- Forgetting to quote variables, then misreading the trace because spaces split words.
- Reading `set -e` as a guarantee; failures in conditions or `||` lists do not abort.
- Using `echo` to inspect values when `declare -p` or `printf '%q'` would expose hidden characters.
- Forgetting that trace output goes to **stderr**, so `> file` does not capture it.
- Testing with a different user, directory or environment than the failing run (cron, CI).

## 11. Troubleshooting

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

## 12. Security Best Practices

- **Treat trace output as sensitive.** `xtrace` prints expanded values, which can include passwords, API keys and tokens. Turn it off (`set +x`) around any command that handles secrets, and never ship trace logs to shared locations without reviewing them.
- Do not paste traces or logs into public tickets, chats or repositories before removing credentials.
- Restrict trace and debug files to the owner (`chmod 600 trace.log`) and delete them when finished.
- Debug on a copy of the script and, where possible, a non-production system.
- Do not run unknown scripts "to see what happens"; read them and use `bash -n` first.
- Avoid `sudo` while debugging unless the failure itself concerns privileged access, and keep the privileged section minimal.
- Do not add temporary insecure workarounds (`chmod 777`, disabling checks) and forget to remove them.
- Prefer secrets from protected files or secret managers over command-line arguments, which appear in process listings and traces.

## 13. Interview Questions

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

## 14. Practical Exercises

1. Create a script with a missing `fi`; use `bash -n` to find the problem, then fix it.
2. Trace `trace-demo.sh` with `bash -x` and explain each traced line, including the quotes.
3. Add a custom `PS4` and trace only a function using `set -x` / `set +x`.
4. Create a script that uses an unset variable with and without `set -u`; compare behaviour.
5. Write a script with an `ERR` trap that prints the failing line and command, and trigger it with a missing file.
6. Run a script with `bash -x script.sh 2> trace.log`, secure the file with `chmod 600`, review it for sensitive values and delete it.

## 15. Key Takeaways

- `bash -n` checks syntax without running; `bash -x` and `set -x` / `set +x` trace execution.
- Use a custom `PS4` for file, line and function context.
- Combine strict mode and an `ERR` trap to expose failures early.
- Follow a method: reproduce, check syntax, check basics, trace, inspect values, isolate, fix.
- Traces go to stderr and can leak secrets, so turn tracing off around sensitive commands.
- Debug safely: copy scripts, avoid unnecessary `sudo`, and never leave insecure workarounds behind.

---

[← Previous: Executable Permissions](10-executable-permissions.md) | [Module index](README.md)
