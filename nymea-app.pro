include(config.pri)
message("APP_VERSION: $${APP_VERSION} ($${APP_REVISION})")
TEMPLATE=subdirs

SUBDIRS = libnymea-app nymea-app
nymea-app.depends = libnymea-app

withtests: {
    SUBDIRS += tests
    tests.depends = libnymea-app
}

# Building a Windows installer:
# Make sure your environment has the toolchain you want (e.g. msvc17 64 bit) by executing the command:
# $ call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat"
# $ make wininstaller
wininstaller.depends = nymea-app
!equals(OVERLAY_PATH, ""):!equals(BRANDING, "") {
    PACKAGE_BASE_DIR = $${OVERLAY_PATH}\packaging
} else {
    PACKAGE_BASE_DIR = $$shell_path($$PWD)\packaging
}
equals(BRANDING, "") {
    APP_NAME = nymea-app
    PACKAGE_URN = io.nymea.nymeaapp
    PACKAGE_NAME = nymea-app-win-installer
    PACKAGE_DIR = $${PACKAGE_BASE_DIR}\windows
} else {
    APP_NAME = $${BRANDING}
    PACKAGE_URN = io.nymea.$${APP_NAME}
    PACKAGE_NAME = $${BRANDING}-win-installer
    PACKAGE_DIR = $${PACKAGE_BASE_DIR}\windows_$${APP_NAME}
}
OLDSTRING="<Version>.*</Version>"
NEWSTRING="<Version>$${APP_VERSION}</Version>"
wininstaller.commands += @powershell -Command \"(gc $${PACKAGE_DIR}\packages\\$${PACKAGE_URN}\meta\package.xml) -replace \'$${OLDSTRING}\',\'$${NEWSTRING}\' | sc $${PACKAGE_DIR}\packages\\$${PACKAGE_URN}\meta\package.xml\" &&
wininstaller.commands += rmdir /S /Q $${PACKAGE_DIR}\packages\\$${PACKAGE_URN}\data & mkdir $${PACKAGE_DIR}\packages\\$${PACKAGE_URN}\data &&
wininstaller.commands += copy $${PACKAGE_DIR}\packages\\$${PACKAGE_URN}\meta\logo.ico $${PACKAGE_DIR}\packages\\$${PACKAGE_URN}\data\logo.ico &&
CONFIG(debug,debug|release):wininstaller.commands += copy nymea-app\debug\nymea-app.exe $${PACKAGE_DIR}\packages\\$${PACKAGE_URN}\data\\$${APP_NAME}.exe &&
CONFIG(release,debug|release):wininstaller.commands += copy nymea-app\release\nymea-app.exe $${PACKAGE_DIR}\packages\\$${PACKAGE_URN}\data\\$${APP_NAME}.exe &&
wininstaller.commands += copy \"$${top_srcdir}\"\windows_openssl\*.dll $${PACKAGE_DIR}\packages\\$${PACKAGE_URN}\data &&
wininstaller.commands += windeployqt --compiler-runtime --qmldir \"$${top_srcdir}\"\nymea-app\ui $${PACKAGE_DIR}\packages\\$${PACKAGE_URN}\data\ &&
wininstaller.commands += binarycreator -c $${PACKAGE_DIR}\config\config.xml -p $${PACKAGE_DIR}\packages\ $${PACKAGE_NAME}-$${APP_VERSION}
win32:message("Windows installer package directory: $${PACKAGE_DIR}")
QMAKE_EXTRA_TARGETS += wininstaller



