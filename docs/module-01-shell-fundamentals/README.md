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

| # | Topic | Document |
|---|-------|----------|
| 1 | What is a Shell? | [01-what-is-a-shell.md](01-what-is-a-shell.md) |
| 2 | What is Bash? | [02-what-is-bash.md](02-what-is-bash.md) |
| 3 | Shell vs Terminal | [03-shell-vs-terminal.md](03-shell-vs-terminal.md) |
| 4 | Bash vs Other Shells | [04-bash-vs-other-shells.md](04-bash-vs-other-shells.md) |
| 5 | Linux Command Execution | [05-linux-command-execution.md](05-linux-command-execution.md) |
| 6 | Shell Environment | [06-shell-environment.md](06-shell-environment.md) |
| 7 | Bash Script Structure | [07-bash-script-structure.md](07-bash-script-structure.md) |
| 8 | Shebang | [08-shebang.md](08-shebang.md) |
| 9 | Creating and Executing Bash Scripts | [09-creating-and-executing-scripts.md](09-creating-and-executing-scripts.md) |
| 10 | Executable Permissions | [10-executable-permissions.md](10-executable-permissions.md) |
| 11 | Bash Script Debugging Fundamentals | [11-bash-script-debugging.md](11-bash-script-debugging.md) |

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
