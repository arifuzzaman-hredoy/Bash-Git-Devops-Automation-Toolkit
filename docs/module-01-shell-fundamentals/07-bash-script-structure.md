# 07 — Bash Script Structure

[← Previous: Shell Environment](06-shell-environment.md) | [Module index](README.md) | [Next: Shebang →](08-shebang.md)

## 1. Overview

A Bash script is a text file of commands. A *good* script is predictable: it declares its interpreter, fails safely, keeps its logic in functions, cleans up after itself and reports meaningful exit codes. A consistent skeleton makes scripts easier to read, review, test and maintain, which matters when the same pattern is repeated across an entire automation toolkit.

## 2. Definition

**Script structure** is the conventional ordering of elements in a Bash script: shebang, header comments, safety options, constants, helper functions, the main logic, and the entry-point call.

## 3. Detailed Explanation

### Recommended layout

1. **Shebang** — first line, selects the interpreter (Topic 8).
2. **Header comment** — purpose, usage, requirements, exit codes.
3. **Safety settings** — `set -Eeuo pipefail` and, optionally, `IFS` and `umask`.
4. **Constants and configuration** — `readonly` values, defaults, overridable settings.
5. **Helper functions** — logging, usage, validation, cleanup.
6. **Traps** — cleanup on `EXIT`, diagnostics on `ERR`.
7. **Main logic** — a `main()` function that orchestrates work.
8. **Entry point** — `main "$@"`.

### The strict-mode options

| Option | Effect | Caveat |
|--------|--------|--------|
| `set -e` (`errexit`) | Exit when a simple command fails | Not triggered inside `if`/`while` conditions, `&&`/`||` lists, or negated commands, so it is a safety net, not a substitute for checking results |
| `set -u` (`nounset`) | Treat expansion of unset variables as an error | Use `${var:-default}` when a variable may legitimately be unset |
| `set -o pipefail` | Pipeline fails if any stage fails | A stage that exits non-zero by design (for example `grep` with no match) can now fail the script |
| `set -E` (`errtrace`) | `ERR` traps are inherited by functions and subshells | Needed for a useful `ERR` trap |

### Other recommended practices

- Quote all variable expansions: `"$var"`, `"${array[@]}"`.
- Use `local` for variables inside functions and `readonly` for constants.
- Use `[[ ]]` for tests and `$(command)` for command substitution (not backticks).
- Use `printf` rather than `echo` when output must be exact.
- Send errors to standard error (`>&2`).
- Return meaningful exit codes: `0` for success, non-zero for failure.
- Avoid parsing `ls`; use globs or `find -print0` with `read -d ''` instead.
- Use `mktemp` for temporary files and remove them in an `EXIT` trap.
- Use a "main guard" if a file may be both sourced and executed.

### Main guard (optional)

```bash
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

## 4. How It Works

1. The kernel reads the shebang and starts Bash with the script path as its argument.
2. Bash reads the file and executes commands in order, one complete command at a time.
3. Functions are only *defined* when Bash reaches them; they must be defined **before** the call that uses them executes. That is why the layout places `main "$@"` at the very bottom.
4. `set` options take effect immediately for every following command.
5. Traps register handlers that run when the shell exits or when a command fails.
6. When the script ends, Bash returns the status of the last command or the argument of `exit`.

## 5. Why It Matters in DevOps

- Production scripts run unattended, so they must fail loudly and early rather than continuing in a bad state.
- A uniform skeleton makes code review and onboarding faster across a toolkit.
- Cleanup traps prevent leftover temp files, locks and partial outputs after failures.
- Correct exit codes let CI/CD pipelines, cron monitoring and orchestration tools react properly.
- Functions and `main` make scripts testable and reusable.
- Logging to stderr/stdout in a consistent format makes troubleshooting simpler.

## 6. Syntax and Commands

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

## 7. Command-by-Command Explanation

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

## 8. Practical Examples

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

## 9. Expected Output

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

## 10. Common Mistakes

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

## 11. Troubleshooting

| Symptom | Likely cause | Safe next step |
|---------|--------------|----------------|
| `unbound variable` | `set -u` with an unset variable | Initialise it or use `${var:-}` |
| Script exits silently mid-way | `set -e` triggered by a command returning non-zero | Run `bash -x script.sh` and look at the last traced command |
| `command not found` for a function | Function defined after its call | Move definitions above `main "$@"` |
| `syntax error: unexpected end of file` | Missing `fi`, `done`, `esac` or `}` | `bash -n script.sh` |
| Pipeline unexpectedly fails | `pipefail` plus `grep` finding nothing | Handle explicitly: `grep PATTERN \|\| true` where no-match is acceptable |
| ERR trap not firing in functions | Missing `-E` | Use `set -E` |
| Leftover temp files | No `EXIT` trap | Add a `cleanup` trap |

## 12. Security Best Practices

- Never hardcode passwords, tokens or keys; read them from a protected source at runtime.
- Validate every input (arguments, environment, files) before use, as `disk-check.sh` does with its threshold.
- Quote expansions and use `--` before user-supplied file names.
- Use `mktemp` for temporary files; never predictable names in shared directories.
- Set a restrictive `umask` (for example `umask 077`) when a script creates sensitive files.
- Avoid `eval`; avoid running with `sudo` unless needed, and then limit the privileged part.
- Set an explicit `PATH` in privileged scripts.
- Do not echo secrets into logs; avoid `set -x` around sensitive operations.
- Keep scripts in version control and review changes before they run in production.

## 13. Interview Questions

1. **What belongs at the top of every Bash script?** A shebang, then a header comment and safety options.
2. **What does `set -Eeuo pipefail` do?** Enables errtrace, errexit, nounset and pipefail.
3. **Name situations where `set -e` does not stop the script.** Conditions in `if`/`while`, commands in `&&`/`||` lists, negated commands, and some subshell/function contexts.
4. **Why use `main "$@"` at the bottom?** All functions are defined before execution begins, and arguments are passed through intact.
5. **What is the difference between `exit` and `return`?** `exit` ends the shell/script; `return` leaves a function.
6. **Why use `local`?** To avoid leaking variables into the global scope.
7. **Why use `trap handler EXIT`?** To guarantee cleanup even when the script fails or is interrupted.
8. **Why prefer `$(command)` to backticks?** It nests cleanly and is easier to read.
9. **Why should you not parse `ls`?** File names with spaces or newlines break it; use globs or `find`.

## 14. Practical Exercises

1. Create `disk-check.sh` from Example 1, run it three times (default, low threshold, invalid argument) and record the exit codes.
2. Add a `-h` option that prints usage and exits `0`.
3. Add a second check for `/var` and report both.
4. Remove the `EXIT` trap, create a temp directory and observe what is left behind after an error; then restore the trap.
5. Run the script with `bash -n` and `bash -x` and describe the difference.
6. Rewrite a script of your own so every variable is quoted and every function uses `local`.

## 15. Key Takeaways

- Use a consistent skeleton: shebang, header, safety options, constants, functions, traps, `main`, entry point.
- `set -Eeuo pipefail` helps but is not a complete safety net.
- Quote everything, use `local`, `readonly` and `[[ ]]`.
- Clean up with traps and create temporary files with `mktemp`.
- Return meaningful exit codes and write errors to stderr.
- Never hardcode secrets and always validate input.

---

[← Previous: Shell Environment](06-shell-environment.md) | [Module index](README.md) | [Next: Shebang →](08-shebang.md)
