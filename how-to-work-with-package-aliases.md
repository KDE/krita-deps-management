# How to work with package aliases

A pacakge alias is a "flavour" of a package that can substitute a normal package. For example, "ext_qt" package may have multiple flavours, like "ext_qt-debug", "ext_qt-asan" or "ext_qt-quickcontrols2". The main requirement for a package flavour is full **binary compatibility** with the original package. That is, packages depending on the original package much be able to consume a flavour package without full recompilation.

We use package flavours for several purposes:

* provide a debugging versions of a package (or ASAN-capable)
* build a package with a different set of flags, needed for a specific merge request

## Create a flavour of a package

Imagine we would like to create a flavour of a Qt package. To implement that we need to do the follwoing:

1) Add a CMake option in `ext_qt/CMakeLists.txt`. Make sure that the option is disabled by default.

```cmake
if (QT_ENABLE_MY_OPTION)
    # TODO: do something that changes the build process of Qt
endif ()
```

2) Create a separate folder for your flavour of the package (`ext_qt-myoption`) and add a special `.kde-ci-override.yml` file with the follwoing content:

```yml
Options:
  cmake-options: '-DQT_ENABLE_MY_OPTION=ON'
```

3) Create metadata for the new package flavour:

    1) Copy `repo-metadata/projects-invent/base/qt` folder into `repo-metadata/projects-invent/base/qt-myoption`

    2) Edit `metadata.yml` any replace all `qt` into `qt-myoption`

    3) Make sure that `repopath` is also changes, since this field is used as a unique key by the scripts internally

    4) Add line `reuse-directory: ext_qt` to make sure the project reuses the recipe of the main package

       When package is being built, the build script will copy the content of `ext_qt` into `ext_qt-myoption` and apply the cahnges from `.kde-ci-override.yml` to `.kde-ci.yml`, which was copied from the original project.

4) Add the package flavour to `latest/developer-packages.yml` seed file, to make sure it is rebuilt on full rebuilds.

5) Build the newly added package:

    1) Open the pipeline job `custom_publish_<platform>` (click on the name, **not** on the "start" button)

    2) On the job's page add an environment variable:

        * var: `KRITA_STAGE_DEP`
        * value: `base/qt-myoption`

    3) Start the job

## Connect the package flavour to the Krita build

After the package flavour has been built, you need to instruct Krita to deploy it during the build process.

1) Open `.kde-ci.yml` file in Krita repository

2) Add the alias statement to substiture `ext_qt` package with your custom flavour `ext_qt-myoption`:

```yml
PackageAliases:
  ext_qt: ext_qt-myoption
```

3) Save and push into your branch/MR. All CI jobs will now use `ext_qt-myoption` package when building your MR.

### Note on paltform-specific flavours

If your flavour is available only on a specifc platform, you can add it via declaring an environment variable in the corresponding jobs in `.gitlab-ci.yml` file in Krita repository:

```yml
.windows-build-base:
  variables:
    KDECI_PACKAGE_ALIASES_YAML: '{ ext_qt : ext_qt-myoption }'
```

Though this method it **not** recommended, since it makes it difficult to reproduce the environment locally.

### Note on merging package flavours into master

Please do **not** merge flavoured packaged into master! It may break development environment for people and create a lot of troubles for people, who are not familiar with the changes. Make sure that all your changes are merged into "mainstream" package before the MR is merged into master.
