#!/bin/sh

# 
# Called after a successful `git checkout` or `git switch`, this hook script
# creates a file `.airflowignore` in the root directory of a bare repository,
# listing all files and directories except for the worktree directory of the last
# *checked out* branch; then Airflow will fill the `DagBag` with only the DAGs
# contained in this directory.
# 
# This hook accepts the following parameter,
# which is passed automatically by git:
#     $3 -- Flag indicating whether the checkout was a branch checkout
#           (changing branches, flag=1).
# 

main() {
    was_branch_checkout="$3"

    # Local override of aliases that might exist for `git`
    alias git=$(which git)

    # $GIT_DIR is not the root directory of a bare repository.
    # Next command extracts it on both "normal" and bare repositories.
    # DOES NOT SUPPORT SPACES IN NAME OF BRANCHES/WORKTREES/DIRECTORIES.
    git_dir=$(git worktree list | head -1 | cut -d" " -f1)

    # Returns true or false
    is_bare_repo=$(git config --get core.bare)

    if [ "${was_branch_checkout}" = 1 ]; then

        if [ "${is_bare_repo}" = false ]; then
            info "Not a bare repo, ignoring Airflow hook."
        else
            branch=$(git branch --show-current)

            # Extract path to a branch's worktree
            # DOES NOT SUPPORT SPACES IN NAME OF BRANCHES/WORKTREES/DIRECTORIES.
            branch_dir_name=$(git worktree list | grep -w "\[${branch}\]" | cut -d" " -f1 | xargs basename)

            # Ignore everything but the worktree directory
            /usr/bin/ls -AI "${branch_dir_name}" "${git_dir}" > "${git_dir}/.airflowignore"

            info ".airflowignore updated with everything except ${branch_dir_name}/"
        fi
    fi

    return 0
}

info() {
    echo >&2 "post-checkout hook: ${1}"
}

main "$@"
