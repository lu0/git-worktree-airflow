`git-worktree-airflow`
---

This repository contains a post-checkout hook script useful to manage Airflow
`dags_folder`s pointing to bare repositories.

Called after a successful `git checkout` or `git switch`, this hook script
creates a file `.airflowignore` in the root directory of a bare repository,
listing all files and directories except for the worktree directory of the last
*checked out* branch; then Airflow will fill the `DagBag` with only the DAGs
contained in this directory.

Table of Contents
---
- [Installation](#installation)
- [Usage](#usage)
  - [Option 1: Using `git-worktree-wrapper`](#option-1-using-git-worktree-wrapper)
  - [Option 2: Using default `git`](#option-2-using-default-git)

# Installation

- Copy or link the `post-checkout.sh` script into the `hooks` directory of your
`dags_folder` (which should be a bare repository), and rename it to
`post-checkout`.

- Example:

<pre><code>ln -srf post-checkout.sh <b>/path/to/your/dags_folder</b>/hooks/post-checkout</pre></code>

*Note*: Make the script executable with `chmod +x post-checkout` if you
***copied** the script instead of linking it.


# Usage

## Option 1: Using [`git-worktree-wrapper`](https://github.com/lu0/git-worktree-wrapper)

- Install [`git-worktree-wrapper`](https://github.com/lu0/git-worktree-wrapper).

- Then switch to a branch by running:

    ```sh
    git checkout <branch_name>
    ```

The hook will be triggered automatically and will show the following message:

```txt
.airflowignore updated to load DAGs from branch <branch_name>
```

## Option 2: Using default `git`


1. ***cd*** into the worktree directory of a branch
    ```language
    cd /path/to/the/root/directory/of/the/bare/repo
    cd branch_name
    ```
    
1. Trigger the hook by running

    ```sh
    git checkout
    ```

The hook will show the following message:
```txt
.airflowignore updated to load DAGs from branch <branch_name>
```
