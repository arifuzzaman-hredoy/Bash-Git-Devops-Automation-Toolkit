# 09 — Creating and Executing Bash Scripts

[← Previous: Shebang](08-shebang.md) | [Module index](README.md) | [Next: Executable Permissions →](10-executable-permissions.md)

## 1. Overview

Writing a script is simple; running it **correctly and safely** requires understanding the different ways to execute it. This topic covers creating scripts with an editor or a here-document, running them via an explicit interpreter, directly through the shebang, or by sourcing, and getting scripts onto an EC2 server from a Windows PC without breaking them.

## 2. Definition

A **Bash script** is a plain-text file containing shell commands, normally with a `.sh` extension (the extension is a convention, not a requirement). **Executing** a script means starting a process that reads and runs those commands. **Sourcing** a script means running its commands inside the *current* shell process.

## 3. Detailed Explanation

### Creating a script

| Method | When to use |
|--------|-------------|
| `nano script.sh` or `vim script.sh` | Normal editing on the server |
| `cat > script.sh <<'EOF'` (text) `EOF` | Quickly creating a file from a pasted block; the quoted `'EOF'` prevents expansion |
| `printf 'text' > script.sh` | One-liners and tests |
| Copy from your PC with `scp` | Scripts maintained on Windows; check line endings and checksums |
| `git clone` / `git pull` | Normal workflow for repository-managed scripts |

### Ways to run a script

| Method | Command | Needs exec bit? | Uses shebang? | Runs in |
|--------|---------|-----------------|---------------|---------|
| Explicit interpreter | `bash script.sh` | No | No (Bash is explicit) | Child process |
| Direct execution (relative) | `./script.sh` | Yes | Yes | Child process |
| Direct execution (absolute) | `/home/ubuntu/bin/script.sh` | Yes | Yes | Child process |
| Through `PATH` | `script.sh` | Yes | Yes | Child process |
| Sourcing | `source script.sh` or `. script.sh` | No | No | **Current shell** |
| Using `sh` | `sh script.sh` | No | No (`sh` is explicit; Dash on Ubuntu) | Child process (selected `sh` implementation) |

### Child process vs sourcing

A script executed normally runs in a child process: its variables and `cd` commands vanish when it ends. A **sourced** script alters the current shell: it can set variables, define functions and change directory. Source only files that you trust and that are designed to be sourced (for example environment setup files).

### Positional parameters and status

| Item | Meaning |
|------|---------|
| `$0` | Name or path used to start the script |
| `$1`, `$2`, `$3` and so on | Arguments |
| `$#` | Number of arguments |
| `"$@"` | All arguments, each quoted separately |
| `$?` | Exit status of the last command |
| `$$` | PID of the running shell |

### Placing scripts on `PATH`

To run a script by name, install it in a directory listed in `PATH`. On Ubuntu, `~/bin` and `~/.local/bin` are added to `PATH` by `~/.profile` at login **if the directory exists** (open a new login session after creating it). Use a personal directory rather than system locations, so no `sudo` is needed.

### Transferring from Windows to EC2

```text
KEY_FILE="/path/to/key.pem"
EC2_PUBLIC_IP="203.0.113.10"  # Replace with the actual server IP
scp -i "$KEY_FILE" 01-module-01-docs.sh "ubuntu@${EC2_PUBLIC_IP}:~/"
```

- Replace the key path and address with your own values; keep the `.pem` file private.
- Compare checksums before and after transfer: `Get-FileHash <file> -Algorithm SHA256` in Windows PowerShell and `sha256sum <file>` on Linux.
- Check line endings with `file` and `cat -A` (Topic 8).
- Review the script (`less script.sh`) and syntax-check it (`bash -n script.sh`) before running it.

## 4. How It Works

**`./script.sh`:** Bash checks the file exists and has the execute bit, calls `fork()`, the child calls `execve()`, the kernel reads the shebang and starts the interpreter, which reads and runs the file. Bash waits and stores the exit status in `$?`.

**`bash script.sh`:** `bash` itself is the executable that the kernel starts; the script is merely a data file passed as an argument, so the execute bit and the shebang are unnecessary (read permission is enough).

**`source script.sh`:** The current shell opens the file and executes each command itself. No new process is created, so changes persist.

