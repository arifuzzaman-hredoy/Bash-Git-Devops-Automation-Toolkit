# Module 01 — Shell & Bash Fundamentals

**Project:** Bash & Git DevOps Automation Toolkit
**Module:** 01
**Difficulty:** Beginner
**Environment:** Ubuntu Linux on AWS EC2
**Primary Shell:** GNU Bash
**Target Audience:** Beginner Linux Users and Junior DevOps Engineers

---

# 1. Module Overview

## What is this module about?

Before learning Bash automation, we need to understand how Linux users interact with the operating system and how commands are executed.

In this module, we learn about the Shell, Bash, Linux command execution, environment variables, and the basic structure of Bash scripts.

We also learn how to create scripts, execute them, manage executable permissions, and troubleshoot common script problems.

These are the foundations of Linux administration and DevOps automation.

## Learning Objectives

By completing this module, you should be able to:

1. Explain what a Shell is.
2. Understand Bash and its purpose.
3. Explain the difference between a Shell and a Terminal.
4. Compare Bash with other Linux shells.
5. Understand how Linux executes commands.
6. Work with shell variables and environment variables.
7. Understand the basic structure of a Bash script.
8. Explain and use a shebang.
9. Create and execute Bash scripts.
10. Manage file permissions using `chmod`.
11. Identify and troubleshoot basic Bash script errors.

## Prerequisites

- Basic computer knowledge.
- Access to an Ubuntu Linux environment.
- Basic familiarity with terminal commands.
- An AWS EC2 Ubuntu instance for practical exercises.

## Topics Covered

| No. | Topic |
|---|---|
| 01 | What is a Shell? |
| 02 | What is Bash? |
| 03 | Shell vs Terminal |
| 04 | Bash vs Other Shells |
| 05 | Linux Command Execution |
| 06 | Shell Environment |
| 07 | Bash Script Structure |
| 08 | Shebang |
| 09 | Creating and Executing Bash Scripts |
| 10 | Executable Permissions |
| 11 | Bash Script Debugging Fundamentals |

## Recommended Learning Sequence

Study the topics in numerical order.

For every topic:

1. Understand the definition.
2. Read the explanation.
3. Study the commands.
4. Understand the expected output.
5. Perform the practical exercise.
6. Answer the knowledge-check questions.

## Practical Learning Outcomes

After completing the practical work, you should be able to:

- Inspect your Linux shell environment.
- Identify the current user and working directory.
- Understand how commands are located and executed.
- Create and use shell variables.
- Create basic Bash scripts.
- Execute scripts using different methods.
- Configure executable permissions.
- Debug common Bash errors.

## Why These Skills Matter in DevOps

DevOps engineers regularly work with Linux servers.

Many daily responsibilities involve command-line operations, including:

- Server administration.
- Application deployment.
- Backup automation.
- Log management.
- System monitoring.
- CI/CD pipelines.
- Infrastructure automation.

Bash helps automate repetitive tasks and makes server administration more efficient.

## Completion Checklist

Mark a topic as complete only after understanding its concepts and completing its required practical exercises.

- [ ] Topic 01 — What is a Shell?
- [ ] Topic 02 — What is Bash?
- [ ] Topic 03 — Shell vs Terminal
- [ ] Topic 04 — Bash vs Other Shells
- [ ] Topic 05 — Linux Command Execution
- [ ] Topic 06 — Shell Environment
- [ ] Topic 07 — Bash Script Structure
- [ ] Topic 08 — Shebang
- [ ] Topic 09 — Creating and Executing Bash Scripts
- [ ] Topic 10 — Executable Permissions
- [ ] Topic 11 — Bash Script Debugging Fundamentals

---

# 2. Topic 01 — What is a Shell?

## 2.1 Overview

A Shell is a program that allows users to communicate with an operating system through commands.

When we type a command such as:

```bash
pwd
```

the Shell receives the command, processes it, and helps execute it.

## 2.2 Definition

A **Shell** is a command-line interpreter that accepts commands from a user or script and requests the operating system to perform the required operations.

In simple terms:

**A Shell is the interface between the user and the operating system when working with commands.**

## 2.3 How a Shell Works

Consider this command:

```bash
ls
```

The process is:

1. The user enters `ls`.
2. The Shell reads the command.
3. The Shell identifies the command.
4. The operating system executes the requested operation.
5. The result is displayed in the terminal.

A simplified view:

```text
User
  |
  v
Shell
  |
  v
Operating System
  |
  v
Command Result
```

The Shell helps users interact with the operating system without needing to write a separate program for every operation.

## 2.4 What Can a Shell Do?

A Shell can help users:

- Navigate directories.
- Create and remove files.
- Manage processes.
- Run applications.
- Manage environment variables.
- Execute scripts.
- Automate repetitive tasks.

For example:

```bash
pwd
ls
mkdir practice
touch notes.txt
```

These commands demonstrate common file and directory operations.

## 2.5 Types of Shells

Linux supports different shells.

Common examples include:

| Shell | Description |
|---|---|
| Bash | Bourne Again Shell; widely used in Linux |
| sh | Traditional shell interface |
| Zsh | Interactive shell with extensive customization |
| Fish | User-friendly interactive shell |
| Ksh | KornShell |

Not every Linux distribution installs all these shells by default.

## 2.6 Shell Modes

A Shell can operate in different modes.

### Interactive Shell

An interactive shell accepts commands directly from the user.

Example:

```bash
pwd
whoami
date
```

### Non-interactive Shell

A non-interactive shell executes commands from a script or another automated process.

Example:

```bash
bash backup.sh
```

This is particularly useful in DevOps automation.

## 2.7 Command-Line Shell vs Graphical Interface

A graphical interface uses windows, menus, and buttons.

A command-line shell uses text commands.

For example:

- Graphical interface: Open a file manager and create a folder.
- Command line: Run `mkdir project`.

Both can perform similar tasks, but command-line operations are especially useful for remote server administration and automation.

## 2.8 Practical Commands

### Check the current shell process

```bash
echo "$0"
```

### Check the configured login shell

```bash
echo "$SHELL"
```

### Check the current user

```bash
whoami
```

### Check the current directory

```bash
pwd
```

### List files

```bash
ls -la
```

### Check available shells

```bash
cat /etc/shells
```

### Check the Bash version

```bash
bash --version
```

## 2.9 Important Difference: Current Shell vs Login Shell

These two commands provide different information:

```bash
echo "$0"
echo "$SHELL"
```

- `$0` generally identifies the current shell or script name.
- `$SHELL` normally contains the user's configured login shell.

They are not guaranteed to be identical.

## 2.10 Why Shell Knowledge Matters in DevOps

DevOps engineers use shells to:

- Connect to remote Linux servers.
- Execute deployment commands.
- Monitor applications.
- Manage files and processes.
- Run automation scripts.

Understanding the Shell is the first step toward Bash scripting.

## 2.11 Common Mistakes

**Mistake 1:** Assuming the Terminal and Shell are the same.

They are different. The Terminal provides the interface; the Shell interprets commands.

**Mistake 2:** Assuming every Linux system uses Bash.

Different Linux systems may use different default shells.

**Mistake 3:** Assuming `$SHELL` always identifies the currently running shell.

It generally identifies the configured login shell, not necessarily the current process.

## 2.12 Knowledge Check

