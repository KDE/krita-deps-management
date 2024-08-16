# Krita dependencies management repository

## Links

* fork of ci-utilities repository: https://invent.kde.org/dkazakov/ci-utilities
* ci-images repository: https://invent.kde.org/sysadmin/ci-images
* artifacts:
    * Windows: https://invent.kde.org/dkazakov/krita-ci-artifacts-windows-qt5.15
    * Linux: https://invent.kde.org/dkazakov/krita-ci-artifacts-appimage-qt5.15
    * MacOS: https://invent.kde.org/dkazakov/krita-ci-artifacts-macos-qt5.15
    * Android-arm64-v8a: https://invent.kde.org/dkazakov/krita-ci-artifacts-android-arm64-v8a-qt5.15
    * Android-armeabi-v7a: https://invent.kde.org/dkazakov/krita-ci-artifacts-android-armeabi-v7a-qt5.15
    * Android-x86_64: https://invent.kde.org/dkazakov/krita-ci-artifacts-android-x86_64-qt5.15
    * Android-x86: https://invent.kde.org/dkazakov/krita-ci-artifacts-android-x86-qt5.15
* Notary service repository: https://invent.kde.org/sysadmin/ci-notary-service
* Configs for the notary service: https://invent.kde.org/sysadmin/ci-utilities/-/tree/master/signing

## CI job names structure

All publicly available CI jobs have names in the following format:

```
<target_packages>_<build_type>_<platform>
```

`<target_packages>` defines what packages are going to be built in this job. It may have the following values:

* `all` --- the job builds all the packages available in the repository, including the debug and asan versions of the packages

* `custom` --- the job builds only the packages passed via the web gui. To pass the space-separated list of packages, click on the job and set up the following environment variable:

    * var: `KRITA_STAGE_DEP`
    * value: `base/qt base/mlt` (space-separated list)

* `dirty` --- the job rebuilds a subtree of "dirty" packages. Basically, it rebuilds the passed packages and all their dependencies. The list is passed via `KRITA_STAGE_DEP` like for "custom" packages.

`<build_type>` defines what happens with the package after the build is done. It may have the following values:

* `publish` --- after the build the packages are published to the repository; publishing is allowed in protected branches only, so if you try to build multiple packages in a non-protected branch, the job will most probably fail

* `local_cache` --- after the build the packages are uploaded into the local cache. This method is suitable for non-protected branches and merge requests to test the changes in the build process

* `shared` --- this is the legacy method of building multiple backages in the same environment without uploading them into the package repository. Currently, it is available for debugging purposes only

`<platform>` selects the platform for which we build the package. Please note that `android-x86` platform is kept only for debugging purposes. We don't provide Krita build for this platform anymore.
