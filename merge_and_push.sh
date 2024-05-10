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
# the environment variable "ghtoken" is a git token which needs permission to push to your source-repo
# and should be added to the CI/CD call, e.g.:
#   - name: merge&sync
#     run: merge_and_push.sh <source-repo>:<merge-branch> <upstream-repo>:<upstream-branch>
#     env:
#      ghtoken: ${{ github.token }}
# assumption is that you checked out <source-repo> in the current step already
##########################################################################################################
set -e # be strict on any error

# check args
if [ $@ -lt 2 ];then echo "missing arg ($0 <source-repo>:<merge-branch> <upstream-repo>:<upstream-branch>)"; exit 4;fi
if [ -z "${ghtoken}" ];then echo "missing token info"; exit 4;fi

# setup vars
lsource="$1"
utarget="$2"
LBRANCH="${lsource/:*}"
UBRANCH="${utarget/:*}"
LREPOFULL="${ltarget/*:}"
UREPOFULL="${utarget/*:}"
LREPONAME=$(echo "${lsource/*:}" | cut -d '/' -f2)
UREPONAME=$(echo "${usource/*:}" | cut -d '/' -f2)
LREPOURL="https://tok:${ghtoken}@${LREPO}.git"
UREPOURL="https://${UREPO}.git"

echo "Syncing changes from $lsource into $utarget ..."

##############################################################################
##############################################################################

# sync, merge & push
function sync_source() {
   git remote add upstream $UREPOURL
   echo "remote-add ended with $?"
   git fetch upstream
   echo "fetch-upstream ended with $?"
   git checkout $LBRANCH
   echo "checkout ended with $?"
   git merge upstream/$UBRANCH
   echo "merge ended with $?"
   git push origin $LBRANCH
   echo "push ended with $?"
}
sync
echo "$0 finished successfully"
