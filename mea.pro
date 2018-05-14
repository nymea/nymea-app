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
wininstaller.commands += rmdir /S /Q mea\release\out && mkdir mea\release\out &&
wininstaller.commands += copy mea\release\mea.exe mea\release\out\ &&
wininstaller.commands += windeployqt --qmldir mea\ui mea\release\out &&
BR=$$BRANDING
equals(BR, "") {
    wininstaller.commands += makensis /DBRANDING=guh packaging\windows\win-installer.nsi
} else {
    wininstaller.commands += makensis /DBRANDING=$$BR packaging\windows\win-installer.nsi
}
QMAKE_EXTRA_TARGETS += wininstaller

target.depends += wininstaller

