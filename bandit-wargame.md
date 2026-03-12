# Write up for Bandit Wargame

### Level 0

In order to login to the Bandit OTW, run

```bash
ssh bandit.labs.overthewire.org -p 2220 -l bandit0 # or ssh bandit0@bandit.labs.overthewire.org -p 2220
```

### Level 1

The password is stored in the readme file. To solve

```bash
cat readme # copy the password
exit
ssh bandit1@bandit.labs.overthewire.org -p 2220
```

---

### Level 2

The password is stored in a file with name `-`. A direct causes the command to confuse it with a flag/option. It can be fixed by

```bash
cat ./- # or equivalently cat /home/bandit1/-
exit
ssh bandit2@bandit.labs.overthewire.org -p 2220
```

Which works by substituting the start of the filepath with the current working directory's path (/home/bandit1/) which doesn't allow the command to treat it as an option

---

### Level 3

In a similar concept to Level 2, we need to substitute the start of the filepath with the working directory so that it isn't treated as an option. Run

```bash
cat ./"--spaces in this filename--" # copy the password
exit
ssh bandit3@bandit.labs.overthewire.org -p 2220
```

---

### Level 4

Since the file is hidden, normal `ls` command wouldn't reveal it. We need to use `ls -a` to get the filename, then run

```bash
cat ./"...Hiding-From-You" # copy the password
exit
ssh bandit4@bandit.labs.overthewire.org -p 2220
```

---

### Level 5

We'll first need to determine each file's type and then scan the possible files. This can be done by

```bash
file ./-file* # which lists out all file's types and shows that -file07 is ASCII TEXT
cat ./-file07 # to get the password
exit
ssh bandit5@bandit.labs.overthewire.org -p 2220
```

---

### Level 6

The command `du` helps to check the file sizes and the command `grep` lets you search through the text. A combination of these commands is what we need

```bash
du -ab | grep 1033 # lists out all file sizes in bytes and then searches for 1033. this yields the file to be ./maybehere07/.file2
cat ./maybehere07/.file2 # to get the password
exit
ssh bandit6@bandit.labs.overthewire.org -p 2220
```

---

### Level 7

We can use the `find` command to find the file with the required properties, but we don't have the access to a lot of these directories, which can be sort of bypasses by passing the error stream (2) to `/dev/null`

```bash
find / -user bandit7 -group bandit6 -size 33c 2> /dev/null # outputs the required file
cat /var/lib/dpkg/info/bandit7.password # to get the password
exit
ssh bandit7@bandit.labs.overthewire.org -p 2220
```

---

### Level 8

We can search files for text using `grep` command

```bash
grep millionth data.text # copy the password
exit
ssh bandit8@bandit.labs.overthewire.org -p 2220
```

---

### Level 9

The `uniq` command checks for duplicacy on adjacent lines, so we need to make sure that all the duplicate lines appear together. This can be done by using the `sort` command.

```bash
sort data.txt | uniq -u # outputs the password
exit
ssh bandit9@bandit.labs.overthewire.org -p 2220
```

---

### Level 10

We can use regex (Perl-based) to filter out the lines from the output of `strings` command which filters out only the human-readable lines from the file.

```bash
strings data.txt | grep -P "=+ " # now find the password
exit
ssh bandit10@bandit.labs.overthewire.org -p 2220
```

---

### Level 11

```bash
base64 -d data.txt
exit
ssh bandit11@bandit.labs.overthewire.org -p 2220
```

---

### Level 12

This can be accomplished by using the `tr` (translate) command, which maps characters from one string to another one. ROT-13 is the same as the mapping 'a-zA-z' to 'n-za-mN-ZA-M'.

```bash
cat data.txt | tr 'a-zA-Z' 'n-za-mN-ZA-M'
exit
ssh bandit12@bandit.labs.overthewire.org -p 2220
```

---

### Level 13

The given file is a hexdump of a file which is repeatedly compressed by various formats (tar, gzip, bzip2). And also the directory containing the file doesn't allow for creation of new files, so we need to copy the contents of the file to a different location where those permissions are granted to us.

```bash
mktemp -d # copy the address
cp data.txt <temp-directory>
cd <temp-directory>

xxd -r data.txt > binary # reverts the hexdump and pushes into binary file

file binary # outputs gzip, so use
gunzip binary

# Then repeat this process, checking for the file type and unzipping using the corresponding format to get to the password
exit
ssh bandit13@bandit.labs.overthewire.org -p 2220
```

---

### Level 14

We need to login using the ssh private key and then once we are in the bandit14 user, we can access even the password

```bash
cat sshkey.private # copy the file contents
exit
nvim sshkey.private # paste the contents here, so that it creates a local copy of the same private key

ssh -i sshkey.private -p 2220 bandit14@bandit.labs.overthewire.org # logs you into user bandit14
cat /etc/bandit_pass/bandit14 # to get the password
```

---

### Level 15

We need to send a request to localhost:30000

```bash
nc localhost 30000
# then in the next line waiting for input enter the password from the previous level to get the new password
```

---

### Level 16
