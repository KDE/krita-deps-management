# How to update compiler in Krita

## Creation of a new "branch" of Krita that uses new compiler/environment

1) Create a MR for ci-images repository with the updated image for the corresponding platform

    * the image should have a different name, e.g. `krita-windows-builder-clang18`
    * do not use docker tags, since KDE infrastructure doesn't use them, only image names
    * example: https://invent.kde.org/sysadmin/ci-images/-/merge_requests/306

2) Create a branch in `krita-deps-management` repository for the transitionary builds

    * the branch should start with `transition.now/*` prefix, e.g. `transition.now/win-clang18`
    * all branches with `transition.now/*` prefix are protected and, hence, are allowed to
      publish the packages into repository

3) Replace the value of `BRANCH_NAME_WINDOWS` in `.gitlab-ci.yml` with the name of your new branch

    * use `BRANCH_NAME_LINUX` or `BRANCH_NAME_ANDROID` if you change stuff for these platforms as well

5) Change the `image` tag for the corresponding job in `.gitlab-ci.yml` to point to the new docker image

    * again, we don't use docker tags, only image names; so the image will always point to `:latest`

6) Run `all_local_cache_windows` (or `all_local_cache_<your-platform>`) job on CI to verify that all
   the packages can be built correctly with the new setup

7) When the packages are built, run `all_publish_windows` job to actually publish the packages in the repository.

   Now all your packages are available for consumption by Krita using normal routines using the new branch name.

8) [krita] Create a Krita branch with the same name (i.e. `transition.now/win-clang18`)

9) [krita] Replace the value of `DEPS_BRANCH_NAME_WINDOWS` in `.gitlab-ci.yml` in Krita's repository with the name of
   your new dependencies branch

10) [krita] Replace the value of `DEPS_REPO_BRANCH_NAME_WINDOWS` in `.gitlab-ci.yml` in Krita's repository with the name of
   your new dependencies branch, if your changes also affect files used by Krita itself, like `krita-deps.yml` or toolchain
   files.

11) [krita] Change the value of `VM_IMAGE_NAME_WINDOWS` in `.gitlab-ci.yml` to point to the new docker image

10) [krita] Make sure Krita compiles correctly with the new set of dependencies

## Deprecation of the old compiler/environment

1) [krita-deps-management] Replace `BRANCH_NAME_WINDOWS` back to `master` in the transition branch

2) [krita-deps-management] Merge the transition branch into master`

3) [krita-deps-management] Run `all_publish_windows` job to actually publish the packages into the repository.

4) [krita] Replace `DEPS_BRANCH_NAME_WINDOWS` back to `master` in the transition branch

5) [krita] Replace `DEPS_REPO_BRANCH_NAME_WINDOWS` back to `master` in the transition branch

6) [krita] Merge the transition branch into master

7) [krita] Make sure Krita compiles fine with the new set of deps

8) [krita-docker-env] [Linux] If Linux docker image has changed, then update the link to that in 
   Krita-docker-env repository in `base-image.conf` file:

   * https://invent.kde.org/dkazakov/krita-docker-env/-/blob/master/bin/base-image.conf

9) [krita-ci-utils] Add the deprecated branch into the list of branches to remove in
   section `branchesToRemove` of `package-registry-cleanup.py` script:

   * https://invent.kde.org/packaging/krita-ci-utilities/-/blob/master/package-registry-cleanup.py?ref_type=heads#L32

   The script will remove the branch on the following sunday night. You can check that by checking
   packages in the repository:

    * the packages will have suffix `-transition-win-clang18`
    * link: https://invent.kde.org/teams/ci-artifacts/krita-windows/-/packages

10) Make a sysadmin ticket to:

    * remove the old docker image
    * remove the transition branch (you cannot remove it normally, since it is protected)