# OS X installer bundle
# Install XCode and Qt clang64, add qmake directory to PATH
# run "make osxbundle"
# Note: We're dropping the QtWebEngineCore framework manually, as that's not app store compliant
# and we're using the WebView instead anyways. (IMHO a bug that macdeployqt -appstore-compliant even adds it)
osxbundle.depends = nymea-app
osxbundle.commands += cd nymea-app && rm -f ../*.dmg ../*pkg *.dmg || true &&
osxbundle.commands += hdiutil eject /Volumes/nymea-app || true &&
osxbundle.commands += macdeployqt nymea-app.app -appstore-compliant -qmldir=$$top_srcdir/nymea-app/ui -dmg &&
osxbundle.commands += rm -r nymea-app.app/Contents/Frameworks/QtWebEngineCore.framework &&
osxbundle.commands += codesign -s \"3rd Party Mac Developer Application\" --entitlements $$top_srcdir/packaging/osx/nymea-app.entitlements --deep nymea-app.app &&
osxbundle.commands += hdiutil convert nymea-app.dmg -format UDRW -o nymea-app_writable.dmg &&
osxbundle.commands += hdiutil attach -readwrite -noverify nymea-app_writable.dmg && sleep 2 &&
osxbundle.commands += mv /Volumes/nymea-app/nymea-app.app /Volumes/nymea-app/nymea\:app.app &&
osxbundle.commands += tar -xpf $$top_srcdir/packaging/osx/template.tar -C /Volumes/nymea-app/ &&
osxbundle.commands += hdiutil eject /Volumes/nymea-app &&
osxbundle.commands += hdiutil convert nymea-app_writable.dmg -format UDRO -o ../nymea-app-osx-bundle-$${APP_VERSION}.dmg &&
osxbundle.commands += rm nymea-app.dmg nymea-app_writable.dmg
QMAKE_EXTRA_TARGETS += osxbundle

# Create a .pkg osx installer.
osxinstaller.depends = osxbundle
osxinstaller.commands += cd nymea-app &&
osxinstaller.commands += productbuild --component nymea-app.app /Applications ../nymea-app-$${APP_VERSION}.pkg && cd .. &&
osxinstaller.commands += productsign -s \"3rd Party Mac Developer Installer\" nymea-app-$${APP_VERSION}.pkg nymea-app-signed-$${APP_VERSION}.pkg
QMAKE_EXTRA_TARGETS += osxinstaller

# Generic linux desktop
linux:!android: {
desktopfile.files = packaging/linux-common/nymea-app.desktop
desktopfile.path = /usr/share/applications/
icons.files = packaging/linux-common/icons/
icons.path = /usr/share/
INSTALLS += desktopfile icons
}

android: {
    message("Android package source dir $${ANDROID_PACKAGE_SOURCE_DIR}")
    SUBDIRS += androidservice
    androidservice.depends = libnymea-app

    NYMEA_APP_ROOT_PROPERTY="nymeaAppRoot=$${top_srcdir}"
    no-firebase: FIREBASE_PROPERTY="useFirebase=false"
    else: FIREBASE_PROPERTY="useFirebase=true"
    write_file($${ANDROID_PACKAGE_SOURCE_DIR}/nymeaapp.properties, NYMEA_APP_ROOT_PROPERTY)
    write_file($${ANDROID_PACKAGE_SOURCE_DIR}/nymeaapp.properties, FIREBASE_PROPERTY, append)
}

# Linux desktop (snap package)
snap: {
desktopfile.files = packaging/linux/nymea-app.desktop
desktopfile.path = /usr/share/applications/
INSTALLS += desktopfile
}

ubports: {
ubuntu_files.path = /
ubuntu_files.files += \
    packaging/ubuntu/click/manifest.json \
    packaging/ubuntu/click/nymea-app.apparmor \
    packaging/ubuntu/click/nymea-app.desktop \
    packaging/ubuntu/click/appicon.svg \
    packaging/ubuntu/click/push.json \
    packaging/ubuntu/click/push-apparmor.json \
    packaging/ubuntu/click/pushexec

INSTALLS += ubuntu_files
}

# Translations support
TRANSLATIONS += $$files($$absolute_path(nymea-app)/translations/*.ts, true)
system("lrelease $$TRANSLATIONS")
lrelease.commands = lrelease $$TRANSLATIONS
QMAKE_EXTRA_TARGETS += lrelease
