function git-stats
  history | grep "git " | awk '{print $2, $3}' | sort | uniq -c | sort -nr | head -n 10
end