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
wininstaller.commands += rmdir /S /Q packaging\windows\packages\io.guh.mea\data & mkdir packaging\windows\packages\io.guh.mea\data &&
wininstaller.commands += copy mea\release\mea.exe packaging\windows\packages\io.guh.mea\data\ &&
wininstaller.commands += windeployqt --qmldir mea\ui packaging\windows\packages\io.guh.mea\data\ &&
BR=$$BRANDING
equals(BR, "") {
    wininstaller.commands += copy packaging\windows\packages\io.guh.mea\logo-guh.ico packaging\windows\packages\io.guh.mea\data\logo.ico &&
    wininstaller.commands += copy packaging\windows\packages\io.guh.mea\license-mea.txt packaging\windows\packages\io.guh.mea\meta\license.txt &&
    wininstaller.commands += binarycreator -c packaging\windows\config\config.xml -p packaging\windows\packages\ mea-win-installer
} else {
    wininstaller.commands += copy packaging\windows\packages\io.guh.mea\logo-$${BR}.ico packaging\windows\packages\io.guh.mea\data\logo.ico &&
    wininstaller.commands += copy packaging\windows\packages\io.guh.mea\license-$${BR}.txt packaging\windows\packages\io.guh.mea\meta\license.txt &&
    wininstaller.commands += binarycreator -c packaging\windows\config\config.xml -p packaging\windows\packages\ mea-$${BR}-win-installer
}
QMAKE_EXTRA_TARGETS += wininstaller

target.depends += wininstaller

