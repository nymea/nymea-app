TEMPLATE=subdirs

include(shared.pri)
message("APP_VERSION: $${APP_VERSION} ($${APP_REVISION})")


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


OLDSTRING="<Version>.*</Version>"
NEWSTRING="<Version>$${APP_VERSION}</Version>"
wininstaller.commands += @powershell -Command \"(gc $${WIN_PACKAGE_DIR}\packages\\$${PACKAGE_URN}\meta\package.xml) -replace \'$${OLDSTRING}\',\'$${NEWSTRING}\' | sc $${WIN_PACKAGE_DIR}\packages\\$${PACKAGE_URN}\meta\package.xml\" &&
wininstaller.commands += rmdir /S /Q $${WIN_PACKAGE_DIR}\packages\\$${WIN_PACKAGE_URN}\data & mkdir $${WIN_PACKAGE_DIR}\packages\\$${PACKAGE_URN}\data &&
wininstaller.commands += copy $${WIN_PACKAGE_DIR}\packages\\$${PACKAGE_URN}\meta\logo.ico $${WIN_PACKAGE_DIR}\packages\\$${PACKAGE_URN}\data\logo.ico &&
CONFIG(debug,debug|release):wininstaller.commands += copy nymea-app\debug\\$${APPLICATION_NAME}.exe $${WIN_PACKAGE_DIR}\packages\\$${PACKAGE_URN}\data\\$${APPLICATION_NAME}.exe &&
CONFIG(release,debug|release):wininstaller.commands += copy nymea-app\release\\$${APPLICATION_NAME}.exe $${WIN_PACKAGE_DIR}\packages\\$${PACKAGE_URN}\data\\$${APPLICATION_NAME}.exe &&
wininstaller.commands += copy \"$${top_srcdir}\"\3rdParty\windows\windows_openssl\*.dll $${WIN_PACKAGE_DIR}\packages\\$${PACKAGE_URN}\data &&
wininstaller.commands += windeployqt --compiler-runtime --qmldir \"$${top_srcdir}\"\nymea-app\ui $${WIN_PACKAGE_DIR}\packages\\$${WIN_PACKAGE_URN}\data\ &&
wininstaller.commands += binarycreator -c $${WIN_PACKAGE_DIR}\config\config.xml -p $${WIN_PACKAGE_DIR}\packages\ $${PACKAGE_NAME}-$${APP_VERSION}
win32:message("Windows installer package directory: $${WIN_PACKAGE_DIR}")
QMAKE_EXTRA_TARGETS += wininstaller



# OS X installer bundle
# Install XCode and Qt clang64, add qmake directory to PATH
# run "make osxbundle"
# Note: We're dropping the QtWebEngineCore framework manually, as that's not app store compliant
# and we're using the WebView instead anyways. (IMHO a bug that macdeployqt -appstore-compliant even adds it)
osxbundle.depends = nymea-app
osxbundle.commands += cd nymea-app && rm -f ../*.dmg ../*pkg *.dmg || true &&
osxbundle.commands += hdiutil eject /Volumes/$${APPLICATION_NAME} || true &&
osxbundle.commands += echo "Creating bundle" &&
osxbundle.commands += macdeployqt $${APPLICATION_NAME}.app -appstore-compliant -qmldir=$$top_srcdir/nymea-app/ui -dmg &&
osxbundle.commands += echo "Removing QtWebEngineCore from bundle" &&
osxbundle.commands += rm -r $${APPLICATION_NAME}.app/Contents/Frameworks/QtWebEngineCore.framework &&
osxbundle.commands += echo "Signing application bundle" &&
osxbundle.commands += codesign -s \"3rd Party Mac Developer Application\" --entitlements $${MACX_PACKAGE_DIR}/$${APPLICATION_NAME}.entitlements --deep $${APPLICATION_NAME}.app &&
osxbundle.commands += echo "converting to writable bundle" &&
osxbundle.commands += hdiutil convert $${APPLICATION_NAME}.dmg -format UDRW -o $${APPLICATION_NAME}_writable.dmg &&
osxbundle.commands += hdiutil attach -readwrite -noverify $${APPLICATION_NAME}_writable.dmg && sleep 2 &&
osxbundle.commands += tar -xpf $${MACX_PACKAGE_DIR}/template.tar -C /Volumes/$${APPLICATION_NAME}/ &&
osxbundle.commands += hdiutil eject /Volumes/$${APPLICATION_NAME} &&
osxbundle.commands += hdiutil convert $${APPLICATION_NAME}_writable.dmg -format UDRO -o ../$${APPLICATION_NAME}-osx-bundle-$${APP_VERSION}.dmg &&
osxbundle.commands += rm $${APPLICATION_NAME}.dmg #$${APPLICATION_NAME}_writable.dmg
QMAKE_EXTRA_TARGETS += osxbundle

# Create a .pkg osx installer.
osxinstaller.depends = osxbundle
osxinstaller.commands += cd nymea-app &&
osxinstaller.commands += productbuild --component nymea-app.app /Applications ../nymea-app-$${APP_VERSION}.pkg && cd .. &&
osxinstaller.commands += productsign -s \"3rd Party Mac Developer Installer\" nymea-app-$${APP_VERSION}.pkg nymea-app-signed-$${APP_VERSION}.pkg
QMAKE_EXTRA_TARGETS += osxinstaller

# Generic linux desktop
linux:!android: {
    desktopfile.files = $${PACKAGE_BASE_DIR}/linux-common/$${APPLICATION_NAME}.desktop
    desktopfile.path = /usr/share/applications/
    icons.files = $${PACKAGE_BASE_DIR}/linux-common/icons/
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
    desktopfile.files = $${PACKAGE_BASE_DIR}/linux/$${APPLICATION_NAME}.desktop
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
