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

## License

nymea-app is licensed under the terms of the GNU General Public License,
version 3 or (at your option) any later version (SPDX identifier:
GPL-3.0-or-later). The complete GPL text is available in `LICENSE.GPL3`.

libnymea-app is licensed under the GNU Lesser General Public License
version 3 (SPDX identifier: LGPL-3.0-or-later). The full LGPL v3 text 
can be found in `LICENSE.LGPL3`.
