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

    is_bare_repo=$(git config --get core.bare)

    if [ "${was_branch_checkout}" = 1 ]; then

        if [ "${is_bare_repo}" == false ]; then
            info "Not a bare repo, skipping airflow-worktree"
        else
            git_root_dir=$(git rev-parse --git-common-dir)
            worktree_abs_path=$(git rev-parse --show-toplevel)
            worktree_rel_path="${worktree_abs_path##"${git_root_dir}"/}"

            # Ignore all directories except root and worktree
            /usr/bin/env find "${git_root_dir}" -maxdepth 1 -type d \
                -not -path "${git_root_dir}" \
                -not -path "${worktree_abs_path}" \
                -printf '^%P/\n' | sort \
                > "${git_root_dir}/.airflowignore"

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
