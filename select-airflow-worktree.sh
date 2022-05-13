#!/usr/bin/env bash

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

set -euo pipefail

select-airflow-worktree() {
    # Defaults to argument passed by pre-commit framework if
    # not triggered by vanilla git
    was_branch_checkout="${3:-${PRE_COMMIT_CHECKOUT_TYPE}}"

    # Local override of aliases that might exist for `git`
    git() {
        /usr/bin/env git "$@"
    }

    # $GIT_DIR is not the root directory of a bare repository.
    # Next command extracts it on both "normal" and bare repositories.
    # DOES NOT SUPPORT SPACES IN NAME OF BRANCHES/WORKTREES/DIRECTORIES.
    git_dir=$(git worktree list | head -1 | cut -d" " -f1)

    # Returns true or false
    is_bare_repo=$(git config --get core.bare)

    if [ "${was_branch_checkout}" = 1 ]; then

        if [ "${is_bare_repo}" == false ]; then
            info "Not a bare repo, skipping airflow-worktree"
        else
            # Informationn of the worktree we are in
            worktree_info=$(git worktree list | grep "$PWD " | xargs)

            # DOES NOT SUPPORT SPACES IN NAME OF BRANCHES/WORKTREES/DIRECTORIES.
            worktree_abs_path=$(echo "${worktree_info}" | cut -d" " -f1)

            # Path to the workspace relative to the repository's root directory
            worktree_rel_path="${worktree_abs_path##"${git_dir}"/}"

            # Ignore everything but the worktree directory
            /usr/bin/env ls -AI "${worktree_rel_path}" "${git_dir}" > "${git_dir}/.airflowignore"

            info ".airflowignore updated to load DAGs from ${worktree_rel_path}"
        fi
    else
        info "Not a branch checkout, skipping airflow-worktree."
    fi
    return 0
}

info() {
    echo -e >&2 "\t${1}\n"
}

select-airflow-worktree "$@"
