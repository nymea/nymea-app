TEMPLATE=subdirs

include(shared.pri)
message("APP_VERSION: $${APP_VERSION} ($${APP_REVISION})")

SUBDIRS = libnymea-app experiences nymea-app

experiences.depends = libnymea-app
nymea-app.depends = libnymea-app experiences

# withtests: {
#     SUBDIRS += tests
#     tests.depends = libnymea-app
# }

# Building a Windows installer:
# Make sure your environment has the toolchain you want (e.g. msvc17 64 bit) by executing the command:
# $ call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat"
# $ make wininstaller
win32: {
    wininstaller.depends = nymea-app

    OLDSTRING="<Version>.*</Version>"
    NEWSTRING="<Version>$${APP_VERSION}</Version>"
    wininstaller.commands += @powershell -Command \"(gc $${WIN_PACKAGE_DIR}\packages\\$${PACKAGE_URN}\meta\package.xml) -replace \'$${OLDSTRING}\',\'$${NEWSTRING}\' | sc $${WIN_PACKAGE_DIR}\packages\\$${PACKAGE_URN}\meta\package.xml\" &&
    wininstaller.commands += rmdir /S /Q $${WIN_PACKAGE_DIR}\packages\\$${PACKAGE_URN}\data & mkdir $${WIN_PACKAGE_DIR}\packages\\$${PACKAGE_URN}\data &&
    wininstaller.commands += copy $${WIN_PACKAGE_DIR}\packages\\$${PACKAGE_URN}\meta\logo.ico $${WIN_PACKAGE_DIR}\packages\\$${PACKAGE_URN}\data\logo.ico &&
    CONFIG(debug,debug|release):wininstaller.commands += copy nymea-app\debug\\$${APPLICATION_NAME}.exe $${WIN_PACKAGE_DIR}\packages\\$${PACKAGE_URN}\data\\$${APPLICATION_NAME}.exe &&
    CONFIG(release,debug|release):wininstaller.commands += copy nymea-app\release\\$${APPLICATION_NAME}.exe $${WIN_PACKAGE_DIR}\packages\\$${PACKAGE_URN}\data\\$${APPLICATION_NAME}.exe &&
    wininstaller.commands += copy \"$${top_srcdir}\"\3rdParty\windows\windows_openssl\*.dll $${WIN_PACKAGE_DIR}\packages\\$${PACKAGE_URN}\data &&
    wininstaller.commands += windeployqt --compiler-runtime --qmldir \"$${top_srcdir}\"\nymea-app\ui $${WIN_PACKAGE_DIR}\packages\\$${PACKAGE_URN}\data\ &&
    wininstaller.commands += binarycreator -c $${WIN_PACKAGE_DIR}\config\config.xml -p $${WIN_PACKAGE_DIR}\packages\ $${PACKAGE_NAME}-win-installer-$${APP_VERSION}
    message("Windows installer package directory: $${WIN_PACKAGE_DIR}")
    QMAKE_EXTRA_TARGETS += wininstaller
}



# OS X installer bundle
# Install XCode and Qt clang64, add qmake directory to PATH
# run "make osxbundle"
# Apple Development is useful for local development DMGs. App Store/TestFlight
# packages should pass a Mac App Store application/distribution identity.
# Note: We're dropping the QtWebEngineCore framework manually, as that's not app store compliant
# and we're using the WebView instead anyways. (IMHO a bug that macdeployqt -appstore-compliant even adds it)
equals(CODESIGN_IDENTITY, "") {
    CODESIGN_IDENTITY="Apple Development"
}
osxpackageapp.depends = nymea-app
osxpackageapp.commands += cd nymea-app && rm -f ../*.dmg ../*.pkg *.dmg &&
osxpackageapp.commands += bash $${MACX_PACKAGE_DIR}/macdeployqt-appstore.sh $${APPLICATION_NAME}.app $$top_srcdir/nymea-app/ui $$[QT_INSTALL_PLUGINS] &&
osxpackageapp.commands += bash $${MACX_PACKAGE_DIR}/codesign-appstore.sh $${APPLICATION_NAME}.app \"$$CODESIGN_IDENTITY\" $${MACX_PACKAGE_DIR}/$${APPLICATION_NAME}.entitlements
QMAKE_EXTRA_TARGETS += osxpackageapp

osxbundle.depends = osxpackageapp
osxbundle.commands += cd nymea-app && ( hdiutil eject /Volumes/$${APPLICATION_NAME} || true ) &&
osxbundle.commands += rm -f $${APPLICATION_NAME}_writable.dmg ../$${APPLICATION_NAME}-osx-bundle-$${APP_VERSION}.dmg &&
osxbundle.commands += hdiutil create $${APPLICATION_NAME}_writable.dmg -volname $${APPLICATION_NAME} -srcfolder $${APPLICATION_NAME}.app -format UDRW -ov &&
osxbundle.commands += hdiutil attach -readwrite -noverify $${APPLICATION_NAME}_writable.dmg && sleep 2 &&
osxbundle.commands += tar -xpf $${MACX_PACKAGE_DIR}/template.tar -C /Volumes/$${APPLICATION_NAME}/ &&
osxbundle.commands += hdiutil eject /Volumes/$${APPLICATION_NAME} &&
osxbundle.commands += hdiutil convert $${APPLICATION_NAME}_writable.dmg -format UDRO -o ../$${APPLICATION_NAME}-osx-bundle-$${APP_VERSION}.dmg &&
osxbundle.commands += rm $${APPLICATION_NAME}_writable.dmg
QMAKE_EXTRA_TARGETS += osxbundle

# Create a .pkg osx installer.
# App Store/TestFlight packages should pass the matching 3rd Party Mac Developer
# Installer identity. Developer ID distribution should use Developer ID
# Application/Installer identities instead.
equals(PRODUCTSIGN_IDENTITY, "") {
    PRODUCTSIGN_IDENTITY="3rd Party Mac Developer Installer"
}

osxinstaller.depends = osxpackageapp
osxinstaller.commands += cd nymea-app &&
osxinstaller.commands += productbuild --component $${APPLICATION_NAME}.app /Applications ../$${APPLICATION_NAME}-$${APP_VERSION}.pkg && cd .. &&
osxinstaller.commands += bash $${MACX_PACKAGE_DIR}/productsign-appstore.sh \"$$PRODUCTSIGN_IDENTITY\" $${APPLICATION_NAME}-$${APP_VERSION}.pkg $${APPLICATION_NAME}-signed-$${APP_VERSION}.pkg
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
        packaging/ubuntu/click/pushexec \
        packaging/ubuntu/click/urls.json

    INSTALLS += ubuntu_files
}

# Translations support
TRANSLATIONS += $$files($$absolute_path(nymea-app)/translations/*.ts, true)
!equals(OVERLAY_PATH, "") {
    exists($${OVERLAY_PATH}/translations.pri) {
        include($${OVERLAY_PATH}/translations.pri)
    } else {
        warning("Overlay translations not found: $${OVERLAY_PATH}/translations.pri. Using default translations only.")
    }
}

message("Translation files: $$TRANSLATIONS")

qtPrepareTool(LRELEASE, lrelease)

system("$$LRELEASE $$TRANSLATIONS")
lrelease.commands = $$LRELEASE $$TRANSLATIONS
QMAKE_EXTRA_TARGETS += lrelease
