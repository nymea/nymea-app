include(config.pri)

TEMPLATE=subdirs

SUBDIRS = libnymea-common libnymea-app-core nymea-app
libnymea-app-core.depends = libnymea-common
nymea-app.depends = libnymea-app-core

withtests: {
    SUBDIRS += tests
    tests.depends = libnymea-app-core
}

# Building a Windows installer:
# Qt MinGW including the Qt Install Framework and MinGW runtime from Qt Installer
# Add QT_INSTALL_DIR/bin, QT_IFW_INSTALL_DIR/bin and MINGW_INSTALL_DIR/bin to PATH
# run "make wininstaller"
wininstaller.depends = nymea-app
equals(BRANDING, "") {
    APP_NAME = nymea-app
    PACKAGE_URN = io.guh.nymeaapp
    PACKAGE_DIR = $$shell_path($$PWD)\packaging\windows
    PACKAGE_NAME = nymea-app-win-installer
} else {
    APP_NAME = $${BRANDING}
    PACKAGE_URN = io.guh.$${APP_NAME}
    PACKAGE_NAME = $${BRANDING}-win-installer
    PACKAGE_DIR = $$shell_path($$PWD)\packaging\windows_$${APP_NAME}
}
OLDSTRING="<Version>.*</Version>"
NEWSTRING="<Version>$${APP_VERSION}</Version>"
wininstaller.commands += @powershell -Command \"(gc $${PACKAGE_DIR}\packages\\$${PACKAGE_URN}\meta\package.xml) -replace \'$${OLDSTRING}\',\'$${NEWSTRING}\' | sc $${PACKAGE_DIR}\packages\\$${PACKAGE_URN}\meta\package.xml\" &&
wininstaller.commands += rmdir /S /Q $${PACKAGE_DIR}\packages\\$${PACKAGE_URN}\data & mkdir $${PACKAGE_DIR}\packages\\$${PACKAGE_URN}\data &&
wininstaller.commands += copy $${PACKAGE_DIR}\packages\\$${PACKAGE_URN}\meta\logo.ico $${PACKAGE_DIR}\packages\\$${PACKAGE_URN}\data\logo.ico &&
CONFIG(debug,debug|release):wininstaller.commands += copy nymea-app\debug\nymea-app.exe $${PACKAGE_DIR}\packages\\$${PACKAGE_URN}\data\\$${APP_NAME}.exe &&
CONFIG(release,debug|release):wininstaller.commands += copy nymea-app\release\nymea-app.exe $${PACKAGE_DIR}\packages\\$${PACKAGE_URN}\data\\$${APP_NAME}.exe &&
!equals(SSL_LIBS, "") {
message("Deploying SSL libs from $${SSL_LIBS} to package.")
wininstaller.commands += copy $${SSL_LIBS}\libeay32.dll $${PACKAGE_DIR}\packages\\$${PACKAGE_URN}\data &&
wininstaller.commands += copy $${SSL_LIBS}\ssleay32.dll $${PACKAGE_DIR}\packages\\$${PACKAGE_URN}\data &&
}
wininstaller.commands += windeployqt --compiler-runtime --qmldir \"$${top_srcdir}\"\nymea-app\ui $${PACKAGE_DIR}\packages\\$${PACKAGE_URN}\data\ &&
wininstaller.commands += binarycreator -c $${PACKAGE_DIR}\config\config.xml -p $${PACKAGE_DIR}\packages\ $${PACKAGE_NAME}-$${APP_VERSION}
QMAKE_EXTRA_TARGETS += wininstaller


# OS X installer bundle
# Install XCode and Qt clang64, add qmake directory to PATH
# run "make osxbundle"
osxbundle.depends = nymea-app
osxbundle.commands += cd nymea-app && rm -f nymea-app.dmg nymea-app_writable.dmg nymea-app-osx-bundle.dmg || true &&
osxbundle.commands += hdiutil eject /Volumes/nymea-app || true &&
osxbundle.commands += macdeployqt nymea-app.app -qmldir=$$top_srcdir/nymea-app/ui -dmg &&
osxbundle.commands += hdiutil convert nymea-app.dmg -format UDRW -o nymea-app_writable.dmg &&
osxbundle.commands += hdiutil attach -readwrite -noverify nymea-app_writable.dmg && sleep 2 &&
osxbundle.commands += mkdir /Volumes/nymea-app/.background/ && cp $$top_srcdir/packaging/osx/installer.tiff /Volumes/nymea-app/.background/ &&
osxbundle.commands += ln -s /Applications /Volumes/nymea-app/Applications &&
osxbundle.commands += mv /Volumes/nymea-app/nymea-app.app /Volumes/nymea-app/nymea\:app.app &&
osxbundle.commands += osascript $$top_srcdir/packaging/osx/patchinstaller.sctp &&
osxbundle.commands += hdiutil eject /Volumes/nymea-app &&
osxbundle.commands += hdiutil convert nymea-app_writable.dmg -format UDRO -o ../nymea-app-osx-bundle-$${APP_VERSION}.dmg &&
osxbundle.commands += rm nymea-app.dmg nymea-app_writable.dmg
QMAKE_EXTRA_TARGETS += osxbundle


# Translations support
TRANSLATIONS += $$files($$absolute_path(nymea-app)/translations/*.ts, true)
lrelease.commands = lrelease $$TRANSLATIONS
lrelease-qmake_all.commands = lrelease $$TRANSLATIONS
QMAKE_EXTRA_TARGETS += lrelease lrelease-make_first lrelease-qmake_all lrelease-install_subtargets
nymea-app.depends += lrelease
