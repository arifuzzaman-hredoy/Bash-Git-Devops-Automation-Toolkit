# 02 — What is Bash?

[← Previous: What is a Shell?](01-what-is-a-shell.md) | [Module index](README.md) | [Next: Shell vs Terminal →](03-shell-vs-terminal.md)

## 1. Overview

Bash is the default interactive shell on Ubuntu and the most widely used shell for Linux automation. It is both the program you type commands into over SSH and the interpreter that runs most of the scripts in this toolkit. Ubuntu 24.04 LTS ships Bash 5.2.x.

## 2. Definition

**Bash** stands for **Bourne-Again SHell**. It is the GNU Project's shell, written as a free replacement and extension of the original Bourne shell (`sh`). It supports many features defined by the POSIX shell standard and adds many extensions, often called *bashisms*. Bash is not limited to POSIX syntax.

## 3. Detailed Explanation

### Origin

Brian Fox wrote Bash for the GNU Project, with its first release in 1989. It has been maintained for many years by Chet Ramey. The name is a pun on the Bourne shell written by Stephen Bourne.

### Key features

- **Command-line editing and history** — arrow keys, `Ctrl+R` reverse search, the `history` builtin.
- **Tab completion** — for commands, file names and, with the `bash-completion` package, command options.
- **Variables, arrays and associative arrays** — indexed arrays and `declare -A` maps (Bash 4+).
- **Extended tests** — `[[ expression ]]` with pattern matching and regular expressions.
- **Expansions** — brace expansion (`{a,b}`), parameter expansion (`${var:-default}`), arithmetic expansion (`$(( ))`) and process substitution (`<( )`).
- **Functions, loops, conditionals and `case`** — a complete scripting language.
- **Job control** — `&`, `jobs`, `fg`, `bg`.
- **Here-documents and here-strings** — `<<EOF` and `<<<`.
- **Shell options** — `set -o` and `shopt` switches to change behaviour.

### Bash and POSIX

POSIX defines a portable shell language. Bash implements it and extends it. Scripts that use only portable POSIX shell features can generally run on `dash`, `ash` and other POSIX-oriented shells. Scripts that use Bash-specific features must be run by Bash. Bash can follow POSIX-oriented behaviour more closely with `set -o posix` or when invoked as `sh`, although this does not turn every Bash script into a portable POSIX script.

### Bash on Ubuntu

- `/bin/bash` (a symlink to `/usr/bin/bash` on current Ubuntu) is normally the default login shell for the `ubuntu` user on a standard Ubuntu EC2 image. Check the configured login shell with `getent passwd ubuntu`.
- `/bin/sh` is **not** Bash; on Ubuntu it points to `dash` (Topic 4).
- Bash reads `~/.bashrc` for interactive non-login shells, and Ubuntu's default `~/.profile` sources it for login shells.

### Version information

Bash exposes its version in `BASH_VERSION` and the array `BASH_VERSINFO`. Ubuntu backports security fixes without always changing the upstream version number, so use the distribution package version for patch tracking rather than the number alone.

## 4. How It Works

1. Bash starts, determines whether it is interactive and/or a login shell, and reads the appropriate startup files.
2. It sets up its internal state: variables, options (`$-`), aliases, functions and the command hash table.
3. For each command line it performs the read–parse–expand–execute cycle described in Topics 1 and 5.
4. For scripts it reads the file (or `-c` string) one complete command at a time and executes it, so a syntax error late in a file may only appear after earlier commands have already run. This is why `bash -n` is valuable (Topic 11).
5. On exit it returns the exit status of the last command (or the value given to `exit`) to its parent.

## 5. Why It Matters in DevOps

- Bash is available on virtually every Linux server, cloud image and CI runner, so scripts need no extra runtime.
- It excels at gluing tools together: `aws`, `git`, `curl`, `systemctl`, `docker`, `kubectl`.
- Its features (arrays, `[[ ]]`, parameter expansion, `trap`) make scripts shorter and safer than strict POSIX `sh` equivalents.
- It is the language of cron jobs, EC2 user-data scripts, Dockerfile `RUN` lines and many pipeline steps.
- Knowing Bash precisely lets you decide when to stay portable and when a different tool (Python, for example) is the better choice.

