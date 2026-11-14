# 10 — Executable Permissions

[← Previous: Creating and Executing Bash Scripts](09-creating-and-executing-scripts.md) | [Module index](README.md) | [Next: Bash Script Debugging Fundamentals →](11-bash-script-debugging.md)

## 1. Overview

Linux controls who may read, modify and run every file through a compact permission model. A script cannot be run directly (`./script.sh`) unless the executing user has the **execute** permission on it. Setting permissions correctly, and no more broadly than necessary, is a core security skill and a daily DevOps task.

## 2. Definition

**File permissions** are attributes stored with each file that define what the **owner**, the file's **group**, and **others** (everyone else) may do: **r**ead, **w**rite and e**x**ecute. The command `chmod` ("change mode") modifies them.

## 3. Detailed Explanation

### Reading `ls -l`

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

### What each permission means

| Permission | On a file | On a directory |
|------------|-----------|----------------|
| `r` (read) | Read the contents | List the names inside |
| `w` (write) | Modify the contents | Create, rename or delete entries inside (also needs `x`) |
| `x` (execute) | Run the file as a program or script | Enter (traverse) the directory and access items by name |

For a script run **directly** on Linux, the user needs `x` on the file and `x` on every directory in its path. For a shebang-based interpreted script, the kernel starts the interpreter and provides access to the script; the caller does not generally need a separate `r` permission on the script. Running `bash script.sh` requires `r` permission because Bash must read the script.

### Octal (numeric) notation

Read = 4, write = 2, execute = 1; add them for each class.

| Octal | Symbolic | Typical use |
|-------|----------|-------------|
| `600` | `rw-------` | Private files, SSH private keys |
| `644` | `rw-r--r--` | Normal documents (including Markdown) |
| `700` | `rwx------` | Private scripts and private directories |
| `750` | `rwxr-x---` | Scripts shared with a group |
| `755` | `rwxr-xr-x` | Shared, read-only tools and public directories |
| `777` | `rwxrwxrwx` | **Avoid**: anyone can modify and execute |

### Symbolic notation with `chmod`

```text
chmod u+x file         add execute for the owner (user)
chmod g-w file         remove write for the group
chmod o-rwx file       remove all access for others
chmod a+r file         add read for all (a = u+g+o)
chmod u=rwx,go=rx file set exact permissions
```

### `umask`

The `umask` masks permission bits when files and directories are created. New files normally start from a base mode of `666` and directories from `777`; the resulting permissions are calculated by applying the bitwise operation `base_mode & ~umask`. A umask of `022` produces files `644` and directories `755`; `002` produces `664` and `775`; `077` produces `600` and `700`. Ubuntu commonly uses `002` for regular users with private user groups, but this can vary by configuration; check with `umask`.

### Ownership

`ls -l` shows the owner and group. Changing ownership with `chown` normally requires administrator privileges and is rarely needed for personal scripts. If a file is owned by the wrong user, fix the cause (for example, a previous `sudo` run) rather than loosening permissions.

### Special bits (awareness only)

| Bit | Effect | Note |
|-----|--------|------|
| `setuid` | Run with the file owner's identity | **Ignored for interpreted scripts on Linux**; do not use for scripts |
| `setgid` | Run with the group, or inherit group on directories | Used on shared directories |
| sticky | Restricts deleting or renaming entries to the file owner, directory owner, or a privileged process | Used on `/tmp` |

### Git and the execute bit

Git records whether a file is executable (mode `100755` vs `100644`). Check with `git ls-files --stage <file>`. A file that loses its execute bit in a commit will fail when others clone it and run `./script.sh`.

### Mount options

A filesystem mounted with `noexec` refuses to run programs from it, even with `x` set. `findmnt -T <path>` shows the options. This is a security hardening measure (commonly applied to `/tmp` and data volumes).

## 4. How It Works

