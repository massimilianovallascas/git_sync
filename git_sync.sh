#!/bin/bash
#
# Script to mirror and keep in sync two git repositories
# Protected branches should not be updated on the Mirror to avoid conflicts
# These script come without warranty of any kind. Use them at your own risk. 

ORIGIN="git@github.com:YOURUSER/sourceRepo.git" # Origin repository url
MIRROR="git@github.com:YOURUSER/destinationRepo.git" # Mirror repository url
PROTECTED_BRANCHES=("main" "develop" "release") # Branches to keep in sync

ORIGIN_FOLDER="${ORIGIN##*/}"
CURRENT_FOLDER="$(pwd)"

function goToOriginFolder() {
    cd ${CURRENT_FOLDER}/${ORIGIN_FOLDER}
}

function goToScriptFolder() {
    cd ${CURRENT_FOLDER}
}

# Print all the branches in the local repository
function getCurrentBranches() {
    goToOriginFolder
    CURRENT_BRANCHES=$(git --no-pager branch -l | sed 's/*/ /' | awk '{print $1;}')
    echo ""
    echo "=== Current branches in ${ORIGIN_FOLDER} are:"
    echo "${CURRENT_BRANCHES}"
    goToScriptFolder
}

# Clone the origin repository and set the mirror repository
function setup() {
    git clone --mirror ${ORIGIN}
    goToOriginFolder
    git remote add --mirror=fetch mirror ${MIRROR}
    goToScriptFolder
}

# Sync the branches from the PROTECTED_BRANCHES array
function sync() {
    goToOriginFolder
    git fetch origin
    goToScriptFolder
    getCurrentBranches
    goToOriginFolder
    for current_branch in ${CURRENT_BRANCHES[@]}; do
        if [[ " ${PROTECTED_BRANCHES[@]} " =~ " ${current_branch} " ]]; then
            echo "* Syncing ${current_branch}"
            git push mirror ${current_branch}
        fi
    done
    goToScriptFolder
}

# Delete local branches not required to be synced
function deleteLocalBranches() {
    local current_branch=""
    goToOriginFolder
    for current_branch in ${CURRENT_BRANCHES[@]}; do
        if [[ ! " ${PROTECTED_BRANCHES[@]} " =~ " ${current_branch} " ]]; then
            echo "* Deleting ${current_branch}"
            git branch -D ${current_branch}
        fi
    done
    goToScriptFolder
}

# Delete local branches not in the PROTECTED_BRANCHES array and then sync
function sync2() {
    goToOriginFolder
    git fetch origin
    goToScriptFolder
    getCurrentBranches
    deleteLocalBranches
    getCurrentBranches
    goToOriginFolder
    git push mirror --all
    goToScriptFolder
}

function usage() {
    echo "${0} current_branches|setup|sync|sync2"
}

case ${1} in
  current_branches)
    getCurrentBranches
    ;;
  setup)
    setup
    ;;
  sync)
    sync
    ;;
  sync2)
    sync2
    ;;
  *)
    usage
    ;;
esac