## 5. Why It Matters in DevOps

- Deployment, backup and maintenance scripts are run in all of these ways by different tools (cron, CI, systemd, humans).
- Mixing up `source` and execution causes mysterious "variable not set" or "directory did not change" bugs.
- Understanding Windows-to-Linux transfer problems saves hours when moving scripts to servers.
- Verifying integrity and reading scripts before executing them is a core security habit.
- Placing scripts in a controlled location with appropriate permissions supports repeatable operations.

## 6. Syntax and Commands

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

## 7. Command-by-Command Explanation

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

## 8. Practical Examples

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

## 9. Expected Output

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

## 10. Common Mistakes

- Typing `script.sh` instead of `./script.sh` when the current directory is not in `PATH`.
- Forgetting `chmod u+x` (error `Permission denied`) or granting too much (`chmod 777`).
- Running a script with `sh script.sh` and being surprised by Bash-only features failing.
- Expecting `cd` or variable assignments in an executed script to affect the calling shell.
- Sourcing scripts that were not designed to be sourced (they may call `exit` and close your session).
- Editing a script on Windows and saving with CRLF line endings.
- Running a script with `sudo` "just to make it work".
- Putting practice scripts inside the Git repository and committing them by accident.
- Adding `.` to `PATH` to avoid typing `./`.

## 11. Troubleshooting

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

## 12. Security Best Practices

- Never execute a script you have not read, especially downloads. Avoid `curl URL | bash`; download first, inspect, then run.
- Verify transferred scripts with checksums, and keep private keys (`.pem`) at `chmod 400` or `600`.
- Use the narrowest permissions that work: `chmod 700` for personal scripts, `chmod 755` for shared read-only tools; never `777`.
- Do not run scripts with `sudo` unless the script genuinely needs elevated rights, and then read it first.
- Source only trusted files, and prefer an absolute or `./` path when sourcing.
- Never hardcode credentials in scripts; avoid passing secrets as command-line arguments.
- Keep scripts in directories that only you (or trusted administrators) can write to.
- Delete installer or helper scripts after verified use if they are no longer needed.

## 13. Interview Questions

1. **How can you run a Bash script?** `bash script.sh`, `./script.sh` (with execute bit), through `PATH`, or `source script.sh`.
2. **Difference between `./script.sh` and `bash script.sh`?** The first needs the execute bit and uses the shebang; the second needs only read permission and explicitly selects Bash.
3. **Difference between executing and sourcing?** Execution uses a child process; sourcing runs in the current shell, so changes persist.
4. **Why does `script.sh` fail while `./script.sh` works?** The current directory is not in `PATH`.
5. **What does exit status 126 mean?** The command was found but could not be executed (often permissions).
6. **What do `$0`, `$1`, `$#` and `"$@"` represent?** Script name, first argument, argument count, all arguments quoted.
7. **Why avoid `curl URL | bash`?** You execute unseen code, possibly modified or incomplete, with your privileges.
8. **How would you check a script transferred from Windows?** Compare checksums, check line endings, run `bash -n`, read it.

## 14. Practical Exercises

1. Create `hello.sh` as in Example 1 and run it with no argument and with two arguments.
2. Run it with `bash hello.sh`, `./hello.sh` and `sh hello.sh`. Record any differences.
3. Remove the execute bit (`chmod u-x hello.sh`), run `./hello.sh`, record the status, then restore it.
4. Demonstrate execute-versus-source with a script that sets a variable and changes directory.
5. Copy a script to `~/bin`, open a new login session and run it by name.
6. Generate a checksum on Windows and on EC2 for the same file and confirm they match.

## 15. Key Takeaways

- Create scripts with an editor or a quoted here-document, and practise outside the Git repository.
- `./script.sh` uses the shebang and execute bit; `bash script.sh` does not need either.
- Executing runs a child process; sourcing changes the current shell.
- Always read, syntax-check and verify scripts before running them, especially transferred or downloaded ones.
- Use the narrowest permissions and avoid `sudo` unless necessary.
- Watch for CRLF line endings when moving files from Windows.

---

[← Previous: Shebang](08-shebang.md) | [Module index](README.md) | [Next: Executable Permissions →](10-executable-permissions.md)
