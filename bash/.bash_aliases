# GIT aliases
alias gitcommit='git commit -a -s -v --gpg-sign'
alias gitupdate="git pull --no-commit --ff-only --all -v && git submodule update --recursive --merge && git submodule foreach 'git status'"
alias gitpush='git push -u -v && git push --tags'
alias gitclone='git clone --recursive -v'
alias gitupdateall="git pull --all -v && git submodule foreach 'git pull --all -v'"
alias gitcommitall="git submodule foreach 'git diff-index --exit-code --quiet HEAD || git commit -a -s -v --gpg-sign' && git commit -a -s -v --gpg-sign"
alias gitpushall="git submodule foreach 'git push -u -v --all && git push --tags' && git push -u -v --all && git push --tags"
alias gittag="git tag --sign"
alias gitreply="git cherry-pick -n"
alias gitrevert="git revert -n"
alias gitfetch="git fetch -v --all --prune"

# Virtual X-Server alias
alias virtualx='xvfb-run -a -l'

# Pandoc
alias pdmarkdown='pandoc -s -S --toc --section-divs '