1. What is a Shell?
2. What is the main responsibility of a Shell?
3. Name four common Linux shells.
4. What is an interactive shell?
5. What is a non-interactive shell?
6. What is the difference between `$0` and `$SHELL`?
7. Why do DevOps engineers use the command line?

## 2.13 Practical Exercise

On your EC2 instance:

```bash
echo "===== CURRENT USER ====="
whoami

echo "===== CURRENT DIRECTORY ====="
pwd

echo "===== CURRENT SHELL ====="
echo "$0"

echo "===== LOGIN SHELL ====="
echo "$SHELL"

echo "===== BASH VERSION ====="
bash --version

echo "===== AVAILABLE SHELLS ====="
cat /etc/shells
```

Compare the output and explain what each command tells you.

**Learning Status:** Basic shell inspection was performed during our EC2 learning. Review the commands and verify them again during practical revision.

---

# 3. Topic 02 — What is Bash?

## 3.1 Overview

Bash is one of the most commonly used shells in Linux.

It allows users to execute commands interactively and write scripts to automate tasks.

Bash is especially important for Linux system administration and DevOps engineering.

## 3.2 Definition

**Bash stands for Bourne Again Shell.**

It is a command-line interpreter and scripting language developed as a free and improved replacement for the traditional Bourne Shell.

In simple terms:

Bash allows us to execute Linux commands and combine them into scripts for automation.

## 3.3 Origin

Bash was created as part of the GNU Project.

It was designed to provide features beyond the traditional Bourne Shell.

It is now widely available across Linux distributions.

## 3.4 Important Bash Features

Bash provides several useful features:

| Feature | Purpose |
|---|---|
| Command execution | Runs Linux commands |
| Variables | Stores values |
| Conditions | Makes decisions |
| Loops | Repeats operations |
| Functions | Organizes reusable code |
| Input and output | Reads input and displays results |
| Redirection | Controls where command output goes |
| Pipelines | Connects commands together |

Some of these features will be explored in later modules.

## 3.5 Bash vs POSIX

POSIX defines standards for operating-system interfaces and shell behavior.

Bash supports many POSIX shell features but also provides additional Bash-specific functionality.

This distinction matters when writing portable shell scripts.

For example, a script written specifically for Bash should identify Bash as its interpreter.

```bash
#!/usr/bin/env bash
```

## 3.6 Bash on Ubuntu

Ubuntu commonly uses Bash as the default login shell for regular users.

We can verify the installed version with:

```bash
bash --version
```

Example output:

```text
GNU bash, version 5.2.x
```

The exact version depends on the installed Ubuntu release and updates.

## 3.7 Check Bash Availability

```bash
command -v bash
```

This displays the location of the Bash executable.

Example:

```text
/usr/bin/bash
```

## 3.8 Run a Bash Command

```bash
bash -c 'echo "Hello from Bash"'
```

Expected output:

```text
Hello from Bash
```

The `-c` option tells Bash to execute the command supplied as a string.

## 3.9 Why Bash Matters in DevOps

Bash is useful for:

- Deployment automation.
- Backup scripts.
- Log cleanup.
- Health checks.
- Server maintenance.
- CI/CD pipeline tasks.

For example, a Bash script can check whether a service is running and report its status.

## 3.10 Common Mistakes

- Confusing Bash with Linux itself.
- Assuming every shell supports Bash-specific syntax.
- Forgetting to specify the correct interpreter in a script.
- Assuming a script works in Bash just because it works in another shell.

## 3.11 Knowledge Check

1. What does Bash stand for?
2. What is Bash?
3. Why was Bash developed?
4. What is the difference between Bash and POSIX?
5. How can you check the installed Bash version?
6. Why is Bash useful in DevOps?

## 3.12 Practical Exercise

Execute:

```bash
echo "===== BASH LOCATION ====="
command -v bash

echo "===== BASH VERSION ====="
bash --version

echo "===== BASH COMMAND TEST ====="
bash -c 'echo "Bash is working correctly"'
```

Verify that Bash is installed and working.

**Learning Status:** Bash version and availability were previously inspected on EC2.

---

# 4. Topic 03 — Shell vs Terminal

## 4.1 Overview

Shell and Terminal are related concepts, but they are not the same.

Understanding the difference is important when working with Linux servers.

## 4.2 What is a Terminal?

A Terminal is an application or interface that allows users to interact with a command-line program.

It accepts keyboard input and displays text output.

Examples include:

- Linux Terminal applications.
- Windows Terminal.
- SSH terminal sessions.

## 4.3 What is a Shell?

A Shell is the program that interprets and executes commands.

Examples include:

- Bash.
- Zsh.
- Fish.
- Ksh.

## 4.4 Main Difference

| Shell | Terminal |
|---|---|
| Interprets commands | Provides a text interface |
| Executes shell commands | Displays input and output |
| Example: Bash | Example: Windows Terminal |
| Can run scripts | Can host a shell session |

A simple analogy:

Think of a Terminal as a classroom and the Shell as the teacher who understands and processes your instructions.

The Terminal provides the place to interact. The Shell understands the commands.

## 4.5 How They Work Together

```text
User
  |
  v
Terminal Application
  |
  v
Shell (Bash)
  |
  v
Operating System
  |
  v
Command Result
```

When you open an Ubuntu terminal, it commonly starts a shell session.

When you type:

```bash
whoami
```

the Terminal sends your input to the Shell. The Shell processes the command, and the result appears in the Terminal.

## 4.6 What is a Pseudo-Terminal?

A pseudo-terminal, commonly called a PTY, provides a terminal-like interface for a program.

SSH sessions often use pseudo-terminals.

This allows a remote shell to behave similarly to a locally opened terminal.

## 4.7 Useful Commands

### Display terminal type

```bash
echo "$TERM"
```

Example:

```text
xterm-256color
```

### Check terminal device

```bash
tty
```

Example:

```text
/dev/pts/0
```

The exact value may differ.

### Check current shell

```bash
echo "$0"
```

### Check login shell

```bash
echo "$SHELL"
```

## 4.8 What is SSH?

SSH stands for Secure Shell.

It is a network protocol used to securely access remote systems.

Example:

```bash
ssh ubuntu@SERVER_PUBLIC_IP
```

Replace `SERVER_PUBLIC_IP` with the actual server IP address.

After connecting, you can interact with the remote shell through your local terminal.

## 4.9 Why This Matters in DevOps

DevOps engineers frequently use SSH to access remote servers.

Understanding the Terminal, Shell, PTY, and SSH helps troubleshoot:

- Remote command execution.
- Interactive sessions.
- Terminal compatibility.
- Remote server administration.

## 4.10 Common Mistakes

- Calling Bash a Terminal.
- Calling Windows Terminal a Shell.
- Assuming SSH and Bash are the same.
- Assuming `$TERM` identifies the current shell.

## 4.11 Knowledge Check

1. What is a Terminal?
2. What is a Shell?
3. Explain the difference between them.
4. What is a PTY?
5. What is SSH?
6. What does `$TERM` represent?
7. How does a Terminal communicate with Bash?

## 4.12 Practical Exercise

Run:

```bash
echo "===== TERMINAL TYPE ====="
echo "$TERM"

echo "===== TERMINAL DEVICE ====="
tty

echo "===== CURRENT SHELL ====="
echo "$0"

echo "===== LOGIN SHELL ====="
echo "$SHELL"
```

Identify which values describe the terminal and which describe the shell.

