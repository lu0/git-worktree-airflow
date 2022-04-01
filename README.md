# `git-worktree-airflow`

This repository contains a post-checkout hook script useful to manage Airflow
`dags_folder`s pointing to bare repositories.

Called after a successful `git checkout` or `git switch`, this hook script
creates a file `.airflowignore` in the root directory of a bare repository,
listing all files and directories except for the worktree directory of the last
*checked out* branch; then Airflow will fill the `DagBag` with only the DAGs
contained in this directory.

## Installation

- Copy or link the `post-checkout.sh` script into the `hooks` directory of your
`dags_folder` (which should be a bare repository), and rename it to
`post-checkout`.

    - Example:

    <pre><code>ln -srf post-checkout.sh <b>/path/to/your/dags_folder</b>/hooks/post-checkout</pre></code>

## Usage

1. ***cd*** into the worktree directory of a branch
    ```language
    cd /path/to/worktree/branch/
    ```
    
1. Trigger the hook by running either

    ```sh
    git checkout $(git branch --show-current)
    ```
    or
    ```sh
    git switch $(git branch --show-current)
    ```

If the repository is a bare repository, the hook will show the following message:
```txt
.airflowignore updated with everything except <worktree directory of checked out branch>
```
