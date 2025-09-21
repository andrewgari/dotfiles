function git-summary
  if not git rev-parse --is-inside-work-tree &>/dev/null
    echo "Not a git repository!"
    return 1
  end
  echo "Branch: (git branch --show-current)"
  echo "Status:"
  git status -s
  echo "Recent commits:"
  git log --oneline -n 5
end