**Learning Status:** Shell and environment inspection was previously performed. Review the Terminal-specific commands as part of practical revision.

---

# 5. Topic 04 — Bash vs Other Shells

## 5.1 Overview

Linux supports different shells, and each shell has its own features.

Bash is widely used for scripting and system administration, but it is not the only available shell.

## 5.2 Common Shells

| Shell | Full Name | Main Characteristics |
|---|---|---|
| sh | Bourne Shell interface | Traditional shell |
| Bash | Bourne Again Shell | Widely used and feature-rich |
| Zsh | Z Shell | Advanced interactive features |
| Fish | Friendly Interactive Shell | User-friendly syntax and suggestions |
| Ksh | KornShell | Scripting and interactive features |

## 5.3 Bash vs sh

Bash supports many additional features compared with traditional Bourne Shell behavior.

For example, Bash supports arrays and other extended syntax.

A script that uses Bash-specific features may not work correctly under a different shell.

## 5.4 Bash vs Zsh

Zsh offers advanced interactive features and customization.

Bash is commonly available by default on many Linux systems and is widely used for automation.

## 5.5 Bash vs Fish

Fish focuses on an interactive user experience.

Its syntax is different from Bash, so Bash scripts should not automatically be assumed to work in Fish.

## 5.6 Why `/bin/sh` May Not Be Bash

On Ubuntu, `/bin/sh` is commonly linked to Dash.

Dash is a lightweight POSIX-compatible shell.

You can inspect it with:

```bash
ls -l /bin/sh
```

This is important because Bash-specific syntax may fail when a script runs using `/bin/sh`.

## 5.7 Example: Bash-Specific Array

```bash
#!/usr/bin/env bash

servers=("web01" "web02" "db01")

echo "${servers[0]}"
```

Expected output:

```text
web01
```

This example uses Bash array syntax.

It should not be treated as a portable POSIX shell script.

## 5.8 Example: POSIX-Compatible Script

```sh
#!/bin/sh

name="Hredoy"

echo "Hello, $name"
```

This simple script uses syntax supported by POSIX-compatible shells.

## 5.9 Inspect Available Shells

```bash
cat /etc/shells
```

Check the availability of common shells:

```bash
command -v bash
command -v sh
command -v zsh
command -v fish
command -v ksh
```

If a command is not found, that shell may not be installed or available through `PATH`.

## 5.10 Choosing the Correct Shell

Use Bash when:

- You need Bash-specific scripting features.
- Your automation targets Bash environments.
- Your scripts use Bash arrays or other Bash-specific syntax.

Use `/bin/sh` when:

- You want POSIX-compatible shell scripts.
- You do not need Bash-specific features.
- Portability is an important requirement.

Always choose the interpreter that matches your script.

## 5.11 Why This Matters in DevOps

Automation scripts may run on different Linux distributions, CI/CD runners, and production servers.

Choosing the wrong interpreter can cause deployment failures.

For example, a Bash array may work on your EC2 server but fail if a script is executed through Dash.

## 5.12 Common Mistakes

- Assuming `/bin/sh` is always Bash.
- Using Bash-specific syntax in a POSIX script.
- Assuming every server has Zsh or Fish installed.
- Changing a server's default shell without understanding the consequences.

## 5.13 Knowledge Check

1. Name five common shells.
2. What is the main difference between Bash and Zsh?
3. What is Dash?
4. Why can Bash arrays fail under `/bin/sh`?
5. How do you check which shell `/bin/sh` points to?
6. When should you use `#!/bin/sh`?
7. When should you use `#!/usr/bin/env bash`?

## 5.14 Practical Exercise

Run:

```bash
echo "===== SHELL AVAILABILITY ====="

for shell in bash sh zsh fish ksh
do
    printf "%-8s " "$shell"
    command -v "$shell" || echo "Not installed or not in PATH"
done

echo
echo "===== /bin/sh INFORMATION ====="
ls -l /bin/sh

echo
echo "===== CONFIGURED SHELLS ====="
cat /etc/shells
```

Record which shells are available on your EC2 instance.

**Learning Status:** Shell availability and `/etc/shells` were previously inspected. Review the comparison and practical implications.

---

# 6. Topic 05 — Linux Command Execution

## 6.1 Overview

Linux provides many commands for managing files, processes, users, and system resources.

But how does Linux know which command to execute?

The Shell plays an important role in this process.

## 6.2 Definition

**Command execution is the process through which a Shell interprets a command and runs the requested program or operation.**

For example:

```bash
date
```

The Shell identifies the command and executes the appropriate program.

## 6.3 Types of Commands

There are several common command types.

### 1. Alias

An alias is a shortcut for another command.

Example:

```bash
alias ll='ls -lah'
```

Now:

```bash
ll
```

runs the equivalent command.

### 2. Shell Built-in

A built-in command is implemented directly inside the Shell.

Examples:

```bash
cd
export
pwd
```

### 3. External Command

An external command is a separate executable program.

Examples:

```bash
ls
cat
grep
mkdir
```

### 4. Function

A shell function is a reusable group of shell commands.

Example:

```bash
hello() {
    echo "Hello from a function"
}
```

Run it:

```bash
hello
```

## 6.4 How Does Bash Find a Command?

When you execute a command, Bash checks how that command should be handled.

For example:

```bash
ls
```

Bash identifies whether the command is an alias, function, built-in, or external executable.

For external commands, Bash searches directories listed in the `PATH` environment variable.

### Command Lookup Order

When Bash processes a command, it follows a command lookup process.

Alias expansion happens while Bash parses a command line.

After parsing, Bash generally checks for commands in this order:

1. Shell functions.
2. Shell built-in commands.
3. Commands stored in Bash's command hash table.
4. External commands found by searching directories in `PATH`.

Bash searches the directories in `PATH` from left to right when it needs to locate an external command.

Useful commands:

```bash
type -a ls
command -V ls
hash -l
hash -r
```
## 6.5 What is PATH?

`PATH` is an environment variable containing directories where the Shell looks for executable commands.

Example:

```bash
echo "$PATH"
```

A simplified example:

```text
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
```

The actual value depends on the system.

Each directory is separated by a colon (`:`).

## 6.6 Find a Command

Use:

```bash
command -v ls
```

Example:

```text
/usr/bin/ls
```

Another useful command is:

```bash
type ls
```

It tells you how Bash interprets the command.

### Bash Expansion Order

Before executing a command, Bash performs several expansion steps.

The main order is:

1. Brace expansion: `file{1,2}.txt`
2. Tilde expansion: `~`
3. Parameter and variable expansion: `$HOME`
4. Arithmetic expansion: `$((5 + 3))`
5. Command substitution: `$(date)`
6. Process substitution, where applicable.
7. Word splitting.
8. Filename expansion (globbing): `*.log`
9. Quote removal.

Parameter, arithmetic, and command substitutions are processed from left to right. Process substitution is performed at the same time as these expansions.

Example:

```bash
echo file{1,2}.txt
echo "Hello, $USER"
echo "Today is $(date +%A)"
echo $((6 * 7))
```

## 6.7 Exit Status

Every command returns an exit status.

Generally:

- `0` means success.
- A non-zero value indicates an error or another unsuccessful condition.

Example:

```bash
true
echo "$?"
```

Output:

```text
0
```

Now:

```bash
false
echo "$?"
```

Output:

```text
1
```

`$?` stores the exit status of the most recently executed command.

