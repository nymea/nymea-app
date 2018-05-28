TEMPLATE=subdirs

SUBDIRS = libnymea-common mea
libnymea-common.subdir = libnymea-common
mea.subdir = mea

mea.depends = libnymea-common


# Building a Windows installer:
# Install Visual Studio, Qt and NSIS on Windows. Make sure NSIS is in your path.
# Use QtCreator to create a release build, make sure to *disable* shadow build.
# After building, run "make wininstaller"
wininstaller.depends = mea
BR=$$BRANDING
equals(BR, "") {
    APP_NAME = mea
    PACKAGE_DIR = packaging\windows
    PACKAGE_NAME = mea-win-installer
} else {
    APP_NAME = $${BR}
    PACKAGE_NAME = $${BR}-win-installer
    PACKAGE_DIR = packaging\windows_$${APP_NAME}
}
wininstaller.commands += rmdir /S /Q $${PACKAGE_DIR}\packages\io.guh.$${APP_NAME}\data & mkdir $${PACKAGE_DIR}\packages\io.guh.$${APP_NAME}\data &&
wininstaller.commands += copy $${PACKAGE_DIR}\packages\io.guh.$${APP_NAME}\meta\logo.ico $${PACKAGE_DIR}\packages\io.guh.$${APP_NAME}\data\logo.ico &&
wininstaller.commands += copy mea\release\mea.exe $${PACKAGE_DIR}\packages\io.guh.$${APP_NAME}\data\\$${APP_NAME}.exe &&
wininstaller.commands += windeployqt --compiler-runtime --qmldir mea\ui $${PACKAGE_DIR}\packages\io.guh.$${APP_NAME}\data\ &&
wininstaller.commands += binarycreator -c $${PACKAGE_DIR}\config\config.xml -p $${PACKAGE_DIR}\packages\ $${PACKAGE_NAME}

QMAKE_EXTRA_TARGETS += wininstaller

target.depends += wininstaller

