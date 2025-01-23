# How to update compiler in Krita

## Creation of a new "branch" of Krita that uses new compiler/environment

1) Create a MR for ci-images repository with the updated image for the corresponding platform

    * the image should have a different name, e.g. `krita-windows-builder-clang18`
    * do not use docker tags, since KDE infrastructure doesn't use them, only image names
    * example: https://invent.kde.org/sysadmin/ci-images/-/merge_requests/306

2) Create a branch in `krita-deps-management` repository for the transitionary builds

    * the branch should start with `transition/*` prefix, e.g. `transition/win-clang18`
    * all branches with `transition/*` prefix are protected and, hence, are allowed to
      publish the packages into repository

3) Replace the value of `BRANCH_NAME_WINDOWS` in `.gitlab-ci.yml` with the name of your new branch

    * use `BRANCH_NAME_LINUX` or `BRANCH_NAME_ANDROID` if you change stuff for these platforms as well

4) Change the branch name of `krita-deps-management` repository (add `-b transition/win-clang18`):

    ```bash
    git clone https://invent.kde.org/dkazakov/krita-deps-management.git -b transition/win-clang18 krita-deps-management --depth=1
    ```

5) Change the `image` tag for the corresponding job in `.gitlab-ci.yml` to point to the new docker image

    * again, we don't use docker tags, only image names; so the image will always point to `:latest`

6) Run `all_local_cache_windows` (or `all_local_cache_<your-platform>`) job on CI to verify that all
   the packages can be built correctly with the new setup

7) When the packages are built, run `all_publish_windows` job to actually publish the packages in the repository.

   Now all your packages are available for consumption by Krita using normal routines using the new branch name.

8) Create a Krita branch with the same name (i.e. `transition/win-clang18`)

9) Replace the value of `DEPS_BRANCH_NAME_WINDOWS` in `.gitlab-ci.yml` in Krita's repository with the name of
   your new dependencies branch

10) Make sure Krita compiles correctly with the new set of dependencies

## Deprecation of the old compiler/environment

1) [krita-deps-management] Replace `BRANCH_NAME_WINDOWS` back to `master` in the transition branch

2) [krita-deps-management] Merge the transition branch into master`

3) [krita-deps-management] Run `all_publish_windows` job to actually publish the packages into the repository.

4) [krita] Replace `DEPS_BRANCH_NAME_WINDOWS` back to `master` in the transition branch

5) [krita] Remove a custom branch of `krita-deps-management` repository (remove `-b transition/win-clang18`):

    ```bash
        git clone https://invent.kde.org/dkazakov/krita-deps-management.git krita-deps-management --depth=1
    ```

6) [krita] Merge the transition branch into master

7) [krita] Make sure Krita compiles fine with the new set of deps

8) Remove all the "branched" packages from the corresponding repository

    * the packages will have suffix `-transition-win-clang18`
    * link: https://invent.kde.org/groups/teams/ci-artifacts/krita-windows/-/packages

9) Make a sysadmin ticket to remove the old docker image