Important: It must be checked immediately if you want the status of a particular command.

## 6.8 Command Chaining

The Shell supports combining commands.

### Semicolon

Runs commands sequentially.

```bash
echo "First"
echo "Second"
```

Or:

```bash
echo "First"; echo "Second"
```

### AND operator

```bash
mkdir test-directory && echo "Directory created"
```

The second command runs only if the first command succeeds.

### OR operator

```bash
mkdir test-directory || echo "Directory creation failed"
```

The second command runs if the first command fails.

## 6.9 Pipes

A pipe (`|`) sends the output of one command to another command.

Example:

```bash
ls -l | grep ".txt"
```

Here:

1. `ls -l` lists files.
2. `grep ".txt"` filters the output.
3. The Terminal displays matching lines.

## 6.10 Input and Output Redirection

### Output redirection

```bash
echo "Hello Linux" > output.txt
```

Creates or overwrites `output.txt`.

### Append output

```bash
echo "Second line" >> output.txt
```

Adds content to the end of the file.

### Read input from a file

```bash
cat < output.txt
```

## 6.11 Important Standard Streams

Linux commands commonly use three standard streams.

| Stream | Number | Purpose |
|---|---:|---|
| stdin | 0 | Standard input |
| stdout | 1 | Standard output |
| stderr | 2 | Standard error |

Example:

```bash
ls existing-file missing-file
```

The command may produce both normal output and an error message.

Redirect errors:

```bash
ls missing-file 2> error.log
```

## 6.12 Why This Matters in DevOps

Understanding command execution is essential for:

- Writing reliable scripts.
- Handling command failures.
- Managing application output.
- Collecting logs.
- Building CI/CD pipelines.
- Troubleshooting automation.

A deployment script should not simply execute commands; it should also handle failures correctly.

## 6.13 Common Mistakes

- Assuming every command is an external executable.
- Confusing `>` with `>>`.
- Forgetting to check `$?`.
- Assuming a pipeline always returns the status of every command.
- Ignoring error output.

## 6.14 Knowledge Check

1. What is command execution?
2. What are the four common command types?
3. What is an environment variable?
4. What is `PATH`?
5. What does `command -v` do?
6. What does exit status `0` mean?
7. What does `$?` represent?
8. What is a pipe?
9. Explain the difference between `>` and `>>`.
10. What are stdin, stdout, and stderr?

## 6.15 Practical Exercise

Run:

```bash
echo "===== COMMAND TYPE ====="
type cd
type ls
type echo

echo
echo "===== COMMAND LOCATION ====="
command -v bash
command -v ls
command -v git

echo
echo "===== PATH ====="
echo "$PATH"

echo
echo "===== SUCCESS STATUS ====="
true
echo "$?"

echo
echo "===== FAILURE STATUS ====="
false
echo "$?"
```

Observe the results and explain the differences.

**Learning Status:** Basic command execution and Git availability were previously inspected. The full command-type and exit-status exercise remains part of practical revision.

---

# 7. Topic 06 — Shell Environment

## 7.1 Overview

When a Shell starts, it receives information about the user and the system.

This information is available through variables.

Examples include:

- Current username.
- Home directory.
- Current working directory.
- Executable search paths.
- Terminal configuration.

This information is called the shell environment.

## 7.2 Definition

**The shell environment is the collection of variables and settings that influence how a shell and its child processes operate.**

## 7.3 What is a Variable?

A variable stores a value.

Example:

```bash
name="Hredoy"
```

Display the value:

```bash
echo "$name"
```

Output:

```text
Hredoy
```

Important: There must not be spaces around the `=` sign when assigning a Bash variable.

Correct:

```bash
name="Hredoy"
```

Incorrect:

```bash
name = "Hredoy"
```

## 7.4 Shell Variables vs Environment Variables

These are related but different.

### Shell Variable

A shell variable exists in the current shell.

Example:

```bash
project="Bash-Git-Toolkit"
```

### Environment Variable

An environment variable is exported so that child processes can inherit it.

Example:

```bash
export project="Bash-Git-Toolkit"
```

The `export` command makes the variable available in the environment of subsequently started child processes.

## 7.5 Understanding Child Processes

Consider:

```bash
export PROJECT_NAME="DevOps Toolkit"

bash -c 'echo "$PROJECT_NAME"'
```

Expected output:

```text
DevOps Toolkit
```

The new Bash process inherits the exported environment variable.

Compare this with an unexported variable:

```bash
LOCAL_NAME="Test"

bash -c 'echo "${LOCAL_NAME-unavailable}"'
```

Expected output:

```text
unavailable
```

The child process does not automatically inherit ordinary, unexported shell variables.

Run these examples in a clean context when testing inheritance. A previously exported variable can affect later results.

## 7.6 Important Environment Variables

| Variable | Purpose |
|---|---|
| `$HOME` | User's home directory |
| `$USER` | Current username in the environment |
| `$SHELL` | Configured login shell |
| `$PATH` | Executable search directories |
| `$PWD` | Current working directory |
| `$LANG` | Language and locale settings |
| `$TERM` | Terminal type |

Inspect them:

```bash
echo "$HOME"
echo "$USER"
echo "$SHELL"
echo "$PATH"
echo "$PWD"
echo "$LANG"
echo "$TERM"
```

## 7.7 Inspect the Environment

Use:

```bash
printenv
```

This displays exported environment variables.

You can also use:

```bash
env
```

To inspect shell variables, use:

```bash
set
```

Note that `set` can display a large amount of information.

## 7.8 Temporary Environment Variables

You can set an environment variable for a single command:

```bash
APP_ENV=development bash -c 'echo "$APP_ENV"'
```

Expected output:

```text
development
```

This assignment applies to that command's environment.

## 7.9 Shell Startup Files

Bash uses startup files to configure shell sessions.

Common files include:

| File | General Purpose |
|---|---|
| `~/.bashrc` | Interactive non-login Bash configuration |
| `~/.bash_profile` | Login Bash configuration, if present |
| `~/.profile` | General login configuration |
| `/etc/profile` | System-wide login configuration |

The exact startup behavior depends on whether Bash is interactive, login, or non-interactive.

Do not edit startup files without understanding which sessions they affect.

## 7.10 What is Sourcing?

Sourcing executes a file in the current shell.

Example:

```bash
source config.sh
```

Short form:

```bash
. config.sh
```

Unlike running a script as a separate process, sourcing can modify the current shell's variables and settings.

This is useful for loading environment configuration.

## 7.11 Why This Matters in DevOps

Environment variables are commonly used to configure applications.

Examples:

- Application environment.
- Port numbers.
- Database connection settings.
- Deployment configuration.
- Tool locations.

Sensitive values such as passwords and API keys must be handled securely. Do not commit secrets to Git repositories.

## 7.12 Common Mistakes

- Forgetting `export`.
- Adding spaces around variable assignments.
- Confusing shell variables with environment variables.
- Assuming every child process inherits every shell variable.
- Exposing secrets in terminal output or Git repositories.
- Editing startup files without making a backup.

## 7.13 Knowledge Check

1. What is a shell environment?
2. What is a variable?
3. What is the difference between a shell variable and an environment variable?
4. What does `export` do?
5. What is `$PATH`?
6. What is `$HOME`?
7. What does `printenv` display?
8. What is the purpose of `.bashrc`?
9. What is sourcing?
10. Why are environment variables useful in DevOps?

