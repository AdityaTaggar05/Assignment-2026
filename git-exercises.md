# Write-up for Git Exercises

### master

The first step required cloning the exercise repository to the local machine

```bash
git clone https://gitexercises.fracz.com/git/exercises.git
cd exercises
./configure.sh
git start
```

It automatically creates a commit, which needs to be pushed by running the command

```bash
git verify
```

---

### commit-one-file

This exercise requires us to commit only a single untracked file. This can be done by

```bash
git add A.txt
git commit -m "file A.txt pushed"
git verify
```

---

### commit-one-file-staged

This exercise requires us to unstage a file and then commit only a single file. This can be done by

```bash
git reset B.txt
git commit -m "file A.txt pushed"
git verify
```

---

### ignore-them

The .gitignore file content

```
*.exe
*.o
*.jar
libraries/
```

Then run the following commands

```bash
git add .gitignore
git commit -m "Added .gitignore"
git verify
```

---

### chase-branch

The branch `escaped` was 2 commits ahead. To make the `chase-branch` in sync, we need to merge the branch `escaped` into the branch `chase-branch`. This can be done by

```bash
git merge escaped # while being on the chase-branch
git verify
```

---

### merge-conflict

The branch `another-piece-of-work` needs to be merged into the branch `merge-conflict`. To do so run `git merge another-piece-of-work`, while being in the `merge-conflict` branch. This raises a merge conflict and to resolve it, I'll use nvim and modify the file contents to `2 + 3 = 5` and then push the changes using

```bash
git add .
git commit -m "resolved merge conflict"
git verify
```

---

### save-your-work

All the changes made need to saved, then the bug fix has to be committed, and finally the finished work has to be committed. This can be done by

```bash
git stash # saves your work in the background
nvim bug.txt # to remove the bug
git add bug.txt
git commit -m "bug fix"
git stash pop # to recover the previously done work
nvim bug.txt # to add the final line of work
git add .
git commit -m "finished work"
git verify
```

---

### change-branch-history

We need to apply the changes made in the branch `change-branch-history` to the latest commit of the branch `hot-bugfix` i.e. we want to rebase the branch `change-branch-history` onto the branch `hot-bugfix`. This can be done by

```bash
git rebase hot-bugfix change-branch-history
git verify
```

---

### remove-ignored

We need to remove the file `ignored.txt` from the repo. This can be done by

```bash
git rm ignored.txt
git commit -m "removed ignored.txt"
git verify
```

---

### case-sensitive-filename

```bash
git mv File.txt file.txt
git commit -m "renamed file"
git verify
```

---

### fix-typo

We need to fix the typo in the file, stage the changes and then ammend the latest commit to include those changes. This can be done by

```bash
nvim file.txt # fix the typo
git add file.txt
git commit --amend # fix the commit message
git verify
```

---

### forge-date

To change the date, we can use `--date` flag. This can be done by

```bash
git commit --amend --date="1987-03-12 13:34:21"
git verify
```

---

### fix-old-typo

We need to fix a typo 2 commits before in the file as well as in the commit message. This can be done by

```bash
git rebase -i HEAD~2
# this gives us the option to modify the previous commit history. mark the required commit with edit instead of pick. save and close the file

nvim file.txt # fix the typo
git add file.txt
git commit --amend # fix the typo in the commit message
git rebase --continue
# this raises a merge conflict with the 2nd commit in the file.txt

nvim file.txt # resolve the merge conflict
git add file.txt
git rebase --continue

git verify
```
