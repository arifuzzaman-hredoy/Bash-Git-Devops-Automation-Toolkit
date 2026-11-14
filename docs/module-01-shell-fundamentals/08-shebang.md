# 08 — Shebang

[← Previous: Bash Script Structure](07-bash-script-structure.md) | [Module index](README.md) | [Next: Creating and Executing Bash Scripts →](09-creating-and-executing-scripts.md)

## 1. Overview

The shebang is the very first line of an executable script. It tells the Linux kernel which interpreter should run the file. Without it, or with a wrong one, a script may run under the wrong shell, fail with a cryptic `bad interpreter` message, or behave differently between your terminal and an automated pipeline.

## 2. Definition

A **shebang** (also called *hashbang*, from "hash" `#` and "bang" `!`) is the two-character sequence `#!` at the very start of a file, followed by the absolute path of an interpreter and, optionally, one argument:

```text
#!/path/to/interpreter [optional-argument]
```

To the shell and to Bash itself, the line is just a comment because it starts with `#`. The meaning comes from the **kernel**.

## 3. Detailed Explanation

### Who reads the shebang?

The kernel does, during the `execve()` system call. If the first two bytes of an executable file are `#!`, the kernel reads the rest of the line, starts that interpreter, and passes it the script's path as an argument. The shell is not involved in interpreting the shebang when a script is run directly (`./script.sh`).

### Common shebangs

| Shebang | Meaning | Typical use |
|---------|---------|-------------|
| `#!/bin/bash` | Use Bash at a fixed path | Servers where Bash is known to be at `/bin/bash` |
| `#!/usr/bin/env bash` | Find `bash` in `PATH` | Portable across systems with Bash in different locations |
| `#!/bin/sh` | POSIX shell | Portable scripts; dash on Ubuntu |
| `#!/usr/bin/env python3` | Python 3 from `PATH` | Python scripts |
| `#!/usr/bin/env -S bash -e` | GNU `env -S` splits the arguments | Passing multiple interpreter arguments where supported |

### `/bin/bash` vs `/usr/bin/env bash`

| Aspect | `#!/bin/bash` | `#!/usr/bin/env bash` |
|--------|---------------|------------------------|
| Predictability | Always that exact binary | Whichever `bash` is first in `PATH` |
| Portability | Fails where Bash is elsewhere (some BSD systems, Nix, some containers) | Works wherever `/usr/bin/env` exists and Bash is in `PATH` |
| Security in privileged contexts | Stronger: not influenced by `PATH` | A user-controlled `PATH` can substitute another `bash` |
| Newer Bash from a package manager | Ignored | Used if earlier in `PATH` |

This toolkit uses `#!/usr/bin/env bash` for portability. For scripts that run as root or from a restricted, security-sensitive context, prefer an absolute interpreter path.

### Rules and limits

- `#!` must be the **first two bytes** of the file: no leading blank line, space or Byte Order Mark (BOM).
- The kernel passes everything after the interpreter path as **one single argument**, so `#!/usr/bin/env bash -e` does not work as expected. Use `env -S`, or call `set -e` inside the script.
- The interpreter must be an absolute path (the `env` trick is how `PATH` lookup is achieved).
- Historically the shebang line was limited to 127 characters; modern Linux kernels allow longer lines, but keep it short.
- Files with **Windows (CRLF) line endings** add a hidden carriage return to the interpreter name and break the shebang.
- The shebang only applies when the file is **executed directly**. `bash script.sh`, `sh script.sh` and `source script.sh` ignore it.

### No shebang

