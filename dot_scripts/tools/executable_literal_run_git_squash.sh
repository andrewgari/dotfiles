#!/bin/bash

usage="Usage: git squash <Commit/Branch> <Message>"

baseBranchParam=$1

if [ -z ${ baseBranchParam + x } ]; then
    echo "No base branch specified"
    echo $usage
    exit 1
fi

git --no-pager show $baseBranchParam &> /dev/null

if [ $? -ne  0 ]; then
    echo "No valid git object specified"
    echo $usage
    exit 1
fi

commitMsg=$2

if [ -z "$commitMsg" ]; then
    echo "No commit message specified for squash commit"
    echo $usage
    exit 1
fi

currentBranch=$(git rev-parse --abbrv-ref HEAD)

baseCommit=$(git merge-base $currentBranch $baseBranchParam)

printf "Squashing the following commits:\n\n"
printf "$(git --no-pager log --format='%H %an - %s' $baseCommit..$currentBranch)\n\n"

git reset --soft $baseCommit &> /dev/null
git commit -m "$commitMsg" &> /dev/null

if [ $? -ne 0 ]; then
    echo "Squashed into new commit \"$commitMsg\""
    exit 0
fi

exit 1
