TEMPLATE=subdirs

SUBDIRS = libnymea-common libmea-core mea
libmea-core.depends = libnymea-common
mea.depends = libmea-core

withtests: {
    SUBDIRS += tests
    tests.depends = libmea-core
}

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
SSLL=$$SSL_LIBS
!equals(SSLL, "") {
message("Deploying SSL libs from $${SSLL} to package.")
wininstaller.commands += copy $${SSLL}\libeay32.dll $${PACKAGE_DIR}\packages\io.guh.$${APP_NAME}\data &&
wininstaller.commands += copy $${SSLL}\ssleay32.dll $${PACKAGE_DIR}\packages\io.guh.$${APP_NAME}\data &&
}
wininstaller.commands += windeployqt --compiler-runtime --qmldir mea\ui $${PACKAGE_DIR}\packages\io.guh.$${APP_NAME}\data\ &&
wininstaller.commands += binarycreator -c $${PACKAGE_DIR}\config\config.xml -p $${PACKAGE_DIR}\packages\ $${PACKAGE_NAME}

QMAKE_EXTRA_TARGETS += wininstaller

TRANSLATIONS += $$files(mea/translations/*.ts, true)
lrelease.commands = lrelease $$_FILE_
lrelease-qmake_all.commands = lrelease $$_FILE_
QMAKE_EXTRA_TARGETS += lrelease lrelease-make_first lrelease-qmake_all lrelease-install_subtargets

mea.depends += lrelease
