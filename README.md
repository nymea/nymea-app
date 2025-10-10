# nymea-app

QtQuick nymea client application

# building

Required packages:
It is recommended to install a complete Qt installation. Minimum required Qt version is Qt 6.

No extra modules are required for a basic desktop build.

After cloning the repository, run

    $ git submodule init
    $ git submodule update

To build a binary with CMake run

    $ cmake -S . -B build
    $ cmake --build build

The build can be customised with the following cache variables:

- `-DNYMEA_ENABLE_ZEROCONF=ON` enables ZeroConf support when the QtZeroConf and
  Avahi dependencies are available.
- `-DNYMEA_USE_MATERIAL_ICONS=ON` switches the icon theme to the Material icon set.

Legacy qmake builds are still available by opening `nymea-app.pro` in QtCreator
and building the project there.

Optional configuration flags to be passed to qmake:

- `CONFIG+=withtests`

> Enables building the testrunner target

## Android
When targeting Android, the build will download the KDAB
[`android_openssl`](https://github.com/KDAB/android_openssl) package at
configure time and automatically bundle the provided `libssl` and `libcrypto`
shared libraries inside the APK. An active internet connection is therefore
required the first time you configure an Android build directory. Other
platforms will build without explicitly linking to OpenSSL if the development
package is not installed.

## Windows

There is an additional make target named "wininstaller" available. You need to
have windeployqt and binarycreator (from Qt Install Framework 3.0) in your
system's Path.

# Running the tests

Required Packages:

- `qtdeclarative5-test-plugin`
- `nymead`

# Custom styles and branding:

## Overriding styles available in the app

nymea-app can be built with custom styles by passing STYLES_PATH to qmake.
Example:
    $ qmake STYLES_PATH=/home/user/my-styles/

The path must point to a directory containing the following file structure:

- styles.qrc
- styles/<stylename>/logo.svg

styles.qrc should be a Qt qrc file listing all the files inside styles/
providing an logo.svg is the minimum required for a style. In addition to
that, any QtQuick.Controls 2 component can be override. See the styles/
directory in this repository fo examples.


## Branding

In addition to overriding the available app styles, the app can be branded.
That means, the style selection will be hidden and the app is locked down to
the style given by the BRANDING argument passed to qmake.

Example locking down the app to the "dark" style:
    $ qmake BRANDING=dark

Brandings will also affect the installer packages. If you use branding in combination
with style overrides, you also need to provide a installer package in
packages/<platform>_<branding> in your styles directory. See the packaging directory
in this repository for examples for isntaller packages.

Example:
    $ qmake STYLES_PATH="C:\path\to\my\styles" BRANDING=mycoolstyle

This would the following minimum files in C:\path\to\my\styles\ :
- styles.qrc
- styles\mycoolstyle\logo.svg
- packaging\windows_mycoolstyle\