## 7.14 Practical Exercise

Run:

```bash
echo "===== USER INFORMATION ====="
echo "USER: $USER"
echo "HOME: $HOME"
echo "SHELL: $SHELL"

echo
echo "===== CURRENT DIRECTORY ====="
echo "$PWD"

echo
echo "===== TERMINAL AND LOCALE ====="
echo "TERM: $TERM"
echo "LANG: $LANG"

echo
echo "===== PATH ====="
echo "$PATH"

echo
echo "===== ENVIRONMENT VARIABLE TEST ====="
export PROJECT_NAME="Bash-Git-DevOps-Toolkit"
bash -c 'echo "Child process: $PROJECT_NAME"'

echo
echo "===== ENVIRONMENT INSPECTION ====="
printenv PROJECT_NAME
```

Expected final values:

```text
Child process: Bash-Git-DevOps-Toolkit
Bash-Git-DevOps-Toolkit
```

**Learning Status:** `$HOME`, `$USER`, `$PATH`, `$PWD`, variable assignment, `export`, child-shell inheritance, and environment inspection were previously practiced on EC2.

---

# 8. Topic 07 — Bash Script Structure

## 8.1 Overview

A Bash script is a text file containing commands that Bash can execute.

Instead of typing the same commands repeatedly, we can save them in a script and execute them when needed.

This is one of the foundations of Linux automation.

## 8.2 Definition

**A Bash script is a text file containing Bash commands and instructions that are executed by the Bash interpreter.**

Example:

```bash
#!/usr/bin/env bash

echo "Hello from Bash Script"
```

## 8.3 Basic Script Structure

A well-organized script commonly contains:

1. Shebang.
2. Comments.
3. Variables.
4. Functions, when needed.
5. Main execution logic.
6. Exit status.

Example:

```bash
#!/usr/bin/env bash

# Script information
# Purpose: Display a welcome message

NAME="Hredoy"

main() {
    echo "Hello, $NAME"
}

main
```

## 8.4 Shebang

The first line identifies the interpreter.

```bash
#!/usr/bin/env bash
```

It tells the operating system to use Bash when the script is executed directly.

The shebang is explained in detail in Topic 08.

## 8.5 Comments

Comments explain the purpose of the script or specific commands.

Single-line comment:

```bash
# This is a comment
```

Comments are ignored as instructions by Bash.

Use comments to explain why something is being done, especially when the reason is not obvious.

## 8.6 Variables

Variables store information.

Example:

```bash
APP_NAME="TaskFlow"
PORT=8080

echo "$APP_NAME"
echo "$PORT"
```

Use descriptive variable names.

## 8.7 Functions

Functions help organize reusable operations.

Example:

```bash
show_message() {
    echo "Starting application"
}

show_message
```

A function can be called multiple times.

## 8.8 Main Function

Larger scripts often use a main function to make the execution flow clear.

Example:

```bash
#!/usr/bin/env bash

main() {
    echo "Script started"
    echo "Performing task"
    echo "Script completed"
}

main
```

### Source-Safe Main Guard

A Bash script can be executed directly or sourced by another shell script.

A main guard ensures that the main function runs only when the file is executed directly.

Example:

```bash
#!/usr/bin/env bash

show_message() {
    echo "Reusable function executed"
}

main() {
    show_message
    echo "Main function executed"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi

**Important:** This main guard prevents `main()` from being called automatically when the file is sourced. It does not prevent other top-level commands from executing. Keep application logic inside functions and call `main` only through this guard.
```

**How It Works:**

- `${BASH_SOURCE[0]}` identifies the current script file.
- `$0` identifies the name of the current shell or executed script.
- When the file is executed directly, these values normally match.
- When the file is sourced, they normally differ.
- `main "$@"` calls the main function and passes the original arguments.

**Why Is It Useful?**

- Allows functions to be reused by other scripts.
- Prevents the main execution logic from running automatically when sourced.
- Helps organize larger automation scripts.

## 8.9 Strict-Mode Options

A common Bash scripting pattern is:

```bash
set -Eeuo pipefail
```

These options change how Bash handles certain errors.

| Option | Purpose |
|---|---|
| `-e` | Exits in many situations when a command fails |
| `-E` | Allows ERR traps to be inherited in more contexts |
| `-u` | Treats unset variables as errors in many expansions |
| `-o pipefail` | Makes a pipeline fail when a command in it fails |

Important: These options do not make every script automatically safe.

`set -e` has exceptions, especially in conditions, functions, and pipelines. Scripts still require careful error handling and testing.

Do not add strict mode blindly to scripts that have not been tested with it.

## 8.10 Example: Basic System Information Script

```bash
#!/usr/bin/env bash

# Purpose: Display basic system information

show_system_info() {
    echo "===== SYSTEM INFORMATION ====="
    echo "User: $(whoami)"
    echo "Hostname: $(hostname)"
    echo "Current Directory: $(pwd)"
    echo "Date: $(date)"
}

main() {
    show_system_info
}

main
```

## 8.11 Why This Matters in DevOps

Bash scripts can automate:

- System health checks.
- Backup tasks.
- Deployment procedures.
- Log maintenance.
- Application checks.
- Repetitive server administration.

Organized scripts are easier to understand, maintain, and troubleshoot.

## 8.12 Common Mistakes

- Forgetting the shebang.
- Using unclear variable names.
- Writing overly complicated scripts.
- Ignoring command failures.
- Using strict mode without understanding its behavior.
- Writing scripts without comments or usage information.

## 8.13 Knowledge Check

1. What is a Bash script?
2. What is the purpose of the shebang?
3. What are comments?
4. Why do we use variables?
5. What is a Bash function?
6. Why might we use a `main` function?
7. What does `set -u` do?
8. What does `pipefail` do?
9. Why is script organization important?

## 8.14 Practical Exercise

Create a basic script:

```bash
cd ~/bash-script

mkdir -p labs/module-01-shell-fundamentals

nano labs/module-01-shell-fundamentals/system-info.sh
```

Add:

```bash
#!/usr/bin/env bash

# Purpose: Display basic system information

main() {
    echo "===== SYSTEM INFORMATION ====="
    echo "User: $(whoami)"
    echo "Hostname: $(hostname)"
    echo "Directory: $(pwd)"
    echo "Date: $(date)"
}

main
```

Save the file.

Do not assume the exercise is complete until you have executed and verified it.

**Learning Status:** The script structure has been introduced. This practical script should be completed during the hands-on phase.

---

# 9. Topic 08 — Shebang

## 9.1 Overview

A shebang is a special line at the beginning of an executable script.

It tells the operating system which interpreter should execute the script.

## 9.2 Definition

A **shebang** is a character sequence beginning with `#!` that identifies the interpreter used to execute a script directly.

Example:

```bash
#!/usr/bin/env bash
```

## 9.3 Why Do We Need a Shebang?

Consider a script containing:

```bash
echo "Hello"
```

If we execute it directly, the operating system needs to know which interpreter should handle the file.

The shebang provides this information.

## 9.4 Common Shebangs

| Shebang | Interpreter |
|---|---|
| `#!/bin/bash` | Bash at `/bin/bash` |
| `#!/usr/bin/env bash` | Bash located through `PATH` |
| `#!/bin/sh` | Shell at `/bin/sh` |
| `#!/usr/bin/python3` | Python 3 |
| `#!/usr/bin/env python3` | Python 3 located through `PATH` |

