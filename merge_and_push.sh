#!/bin/bash
##########################################################################################################
#
# sync code with an upstream repo within a global CI/CD setup (github actions on an ORG)
# if a single repo is required better use: aormsby/Fork-Sync-With-Upstream-action instead
#
# script adapted from:
# https://github.com/sfX-android/jenkins_scripts/blob/main/common/merge_upstream.sh
#
# Copyright:
# - 2020-2024  steadfasterX <steadfasterX |AT| gmail #COM#>
#
##########################################################################################################
# setup/usage:
# the following environment variables are expected to be accessible by this script:
#   - ghtoken -> a git token which needs permission to push to your source-repo
#   - gituser -> username for the merge commit
#   - gitmail -> mail for that username
# and should be added to the CI/CD call, e.g.:
#   - name: merge&sync
#     run: merge_and_push.sh <source-repo>:<merge-branch> <upstream-repo>:<upstream-branch>
#     env:
#      ghtoken: ${{ github.token }}
# assumption is that you checked out <source-repo> in the current step already
##########################################################################################################
set -e # be strict on any error

# check args
if [ $# -lt 2 ];then echo "missing arg ($0 <source-repo>:<merge-branch> <upstream-repo>:<upstream-branch>)"; exit 4;fi
if [ -z "${ghtoken}" ];then echo "missing token info"; exit 4;fi

# setup vars
lsource="$1"
utarget="$2"
MODE="$3"
case $MODE in 
   DRYRUN) TESTMODE=1;;
   *) TESTMODE=0;;
esac
LBRANCH="${lsource/*:}"
UBRANCH="${utarget/*:}"
LREPOFULL="${ltarget/:*}"
UREPOFULL="${utarget/:*}"
LREPONAME=$(echo "${lsource/:*}" | cut -d '/' -f2)
UREPONAME=$(echo "${usource/:*}" | cut -d '/' -f2)
LREPOURL="https://tok:${ghtoken}@${LREPOFULL}.git"
UREPOURL="https://${UREPOFULL}.git"

echo "Syncing changes from $utarget into $lsource ..."

##############################################################################
##############################################################################

# add git commit infos
setup_git(){
   git config --global user.name "$gituser"
   git config --global user.email "$gitmail"
}

# sync, merge & push
sync() {
   git remote add upstream $UREPOURL
   echo "remote-add ended with $?"
   git fetch upstream
   echo "fetch-upstream ended with $?"
   git checkout $LBRANCH
   echo "checkout ended with $?"
   git merge --allow-unrelated-histories upstream/$UBRANCH
   echo "merge ended with $?"
   if [ $TESTMODE -ne 1 ];then
      git push origin $LBRANCH
   else
      echo -e "TESTMODE=$TESTMODE, not pushing anything!\nHere the current git state instead:"
      git status
      git diff
      git show
   fi
   echo "push ended with $?"
}
setup_git
sync
echo "$0 finished successfully"
