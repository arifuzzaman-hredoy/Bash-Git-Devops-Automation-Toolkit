# 04 — Bash vs Other Shells

[← Previous: Shell vs Terminal](03-shell-vs-terminal.md) | [Module index](README.md) | [Next: Linux Command Execution →](05-linux-command-execution.md)

## 1. Overview

Bash is not the only shell. Ubuntu itself uses two different shells for different jobs: **Bash** for interactive use and most user scripts, and **dash** as `/bin/sh` for fast, minimal system scripts. Other shells such as zsh, fish, ksh and PowerShell exist for different audiences. Knowing the differences prevents the classic "it works in my terminal but fails in the pipeline" problem.

## 2. Definition

A *shell family* describes shells that share a common language lineage:

- **Bourne family:** `sh`, `bash`, `dash`, `ksh`, `zsh`, `ash`/BusyBox `sh`.
- **C shell family:** `csh`, `tcsh`.
- **Others:** `fish`, PowerShell (`pwsh`), `nushell`.

**POSIX `sh`** is the portable, standardised subset of the Bourne-family shell language. **Bashism** means a feature that works in Bash but is not guaranteed in POSIX `sh`.

## 3. Detailed Explanation

### Comparison

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

### Why Ubuntu uses dash for `/bin/sh`

Debian and Ubuntu moved `/bin/sh` to dash to speed up boot and package scripts. Consequences:

- A script with `#!/bin/sh` runs under dash on Ubuntu, so Bash-only syntax fails.
- `sh script.sh` ignores the script's shebang and uses `sh` explicitly.
- Interactive use still defaults to Bash because the user's login shell is `/bin/bash`.

### Common bashisms that fail in dash

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

### Choosing a shell for scripts

- Use **`#!/usr/bin/env bash`** (or `#!/bin/bash`) when you want Bash features. This is the default recommendation for this toolkit.
- Use **`#!/bin/sh`** only when the script must be portable to minimal environments (Alpine, BusyBox, some init scripts) and you have limited yourself to POSIX features.
- Use **Python or another language** when logic becomes complex (heavy data structures, JSON handling, large programs).

## 4. How It Works

When a script is executed, the **kernel** reads its shebang and starts the named interpreter (Topic 8). The interpreter, not your login shell, determines the syntax rules. Your login shell only matters for interactive use and for scripts that have no shebang (in which case a shell such as Bash may be used to run them as a fallback).

When Bash is invoked with the name `sh`, it enters POSIX-compatibility mode and changes some behaviour. On Ubuntu, however, `/bin/sh` is dash, not Bash in that mode.

## 5. Why It Matters in DevOps

- CI/CD systems, container images and `cron` commonly use `/bin/sh` by default, so a Bash-only snippet may fail there even though it works in your SSH session.
- Dockerfile `RUN` instructions use `/bin/sh -c` by default; Alpine images often have no Bash at all.
- EC2 user-data, `systemd` units and Ansible tasks each choose their own interpreter; being explicit avoids surprises.
- Portable scripts reduce incidents when workloads move between Ubuntu, Amazon Linux, Debian and Alpine.
- Choosing deliberately between Bash and POSIX `sh` is part of professional script design.

## 6. Syntax and Commands

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

## 7. Command-by-Command Explanation

| Command | Explanation |
|---------|-------------|
| `ls -l /bin/sh` | Shows the symlink; on Ubuntu 24.04 it points to `dash`. |
| `readlink -f /bin/sh` | Resolves all symlinks; usually prints `/usr/bin/dash`. |
| `cat /etc/shells` | Lists permitted login shells. |
| `getent passwd "$USER" \| cut -d: -f7` | Reads your account entry and prints field 7, the login shell. |
| `sh -c '[[ 1 == 1 ]]'` | Runs the test in `sh` (dash); it fails because `[[` does not exist there. |
| `bash -c '[[ 1 == 1 ]]; echo "rc=$?"'` | Same test in Bash; succeeds with status 0. |
| `command -v dash bash zsh fish` | Prints the path for each installed shell; missing ones print nothing. |

## 8. Practical Examples

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

## 9. Expected Output

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

## 10. Common Mistakes

- Using `#!/bin/sh` and then writing Bash-only code.
- Running `sh script.sh` on a Bash script and being surprised by errors.
- Assuming `/bin/sh` is Bash on every distribution (it is on some, not on Ubuntu or Debian).
- Assuming Bash exists in every container image; minimal images may only have `sh`.
- Changing the system `/bin/sh` symlink to Bash "to fix" a script. This alters system behaviour and is unnecessary; fix the script's shebang instead.
- Using `echo -e` and `echo -n` in portable scripts instead of `printf`.

## 11. Troubleshooting

| Symptom | Likely cause | Safe next step |
|---------|--------------|----------------|
| `[[: not found` | Run by dash | Use a Bash shebang or run with `bash` |
| `Bad substitution` | Bash expansion under `sh` | Same as above, or rewrite using POSIX constructs |
| `Syntax error: "(" unexpected` | Array syntax under dash | Run with Bash |
| `bash: not found` in a container | Minimal image without Bash | Write POSIX `sh` or use an image that includes Bash |
| Script works via SSH but not in CI | Different default shell | Specify the shell explicitly in the pipeline step |

## 12. Security Best Practices

- Do not replace or re-link system shells (`/bin/sh`) to work around script problems.
- Only change a user's login shell to entries listed in `/etc/shells`.
- Be wary of `#!/usr/bin/env` shebangs in privileged contexts, because they depend on `PATH` (Topic 8).
- In minimal containers, remember that fewer shells mean a smaller attack surface; do not add Bash unless needed.
- Quote variables in every shell. The quoting rules differ in subtle ways in zsh and fish; never copy scripts between shells without review.
- Do not run unreviewed scripts with *any* shell.

## 13. Interview Questions

1. **What is `/bin/sh` on Ubuntu?** A symlink to `dash`.
2. **Why does Ubuntu use dash?** It is smaller and faster for system scripts and boot.
3. **What is a bashism?** A Bash feature that is not part of POSIX `sh`.
4. **Give three bashisms.** `[[ ]]`, arrays, `${var,,}`, `<( )`, `&>`.
5. **How does `sh script.sh` differ from `./script.sh`?** `sh script.sh` forces `sh` and ignores the shebang; `./script.sh` honours the shebang.
6. **When would you choose POSIX `sh` over Bash?** For maximum portability, minimal containers or init-style scripts.
7. **Is fish suitable for portable automation scripts?** No; it is not POSIX-compatible.

## 14. Practical Exercises

1. Show what `/bin/sh` and your login shell are on your EC2 instance.
2. Write a three-line script using `[[ ]]`, run it with `bash` and with `sh`, and record both results.
3. Replace `echo -e "a\tb"` with a `printf` equivalent and test it in both shells.
4. Rewrite a `[[ -f file ]]` test as a POSIX `[ -f file ]` test.
5. List which of dash, bash, zsh and fish are installed on your server without installing anything.

## 15. Key Takeaways

- Ubuntu: Bash is interactive and the default for this toolkit; `/bin/sh` is dash.
- The shebang and the way a script is started decide which interpreter runs it.
- Bashisms fail under `sh`; use `printf`, `[ ]` and `.` for portable code.
- Choose the interpreter deliberately and state it explicitly in scripts and pipelines.
- Do not alter system shells to fix script bugs.

---

[← Previous: Shell vs Terminal](03-shell-vs-terminal.md) | [Module index](README.md) | [Next: Linux Command Execution →](05-linux-command-execution.md)