## 9.5 `/bin/bash` vs `/usr/bin/env bash`

### Direct interpreter path

```bash
#!/bin/bash
```

This uses Bash at a specific location.

### Environment-based lookup

```bash
#!/usr/bin/env bash
```

This uses `env` to locate Bash through the current `PATH`.

The second approach can be more flexible across systems where Bash is installed in different locations.

However, the executable path and environment must still be available.

## 9.6 How the Shebang Works

When a script is executed directly:

```bash
./script.sh
```

the operating system checks the shebang and starts the specified interpreter.

Simplified flow:

```text
Execute Script
      |
      v
Read Shebang
      |
      v
Find Interpreter
      |
      v
Start Interpreter
      |
      v
Execute Script
```

## 9.7 What Happens Without a Shebang?

A script without a shebang may still run when explicitly passed to an interpreter.

Example:

```bash
bash script.sh
```

Here, Bash is explicitly selected.

However, direct execution may fail or behave differently depending on how the script is launched.

For reliable executable scripts, use the appropriate shebang.

## 9.8 Practical Example

Create a script:

```bash
nano hello.sh
```

Add:

```bash
#!/usr/bin/env bash

echo "Hello from the shebang example"
```

Save it.

Execute using Bash:

```bash
bash hello.sh
```

Later, after giving it executable permission, execute it directly:

```bash
./hello.sh
```

## 9.9 Check the Interpreter

```bash
command -v bash
```

Inspect the first line:

```bash
head -n 1 hello.sh
```

## 9.10 Common Mistakes

- Typing incorrect characters in the shebang.
- Putting spaces before `#!`.
- Using a nonexistent interpreter path.
- Using Bash-specific syntax with `#!/bin/sh`.
- Saving a script with Windows line endings that cause interpreter errors.

## 9.11 Windows Line Endings

Windows commonly uses CRLF line endings, while Linux scripts generally use LF.

A script transferred from Windows may contain unwanted carriage-return characters.

Check the file:

```bash
file hello.sh
```

If required, convert it:

```bash
sed -i 's/\r$//' hello.sh
```

This removes a trailing carriage return from each line.

## 9.12 Why This Matters in DevOps

Incorrect interpreter configuration can break:

- Deployment scripts.
- CI/CD jobs.
- Server automation.
- Scheduled scripts.
- Container entrypoint scripts.

The correct shebang helps ensure that scripts use the intended interpreter.

## 9.13 Knowledge Check

1. What is a shebang?
2. What does `#!` represent?
3. Why do scripts need an interpreter?
4. What is the difference between `/bin/bash` and `/usr/bin/env bash`?
5. Can a script run without a shebang?
6. What is CRLF?
7. Why can Windows line endings cause problems in Linux scripts?

## 9.14 Practical Exercise

Create and inspect a script:

```bash
cd ~/bash-script

nano shebang-test.sh
```

Content:

```bash
#!/usr/bin/env bash

echo "Shebang is working"
```

Then run:

```bash
head -n 1 shebang-test.sh
command -v bash
file shebang-test.sh
bash shebang-test.sh
```

**Learning Status:** Shebang concepts and practical examples are included in this module. Complete the exercise to verify your understanding.

---

# 10. Topic 09 — Creating and Executing Bash Scripts

## 10.1 Overview

Bash scripts allow us to save commands in files and execute them whenever required.

This reduces repetitive work and helps automate system administration tasks.

## 10.2 Definition

**Creating and executing a Bash script means writing Bash commands in a file and running that file using the Bash interpreter or direct executable execution.**

## 10.3 Creating a Script

Use a text editor such as Nano:

```bash
nano hello.sh
```

Add:

```bash
#!/usr/bin/env bash

echo "Hello from Bash"
```

Save the file.

## 10.4 Method 1: Execute Using Bash

```bash
bash hello.sh
```

Bash reads and executes the script.

The script does not need executable permission for this method.

## 10.5 Method 2: Execute Using the Relative Path

First, grant executable permission:

```bash
chmod +x hello.sh
```

Then:

```bash
./hello.sh
```

The `./` means the file is in the current directory.

## 10.6 Method 3: Execute Using the Absolute Path

Example:

```bash
/home/ubuntu/bash-script/hello.sh
```

This requires the file to be executable and its interpreter to be available.

## 10.7 Method 4: Source a Script

```bash
source hello.sh
```

Or:

```bash
. hello.sh
```

This runs the script in the current shell rather than creating a separate Bash process.

This is useful for loading environment variables and shell configuration.

Be careful: sourcing a script can change the current shell's variables, directory, options, and other settings.

## 10.8 Running a Script vs Sourcing It

| Running as a separate process | Sourcing |
|---|---|
| Starts another process | Uses the current shell |
| Changes usually stay in the child process | Changes can affect the current shell |
| Example: `bash script.sh` | Example: `source script.sh` |

## 10.9 Positional Parameters

A Bash script can receive arguments.

Example:

```bash
#!/usr/bin/env bash

echo "First argument: $1"
echo "Second argument: $2"
echo "All arguments: $@"
echo "Number of arguments: $#"
```

Save as `arguments.sh`.

Execute:

```bash
bash arguments.sh Linux DevOps
```

Expected output:

```text
First argument: Linux
Second argument: DevOps
All arguments: Linux DevOps
Number of arguments: 2
```

Important special parameters:

| Parameter | Meaning |
|---|---|
| `$0` | Script name or invocation name |
| `$1`, `$2` | First and second positional arguments |
| `$@` | All positional arguments |
| `$#` | Number of positional arguments |
| `$?` | Previous command's exit status |

When handling arbitrary arguments, prefer `"$@"` to preserve arguments containing spaces.

## 10.10 Script Location and PATH

A script can be executed by specifying its path.

You can also place your own scripts in a directory included in `PATH`.

For example:

```bash
mkdir -p "$HOME/bin"
```

After configuring the directory in your shell startup configuration, commands in that directory can be invoked by name.

Do not add untrusted directories to `PATH`.

## 10.11 Why This Matters in DevOps

DevOps engineers use scripts to automate:

- Application deployment.
- Service restarts.
- System checks.
- Backups.
- Log management.
- CI/CD tasks.

A script can turn a long sequence of manual commands into a repeatable operation.

## 10.12 Common Mistakes

- Forgetting to save the script.
- Forgetting executable permissions when using `./script.sh`.
- Forgetting `./` for files in the current directory.
- Using the wrong interpreter.
- Confusing sourcing with normal execution.
- Forgetting to quote arguments that may contain spaces.

## 10.13 Knowledge Check

1. How do you create a Bash script?
2. How do you execute a script using Bash?
3. How do you execute a script directly?
4. Why do we use `chmod +x`?
5. What is the difference between `bash script.sh` and `source script.sh`?
6. What does `$1` represent?
7. What does `$@` represent?
8. What does `$#` represent?
9. What is the purpose of `PATH`?

## 10.14 Practical Exercise

Create:

```bash
cd ~/bash-script

mkdir -p labs/module-01-shell-fundamentals

nano labs/module-01-shell-fundamentals/hello-devops.sh
```

Content:

```bash
#!/usr/bin/env bash

echo "Welcome to the Bash and Git DevOps Automation Toolkit"
echo "Current User: $(whoami)"
echo "Current Directory: $(pwd)"
```

Execute it using:

