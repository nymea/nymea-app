# nymea-app

QtQuick nymea client application

# building

Required packages:
It is recommended to install a complete Qt installation. Minimum required Qt Version *5.7.0*.

No extra modules are required for a basic desktop build.

After cloning the repository, run

    $ git submodule init
    $ git submodule update

To build a binary run

    $ mkdir builddir
    $ cd builddir
    $ qmake path/to/source/dir
    $ make

Or open `nymea-app.pro` in QtCreator and click the **"Play"** button.

Optional configuration flags to be passed to qmake:

- `CONFIG+=withtests`

> Enables building the testrunner target

## Android
As Qt can't bundle a build of openssl for android, you need to place a copy to
`/opt/android-ssl/`

## Windows

There is an additional make target named "wininstaller" available. You need to
have windeployqt and binarycreator (from Qt Install Framework 3.0) in your
system's Path.

# Running the tests

Required Packages:

- `qtdeclarative5-test-plugin`
- `nymead`

