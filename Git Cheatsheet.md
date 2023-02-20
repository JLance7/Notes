# Git commands

## **1. Basics**
### 1. Adding/committing files 
```
git init                                 //create git repository
git add .  (or git add filename.txt)     //add file(s) to be committed
git commit -m "Commit message"           //commit files
```

### 2. Checking status
```
git status                               //check if files are added/committed
git log                                  //see history of commits
git diff <commit id>                     //see diff between working tree and commit
git diff <commit id> <commit id>         //see diff between commits
git checkout <commit id>                 //view files at that commit
```

### 3. Branches
#### Create/view branch
```
git branch                               //see list of every branch
git branch branchName                    //create new branch (the new branch has every commit in master)
git checkout branchName                  //change to branchName
git checkout -b branchName               //create branch and change to it
```
#### Modify branch
```
git branch -d branchName                 //deletes branchName
git merge branchName                     //adds each commit from branchName to the branch you are on
```

---

## 2. **Undoing mistakes**
### Basic undo commands
```
git checkout <commit id> .               //set working directory to that commit
git revert <commit id>                   //creates new commit that removes everything in <commit id>
git reset --hard <commit id>             //delete all commits before this commit
```
### Creating new commit of old commit
```
git checkout <commit id> .
git commit -m "copy of old commit"       //creates copy of old commit as a new commit
```
### Delete all commits after this commit (best to do in a branch)
```
git checkout -b newBranch
git reset --hard <commit id>
git checkout master
git merge newBranch
```
---

## 3. **Github/remote repository**
### Set up remote repository
```
git remote add origin <repositroyURL>    //add remote origin
git push -u origin master                //push files to remote repository
git push                                 //push commits to remote repository
git pull                                 //download changes in remote repository 
```