```bash
bash labs/module-01-shell-fundamentals/hello-devops.sh
```

Then compare with direct execution after granting executable permission.

**Learning Status:** Practical script creation and execution must be verified during the hands-on phase.

---

# 11. Topic 10 — Executable Permissions

## 11.1 Overview

Linux uses permissions to control who can read, modify, and execute files.

These permissions are important for security and script execution.

## 11.2 Definition

**File permissions determine what actions a user or group can perform on a file or directory.**

Linux uses three main permission categories:

- Read (`r`)
- Write (`w`)
- Execute (`x`)

## 11.3 Understanding `ls -l`

Run:

```bash
ls -l
```

Example output:

```text
-rwxr-xr-x 1 ubuntu ubuntu 120 Nov 15 10:00 script.sh
```

The first section represents file type and permissions.

```text
-rwxr-xr-x
```

It can be understood as:

```text
- | rwx | r-x | r-x
    User  Group Others
```

## 11.4 Permission Types

| Permission | Symbol | Meaning for a File |
|---|---|---|
| Read | r | Read file content |
| Write | w | Modify file content |
| Execute | x | Execute the file as a program, subject to other requirements |

For directories, permissions have different meanings:

- Read: List directory entries.
- Write: Create, remove, or rename entries, subject to other permissions.
- Execute: Access or traverse the directory.

## 11.5 Permission Categories

Linux has three permission categories:

| Category | Meaning |
|---|---|
| User | File owner |
| Group | Members of the file's group |
| Others | Everyone else |

## 11.6 Numeric Permissions

Linux also represents permissions using numbers.

| Permission | Value |
|---|---:|
| Read | 4 |
| Write | 2 |
| Execute | 1 |

Add the values to calculate a permission number.

Examples:

| Permissions | Calculation | Number |
|---|---|---:|
| Read | 4 | 4 |
| Write | 2 | 2 |
| Execute | 1 | 1 |
| Read + Execute | 4 + 1 | 5 |
| Read + Write | 4 + 2 | 6 |
| Read + Write + Execute | 4 + 2 + 1 | 7 |

## 11.7 Understanding chmod

`chmod` changes file permissions.

Example:

```bash
chmod 755 script.sh
```

This sets:

- Owner: Read, write, execute.
- Group: Read, execute.
- Others: Read, execute.

Another example:

```bash
chmod 644 file.txt
```

This sets:

- Owner: Read and write.
- Group: Read.
- Others: Read.

## 11.8 Symbolic Permissions

Permissions can also be changed using symbols.

Example:

```bash
chmod +x script.sh
```

Adds executable permission according to the command's default affected classes and current `umask`.

More specific examples:

```bash
chmod u+x script.sh
chmod g+x script.sh
chmod o-x script.sh
```

Meaning:

- `u`: User/owner.
- `g`: Group.
- `o`: Others.

## 11.9 Understanding umask

`umask` controls which permission bits are removed when new files and directories are created.

Check it:

```bash
umask
```

A common value is:

```text
0022
```

The actual default permissions depend on the program creating the file and the system's configuration.

## 11.10 File Ownership

Linux files have an owner and group.

Check ownership:

```bash
ls -l script.sh
```

Change ownership with `chown` when authorized:

```bash
sudo chown ubuntu:ubuntu script.sh
```

Only use `sudo` when required and when you understand the consequences.

## 11.11 Special Permissions

Linux also has special permission bits:

- SUID.
- SGID.
- Sticky bit.

These affect execution or directory behavior.

They are advanced permission concepts and should be understood before changing them.

Do not modify special permission bits on system files without a specific administrative reason.

## 11.12 Git and Executable Permissions

Git tracks whether a regular file is executable.

This matters when committing Bash scripts.

For example:

```bash
git ls-files --stage
```

A tracked executable file commonly appears with mode:

```text
100755
```

A regular non-executable file commonly appears with mode:

```text
100644
```

### Mount Options and `noexec`

Linux filesystems can be mounted with options that control how files are accessed.

One important option is `noexec`.

A filesystem mounted with `noexec` prevents files on that filesystem from being directly executed through the normal kernel execution mechanism, even when their executable permission is set.

Inspect mount options for a path:

```bash
findmnt -T /tmp -o TARGET,OPTIONS
```

Look for `noexec` in the options.

**Important Distinction:**

```bash
./script.sh
```

This attempts to execute the file directly and may fail on a `noexec` filesystem.

```bash
bash script.sh
```

This normally works because Bash reads the script as input instead of asking the kernel to execute that file directly.

`noexec` is a security-hardening option sometimes used for temporary directories and data filesystems. Do not change mount options without understanding the security and operational impact.

## 11.13 Why This Matters in DevOps

Incorrect permissions can cause:

- Deployment failures.
- Script execution errors.
- Security vulnerabilities.
- Unauthorized file access.

Production scripts should have only the permissions they need.

## 11.14 Common Mistakes

- Using `chmod 777` without understanding the security impact.
- Forgetting executable permission.
- Confusing file and directory permissions.
- Changing ownership unnecessarily.
- Running permission commands with `sudo` without a reason.

## 11.15 Knowledge Check

1. What are Linux file permissions?
2. What does `r` mean?
3. What does `w` mean?
4. What does `x` mean?
5. What are user, group, and others?
6. What does `chmod` do?
7. What does `chmod 755` mean?
8. What does `chmod 644` mean?
9. What is `umask`?
10. Why should we avoid `chmod 777`?
11. How does Git track executable permissions?

## 11.16 Practical Exercise

Create a test file:

```bash
cd ~/bash-script

mkdir -p labs/module-01-shell-fundamentals

cd labs/module-01-shell-fundamentals

touch permission-test.sh

ls -l permission-test.sh
```

Change its permissions:

```bash
chmod 755 permission-test.sh

ls -l permission-test.sh
```

Inspect the result.

Then:

```bash
chmod 644 permission-test.sh

ls -l permission-test.sh
```

Compare both outputs.

**Learning Status:** Executable-permission practice must be completed and verified before marking this topic complete.

---

# 12. Topic 11 — Bash Script Debugging Fundamentals

## 12.1 Overview

Scripts may contain syntax errors, incorrect variable names, failed commands, or unexpected behavior.

Debugging helps us identify and fix these problems.

## 12.2 Definition

**Debugging is the process of finding, understanding, and correcting errors in a program or script.**

In Bash, debugging tools help us inspect script syntax and command execution.

## 12.3 Common Bash Errors

### Syntax Error

Example:

```bash
if [ "$USER" = "ubuntu" ]
    echo "Welcome"
fi
```

This example is missing `then`.

Correct version:

```bash
if [ "$USER" = "ubuntu" ]; then
    echo "Welcome"
fi
```

### Variable Error

Example:

```bash
echo "$USER_NAME"
```

If the variable is not defined, it may produce an empty value unless stricter handling is enabled.

### Command Error

Example:

```bash
systemctl status nonexistent-service
```

The command may fail because the requested service does not exist.

## 12.4 Main Debugging Tools

### 1. bash -n

Checks a script for syntax errors without executing its commands.

```bash
bash -n script.sh
```

Important: It does not detect every possible runtime or logical error.

### 2. bash -x

Displays commands as Bash executes them.

```bash
bash -x script.sh
```

This is useful for understanding execution flow.

### 3. set -x

Enables execution tracing inside a script.

```bash
set -x

echo "Debugging enabled"

set +x
```