1. When a process calls `execve()` on a file, the kernel checks the file's mode bits against the process's effective user ID and group IDs.
2. The kernel picks **one** class: owner if the user owns the file, otherwise group if the user is in the group, otherwise others. Only that class's bits apply.
3. If the `x` bit is missing for that class, the call fails with `EACCES` and Bash reports `Permission denied` with exit status `126`.
4. The kernel also checks directory traversal (`x`) along the path and the mount's `noexec` flag.
5. `chmod` changes the mode bits stored in the file's inode; only the owner (or an administrator) can change them.

## 5. Why It Matters in DevOps

- Deployment and automation scripts must be executable by the right account (and by no one else).
- Overly broad permissions are a common finding in security audits and a route for privilege escalation.
- SSH refuses private keys that are too open, and many tools refuse world-writable config files.
- Lost execute bits in Git cause "Permission denied" failures in CI and on freshly cloned servers.
- Correct permissions on directories and logs ensure services can write where they must and nowhere else.

## 6. Syntax and Commands

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

## 7. Command-by-Command Explanation

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

## 8. Practical Examples

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

## 9. Expected Output

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

## 10. Common Mistakes

- Using `chmod 777` (or `chmod -R 777`) to "fix" a permissions error.
- Running `chmod +x` on every file recursively, making data and documents executable.
- Forgetting directory execute permission, then being unable to enter or access files in it.
- Using `sudo` to run or edit files, leaving root-owned files in your home directory.
- Making a script writable by group or others so it can be tampered with.
- Setting `644` on SSH private keys (SSH rejects it; use `600`).
- Assuming `setuid` works on shell scripts.
- Ignoring `noexec` mounts when `x` appears to be set but execution still fails.
- Forgetting that `chmod` changes do not "stick" for Windows-mounted or special filesystems.

## 11. Troubleshooting

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

## 12. Security Best Practices

- Apply the **principle of least privilege**: grant the minimum permissions required, to the fewest users.
- Prefer `700` for personal scripts, `750` for group-shared scripts and `755` only for intentionally shared tools; never `777` or world-writable files.
- Keep SSH private keys at `600` or `400`, and the `~/.ssh` directory at `700`.
- Keep files that hold secrets at `600` and out of version control.
- Use `chmod u+x` for a single file instead of recursive `chmod -R +x`.
- Do not run scripts as root unless needed; never make a script `setuid`.
- Regularly audit for world-writable files and unexpected executables (`find DIR -perm -0002`).
- Treat `sudo chmod` and `sudo chown` as exceptional operations that require understanding of the cause and effect.
- Consider `noexec` on temporary and data mounts as part of system hardening (changing mount options is an administrator decision outside this module).

## 13. Interview Questions

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

## 14. Practical Exercises

1. Create a script, observe `Permission denied`, add execute with `chmod u+x`, and run it.
2. Express `rwxr-x---` in octal and set it on a practice script, verifying with `stat`.
3. Create files under `umask 077` and `umask 022` in subshells and compare their modes.
4. Use `find` to locate `.sh` files in `~/practice` that are not executable by their owner.
5. Create a file with `chmod 666`, find it with the world-writable `find` command, then correct it to `644`.
6. Use `namei -l` on a path to see the permissions of each directory component.

## 15. Key Takeaways

- Permissions are `rwx` for owner, group and others; the kernel applies only the first matching class.
- `chmod u+x` is the minimal change to make your own script runnable.
- Common modes: `600`, `644`, `700`, `750`, `755`; avoid `777`.
- Directories need `x` to be entered; `noexec` mounts block execution regardless of `x`.
- Exit status `126` signals a "cannot execute" problem.
- Least privilege, no unnecessary `sudo`, and regular audits keep systems safe.

---

[← Previous: Creating and Executing Bash Scripts](09-creating-and-executing-scripts.md) | [Module index](README.md) | [Next: Bash Script Debugging Fundamentals →](11-bash-script-debugging.md)
