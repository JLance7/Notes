remove file from history
`git filter-branch --index-filter 'git rm -rf --cached --ignore-unmatch path_to_file' HEAD`

git stash, git pop

keep file in repo without updating
`git update-index --assume-unchanged FILE_NAME`
`git update-index --no-assume-unchanged FILE_NAME`



squash
`git rebase -i commit-id`
`git squash commit-id (squashes into commit that has pick)`

`git merge --squash feature_branch (merge all commits from feature into another branch, must also do git commit afterwards)`


gpg
`gpg --encrypt --sign --armor -r email test2.txt`


Git Rebase 
accept current change:
  - keep base branch (main branch)'s changes
accept incoming change:
  - keep your local changes, add to rebased,
  (main branch)

Git merge
accept current change:
  - keep your local changes, discard incoming branch changes
accept incoming change:
  - accept incoming branch, discard current local changes
