# 📘 Bash Intermediate Tutorial

## 🎯 Prerequisites

Before starting this tutorial, make sure you're comfortable with:

- Basic Bash commands (`ls`, `cd`, `cp`, `mv`, `grep`, `cat`, etc.)
- Variables and simple command substitution
- Writing and running basic scripts (`#!/bin/bash`, shebang)
- Input/output redirection (`>`, `<`, `|`)

---

## 🚀 Table of Contents

1. [Conditionals (if/elif/else)](#1-conditionals-ifelse)
2. [Loops](#2-loops)
3. [Functions](#3-functions)
4. [Command-Line Arguments](#4-command-line-arguments)
5. [String Manipulation](#5-string-manipulation)
6. [Arrays](#6-arrays)
7. [Error Handling](#7-error-handling)
8. [File and Directory Operations](#8-file-and-directory-operations)
9. [Process Management](#9-process-management)
10. [Debugging and Scripting Best Practices](#10-debugging-and-scripting-best-practices)

---

## 1. Conditionals (`if`/`elif`/`else`)

### Syntax:

```bash
if [ condition ]; then
    # code
elif [ another_condition ]; then
    # code
else
    # code
fi
```

> ⚠️ Always leave spaces around `[` and `]`.

### Example:

```bash
#!/bin/bash

read -p "Enter a number: " num

if [ "$num" -gt 0 ]; then
    echo "Positive"
elif [ "$num" -lt 0 ]; then
    echo "Negative"
else
    echo "Zero"
fi
```

### Common Test Operators:

| Operator | Meaning |
|----------|-----------------------------|
| `-eq` | Equal |
| `-ne` | Not equal |
| `-gt` | Greater than |
| `-lt` | Less than |
| `-ge` | Greater than or equal |
| `-le` | Less than or equal |
| `-z` | String is empty |
| `-n` | String is not empty |
| `=` | String equality |
| `!=` | String inequality |

---

## 2. Loops

### For Loop:

```bash
for i in 1 2 3 4 5; do
    echo "Number: $i"
done
```

```bash
for file in *.txt; do
    echo "Found file: $file"
done
```

### While Loop:

```bash
count=1
while [ $count -le 5 ]; do
    echo "Count: $count"
    ((count++))
done
```

### Until Loop:

```bash
i=0
until [ $i -ge 5 ]; do
    echo "Until loop: $i"
    ((i++))
done
```

---

## 3. Functions

```bash
greet() {
    echo "Hello, $1!"
}

greet "Alice"
greet "Bob"
```

You can return values using `echo` and capture them with command substitution:

```bash
add() {
    echo $(($1 + $2))
}

sum=$(add 5 3)
echo "Sum: $sum"
```

---

## 4. Command-Line Arguments

Access arguments with `$1`, `$2`, ..., `$9`, or `$@` for all.

```bash
#!/bin/bash

echo "First arg: $1"
echo "All args: $@"
echo "Total args: $#"
```

Use shift to move through arguments:

```bash
while [ "$#" -gt 0 ]; do
    echo "Argument: $1"
    shift
done
```

---

## 5. String Manipulation

```bash
str="Hello World"

echo ${str:0:5} # Hello
echo ${str/World/Bash} # Hello Bash
echo ${#str} # Length: 11
echo ${str,,} # hello world (lowercase)
echo ${str^^} # HELLO WORLD (uppercase)
```

---

## 6. Arrays

### Declare an array:

```bash
arr=("apple" "banana" "cherry")
```

### Access elements:

```bash
echo ${arr[0]} # apple
echo ${arr[-1]} # cherry
```

### Loop through array:

```bash
for fruit in "${arr[@]}"; do
    echo "Fruit: $fruit"
done
```

### Add element:

```bash
arr+=("date")
```

---

## 7. Error Handling

### Check if a command succeeded:

```bash
if grep -q "pattern" file.txt; then
    echo "Found!"
else
    echo "Not found!"
fi
```

### Use `set -e`, `set -u`, `set -o pipefail`:

```bash
#!/bin/bash
set -euo pipefail

# script exits on error, undefined variable, and pipeline failure
```

### Custom error function:

```bash
error_exit() {
    echo "$1" >&2
    exit 1
}

ls /nonexistent_dir || error_exit "Directory does not exist."
```

---

## 8. File and Directory Operations

### Check if file/directory exists:

```bash
if [ -f "file.txt" ]; then
    echo "It's a file"
elif [ -d "dir" ]; then
    echo "It's a directory"
fi
```

### Create/read/write files:

```bash
echo "Hello" > file.txt # overwrite
echo "World" >> file.txt # append
cat file.txt # read
```

### Find files:

```bash
find . -name "*.sh" # find .sh files recursively
grep -r "hello" . # recursive grep
```

---

## 9. Process Management

### Run in background:

```bash
sleep 10 &
pid=$!
echo "Background PID: $pid"
```

### Wait for background jobs:

```bash
wait $pid
```

### List processes:

```bash
ps aux | grep bash
```

---

## 10. Debugging & Best Practices

### Debugging:

```bash
bash -x script.sh # Print each command before executing
set -x # Inside script to enable tracing
set +x # Turn off tracing
```

### Best Practices:

✅ Use quotes around variables  
✅ Use `[[ ]]` instead of `[ ]` for more features (e.g., pattern matching)  
✅ Use `set -euo pipefail` for robustness  
✅ Comment your code  
✅ Modularize with functions  
✅ Use `logger` for logging in production scripts

---

## 🧪 Exercises

Try these to reinforce your skills:

1. Write a script that backs up all `.txt` files in the current directory to a folder called `backup_YYYYMMDD`.
2. Create a menu-driven script that provides options to list files, show date, or exit.
3. Write a script that checks if a website is reachable and logs the result with timestamp.
4. Implement a number guessing game in Bash.
5. Parse a log file and extract all IPs, count unique ones.

---

## 📚 Recommended Resources

- [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/)
- [Bash Hackers Wiki](https://wiki.bash-hackers.org/)
- [ShellCheck](https://www.shellcheck.net/) – Static analysis tool for shell scripts

---

By mastering the topics above, you'll be well-equipped to write clean, powerful, and maintainable Bash scripts. Happy scripting! 🖥️💻🐧