## 6. Syntax and Commands

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

## 7. Command-by-Command Explanation

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

## 8. Practical Examples

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

## 9. Expected Output

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

## 10. Common Mistakes

- Writing Bash-specific syntax (`[[ ]]`, arrays) in a script run with `sh`.
- Forgetting quotes around `"${array[@]}"`, which breaks elements containing spaces.
- Assuming associative arrays work in very old Bash (macOS ships Bash 3.2 by default).
- Using `==` inside single brackets `[ ]` and expecting pattern matching; use `[[ ]]` for patterns.
- Trying to use `man cd`; builtins are documented with `help cd` and in `man bash`.
- Assuming `/bin/sh` is Bash on Ubuntu.

## 11. Troubleshooting

| Symptom | Likely cause | Safe next step |
|---------|--------------|----------------|
| `declare: -A: invalid option` | Running a very old Bash | `bash --version`; run with a newer Bash |
| `[[: not found` | Script executed by `sh`/`dash` | Run with `bash script.sh` or fix the shebang |
| `syntax error near unexpected token` | Unbalanced quotes, missing `fi`/`done`, CRLF line endings | `bash -n script.sh`; `file script.sh` |
| `bad substitution` | Bash-only parameter expansion run under `sh` | Confirm the interpreter with `ps -p $$ -o comm=` inside the script |
| Different behaviour in cron | Different environment and `PATH` | Use absolute paths; set `PATH` explicitly (Topic 6) |

## 12. Security Best Practices

- Quote every variable expansion (`"$var"`) to avoid word splitting and glob expansion on untrusted data.
- Never use `eval` on user-supplied or external input.
- Prefer `[[ ]]` over `[ ]` for tests on variables, and validate input before use.
- Keep Ubuntu packages updated through the normal, approved update process so Bash receives security fixes.
- Do not hardcode secrets in scripts; load them from protected files or a secrets manager.
- Avoid running scripts as root unless the specific task requires it.

## 13. Interview Questions

1. **What does Bash stand for?** Bourne-Again SHell.
2. **Is Bash the same as `sh`?** No. `sh` is the POSIX shell interface. On Ubuntu `/bin/sh` is `dash`; Bash is a separate, richer shell.
3. **Name three Bash features that are not in POSIX `sh`.** Arrays, `[[ ]]`, process substitution, brace expansion, `${var,,}` case conversion.
4. **How do you check the Bash version inside a script?** Use `BASH_VERSION` or `BASH_VERSINFO`.
5. **What is a builtin and how do you read its documentation?** A command implemented inside the shell; use `help <name>`.
6. **Why use `[[ ]]` instead of `[ ]`?** It does not perform word splitting or pathname expansion on its expressions and supports pattern matching with `==` and regular-expression matching with `=~`.
7. **How can Bash be made to follow POSIX behaviour?** `set -o posix`, `bash --posix`, or being invoked as `sh`.

## 14. Practical Exercises

1. Record your Bash version using both `BASH_VERSION` and `BASH_VERSINFO`.
2. Create an array of three directory names and loop over it, printing each.
3. Create an associative array mapping service names to ports and print one value.
4. Use `[[ =~ ]]` to extract the year from `report-2025-03-01.csv`.
5. Run `compgen -b | wc -l` and `help type`. Explain what `type` is documented as.

## 15. Key Takeaways

- Bash is the GNU "Bourne-Again SHell", the default Ubuntu interactive shell.
- It is mostly POSIX-compatible and adds arrays, `[[ ]]`, process substitution and more.
- `/bin/sh` is a different shell (`dash`) on Ubuntu.
- Use `help` for builtins and `man bash` for the full reference.
- Quote variables and avoid `eval` to keep scripts safe.

---

[← Previous: What is a Shell?](01-what-is-a-shell.md) | [Module index](README.md) | [Next: Shell vs Terminal →](03-shell-vs-terminal.md)