`set +x` disables tracing.

### 4. set -e

Enables a behavior where Bash exits in many situations when a command fails.

```bash
set -e
```

It has exceptions, so it should not replace proper error handling.

### 5. set -u

Treats certain uses of unset variables as errors.

```bash
set -u
```

### 6. pipefail

Makes a pipeline return a failure status if a command within the pipeline fails.

```bash
set -o pipefail
```

## 12.5 Debugging with bash -n

Create a file containing a syntax error.

Example:

```bash
#!/usr/bin/env bash

echo "Starting"

if [ "$USER" = "ubuntu" ]; then
    echo "Welcome"
fi
```

Run:

```bash
bash -n script.sh
```

If the syntax is valid, Bash normally produces no output and returns success.

Check:

```bash
echo "$?"
```

## 12.6 Debugging with bash -x

Run:

```bash
bash -x script.sh
```

Bash displays execution traces, usually prefixed by `+`.

This helps identify which commands were executed.

## 12.7 Understanding PS4

`PS4` controls the prefix used by Bash when displaying execution traces.

Example:

```bash
export PS4='+ ${BASH_SOURCE[0]}:${LINENO}: '
bash -x script.sh
```

This can make traces easier to understand by showing source file and line information.

## 12.8 Useful Special Variables

| Variable | Meaning |
|---|---|
| `$?` | Previous command's exit status |
| `$#` | Number of positional arguments |
| `$@` | All positional arguments |
| `$0` | Script name or invocation name |
| `$LINENO` | Current line number in the script |
| `${BASH_SOURCE[0]}` | Current script source path in common script contexts |

## 12.9 Redirecting Debug Output

Debug traces can be redirected.

Example:

```bash
bash -x script.sh 2> debug.log
```

This sends standard error, including typical Bash trace output, to `debug.log`.

Be careful: Debug logs can contain sensitive information if scripts print secrets or process sensitive arguments.

## 12.10 A Repeatable Debugging Method

When a Bash script fails:

1. Read the error message.
2. Identify the script and line number.
3. Check the script syntax using `bash -n`.
4. Execute it with `bash -x`.
5. Inspect variable values.
6. Check command exit statuses.
7. Correct the issue.
8. Execute the script again.
9. Verify the expected result.

## 12.11 Why This Matters in DevOps

A broken automation script can interrupt a deployment or maintenance operation.

Debugging skills help engineers:

- Identify failed commands.
- Understand deployment failures.
- Diagnose automation problems.
- Reduce downtime.
- Improve script reliability.

## 12.12 Common Mistakes

- Assuming `bash -n` checks runtime behavior.
- Ignoring exit statuses.
- Enabling tracing without considering sensitive information.
- Assuming `set -e` handles every error.
- Changing several things at once while debugging.

## 12.13 Knowledge Check

1. What is debugging?
2. What does `bash -n` do?
3. What does `bash -x` do?
4. What is the difference between syntax errors and runtime errors?
5. What does `set -x` do?
6. How do you disable tracing?
7. What does `set -u` do?
8. What is the purpose of `pipefail`?
9. What is `PS4`?
10. Why should debug logs be handled carefully?

## 12.14 Practical Exercise

Create a test script:

```bash
cd ~/bash-script

mkdir -p labs/module-01-shell-fundamentals

nano labs/module-01-shell-fundamentals/debug-test.sh
```

Add:

```bash
#!/usr/bin/env bash

echo "Starting debug test"

NAME="DevOps"

echo "Project: $NAME"

echo "Debug test completed"
```

Run a syntax check:

```bash
bash -n labs/module-01-shell-fundamentals/debug-test.sh
```

Run with debugging:

```bash
bash -x labs/module-01-shell-fundamentals/debug-test.sh
```

Compare the normal output and the debug trace.

**Learning Status:** Debugging concepts are covered. Complete the practical exercise before marking the topic complete.

---

# 13. Module 01 Final Review

## 13.1 Essential Commands Reference

| Command | Purpose |
|---|---|
| `pwd` | Display current directory |
| `whoami` | Display current username |
| `ls -la` | List files, including hidden files |
| `echo` | Display text or variable values |
| `bash --version` | Display Bash version |
| `command -v bash` | Locate Bash |
| `cat /etc/shells` | Display configured valid login shells |
| `printenv` | Display exported environment variables |
| `env` | Display environment information |
| `export` | Export variables |
| `type` | Identify how Bash interprets a command |
| `chmod` | Change file permissions |
| `ls -l` | Display file permissions and ownership |
| `bash script.sh` | Execute a script using Bash |
| `source script.sh` | Execute a script in the current shell |
| `bash -n script.sh` | Check script syntax |
| `bash -x script.sh` | Execute with debugging trace |
| `echo "$?"` | Display the previous command's exit status |

## 13.2 Important Concepts to Remember

1. A Shell interprets commands.
2. A Terminal provides an interface for interacting with a Shell.
3. Bash is a widely used Linux shell and scripting language.
4. Different shells can have different syntax and features.
5. `PATH` helps the Shell locate external commands.
6. Exit status `0` generally indicates success.
7. Environment variables can be inherited by child processes.
8. A shebang identifies the interpreter for direct script execution.
9. `chmod +x` adds executable permission.
10. `bash -n` checks syntax.
11. `bash -x` displays execution traces.

## 13.3 Final Assessment Questions

Answer these questions without looking at the documentation.

1. Define a Shell.
2. Define Bash.
3. Explain Shell vs Terminal.
4. Name five common Linux shells.
5. Explain the difference between Bash and `/bin/sh`.
6. What is command execution?
7. Explain `PATH`.
8. What is an exit status?
9. Explain shell variables and environment variables.
10. What does `export` do?
11. Explain the purpose of a shebang.
12. What is a Bash script?
13. Explain the difference between running and sourcing a script.
14. What are positional parameters?
15. Explain Linux file permissions.
16. What does `chmod 755` mean?
17. What is `umask`?
18. Explain `bash -n`.
19. Explain `bash -x`.
20. Why is Bash useful in DevOps automation?

## 13.4 Final Practical Assessment

Complete these tasks on your Ubuntu EC2 instance:

- [ ] Identify the current user.
- [ ] Identify the current working directory.
- [ ] Inspect the current shell and login shell.
- [ ] Check the Bash version.
- [ ] Inspect available shells.
- [ ] Inspect important environment variables.
- [ ] Create and export a variable.
- [ ] Verify environment inheritance in a child shell.
- [ ] Identify command types using `type`.
- [ ] Locate commands using `command -v`.
- [ ] Check command exit statuses.
- [ ] Create a Bash script.
- [ ] Execute the script using Bash.
- [ ] Add executable permission.
- [ ] Execute the script directly.
- [ ] Run a syntax check.
- [ ] Run the script with debugging enabled.

## 13.5 Completion Criteria

Module 01 is complete when:

1. All 11 topics have been studied.
2. The learner can explain the important concepts.
3. The required practical exercises have been completed.
4. The final practical assessment has been verified.
5. The learner can troubleshoot basic Bash script problems.

Do not mark the module complete based only on reading the documentation.

---

# 14. Next Module Preview

After completing Shell and Bash Fundamentals, the next module will focus on practical Bash scripting and automation.

The knowledge from this module will be used to create more useful automation scripts and build a foundation for real-world DevOps tasks.

**End of Module 01 — Shell & Bash Fundamentals**