If an executable text file has no shebang, `execve()` fails with `ENOEXEC`. Bash then typically runs the file itself as a shell script, but other callers (cron wrappers, Python's `subprocess`, other languages) may not. Always include a shebang.

## 4. How It Works

1. You run `./deploy.sh`.
2. Bash calls `execve("./deploy.sh", args, environment)`.
3. The kernel opens the file, sees `#!`, and extracts the interpreter and optional argument.
4. The kernel replaces the new process with the interpreter and calls it as `interpreter [optional-arg] ./deploy.sh args`.
5. The interpreter reads the file. The shebang line is ignored as a comment.
6. The script runs; its exit status is returned to the parent shell.

With `#!/usr/bin/env bash` there is one more hop: the kernel starts `/usr/bin/env`, which searches `PATH` for `bash` and then executes it with the script path.

## 5. Why It Matters in DevOps

- Scripts run from cron, CI/CD, systemd, Ansible and `ssh host ./script` rely on the shebang rather than the user's shell.
- A wrong shebang is a classic cause of pipeline failures on different runner images.
- Windows-to-Linux transfers (as in this project's workflow) often introduce CRLF line endings that silently break shebangs.
- Using a consistent, correct shebang across the toolkit makes behaviour predictable across Ubuntu, Debian, Amazon Linux and containers.
- It documents the interpreter's expected language, helping linters, editors and reviewers.

## 6. Syntax and Commands

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

## 7. Command-by-Command Explanation

| Command | Explanation |
|---------|-------------|
| `head -n 1 script.sh` | Prints the first line only, which should be the shebang. |
| `file script.sh` | Identifies the file; for a script it reports the interpreter and adds `with CRLF line terminators` if Windows line endings are present. |
| `cat -A` | Makes invisible characters visible. `$` marks the end of each line, `^M` marks a carriage return. |
| `command -v env` | Confirms `/usr/bin/env` is where the kernel expects it. |
| `printf 'line1\nline2' > t.sh` | Creates a file; `printf` interprets `\n` as newlines. |
| `sed -i 's/\r$//'` | Edits the file in place, deleting a trailing carriage return from every line. Make a copy first (`cp script.sh script.sh.bak`). |

## 8. Practical Examples

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

## 9. Expected Output

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

## 10. Common Mistakes

- A blank line or space before `#!`.
- Misspelling the interpreter path (`#!/bin/bsh`) or using a path that does not exist.
- Saving the script with Windows line endings (CRLF) or a UTF-8 BOM.
- Expecting `#!/usr/bin/env bash -e` to pass `-e`.
- Using `#!/bin/sh` for scripts with Bash-only syntax.
- Believing the shebang takes effect with `bash script.sh` or `source script.sh`.
- Putting the shebang on line 2 after a comment.
- Hardcoding `/home/user/venv/bin/python` interpreters or virtual-environment paths in shared scripts.

## 11. Troubleshooting

| Symptom | Likely cause | Safe next step |
|---------|--------------|----------------|
| `bad interpreter: No such file or directory` | Wrong path, or `^M` at the end of the line | `head -n 1 script \| cat -A`; `file script` |
| `/usr/bin/env: ‘bash\r’: No such file or directory` | CRLF line endings | Convert line endings after making a backup |
| `Exec format error` | Binary for wrong architecture, or no shebang in a non-shell caller | Check `file` output and the first line |
| `Permission denied` | Missing execute bit, or `noexec` mount | `ls -l`; `findmnt -T .` (Topic 10) |
| `[[: not found` | `#!/bin/sh` with Bash syntax | Change to `#!/usr/bin/env bash` |
| Different behaviour in cron | Different `PATH` found a different `bash` | Use an absolute interpreter path or set `PATH` |
| Script ignores the shebang | Run as `bash script` or `sh script` | Execute it directly with `./script` |

## 12. Security Best Practices

- In scripts that run as root or via `sudo`, use an absolute interpreter (`#!/bin/bash`) so a manipulated `PATH` cannot substitute a malicious `bash`.
- Never place `.` or world-writable directories in `PATH`.
- Do not make scripts `setuid`: Linux ignores the `setuid` bit on interpreted scripts for good reason, and trying to work around it is dangerous.
- Inspect a downloaded script's first line and entire contents before executing it.
- Ensure scripts are not writable by other users, so nobody can replace the interpreter line or code.
- Verify files transferred from Windows (checksums, line endings) before running them on servers.
- Avoid shebangs that point to user-writable locations (`/tmp/script-dir`, home directories).

## 13. Interview Questions

1. **What is a shebang?** `#!` followed by an interpreter path at the start of a script, read by the kernel.
2. **Who interprets the shebang, the shell or the kernel?** The kernel, during `execve()`.
3. **Difference between `#!/bin/bash` and `#!/usr/bin/env bash`?** Fixed path versus `PATH` lookup; the latter is more portable, the former is safer for privileged scripts.
4. **Does the shebang apply to `bash script.sh`?** No, the explicitly named interpreter is used.
5. **Why does `#!/usr/bin/env bash -e` not work on Linux?** The kernel passes `bash -e` as one argument; use `env -S` or `set -e`.
6. **How do CRLF line endings break a script?** The carriage return becomes part of the interpreter name.
7. **How do you detect CRLF endings?** `file script.sh` or `cat -A script.sh`.
8. **What happens if a script has no shebang?** `execve` fails with `ENOEXEC`; Bash may fall back to running it itself, other callers may not.

## 14. Practical Exercises

1. Create a script with `#!/usr/bin/env bash`, run it with `./` and with `sh`, and explain any difference.
2. Intentionally write `#!/bin/bsh`, run it, and record the error message.
3. Create a CRLF script, diagnose it with `file` and `cat -A`, then repair a **copy** of it.
4. Write a one-line Python script with an `env` shebang and run it directly.
5. Find the first line of every `.sh` file in a practice directory: `for f in *.sh; do printf '%s: ' "$f"; head -n 1 "$f"; done`.

## 15. Key Takeaways

- The shebang is read by the kernel and must be the first two bytes of the file.
- `#!/usr/bin/env bash` favours portability; an absolute path favours security in privileged contexts.
- The kernel passes only one argument after the interpreter.
- CRLF line endings are a frequent, easily diagnosed cause of failures after Windows transfers.
- The shebang is ignored when you call the interpreter explicitly.
- Never rely on `setuid` scripts and keep scripts non-writable by others.

---

[← Previous: Bash Script Structure](07-bash-script-structure.md) | [Module index](README.md) | [Next: Creating and Executing Bash Scripts →](09-creating-and-executing-scripts.md)
