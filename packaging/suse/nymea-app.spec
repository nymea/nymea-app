#
# spec file for package nymea-app
#

Name:           nymea-app
Version:        1
Release:        0
Summary:        QtQuick nymea client application
License:        GPL-3.0-only
URL:            https://nymea.io
Source:         %{name}.tar.xz

BuildRequires:  libqt5-qtbase-common-devel
BuildRequires:  libavahi-devel
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Charts)
BuildRequires:  pkgconfig(Qt5Svg)
BuildRequires:  pkgconfig(Qt5WebSockets)
BuildRequires:  pkgconfig(Qt5WebView)
BuildRequires:  pkgconfig(Qt5Bluetooth)
BuildRequires:  pkgconfig(Qt5Nfc)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  pkgconfig(Qt5Network)
BuildRequires:  pkgconfig(Qt5QuickControls2)
BuildRequires:  libQt5Gui-private-headers-devel

#qml deps
Requires:        qt5qmlimport(QtGraphicalEffects.1)
Requires:        qt5qmlimport(Qt.labs.settings.1)
Requires:        qt5qmlimport(Qt.labs.folderlistmodel.2)
Requires:        qt5qmlimport(Qt.labs.calendar.1)
Requires:        qt5qmlimport(QtQuick.2)
Requires:        qt5qmlimport(QtQuick.Window.2)
Requires:        qt5qmlimport(QtQuick.Controls.2)
Requires:        qt5qmlimport(QtQuick.Layouts.1)
Requires:        qt5qmlimport(QtCharts.2)

%description
A client app for nymea
This package will install nymea:app, the client app 
and main user interface for nymea:core.


#%%package nymea-app-kiosk-x11
#Requires:	nymea-app
#Requires:	openbox
#Requires:	lightdm
#Requires:	qt5qmlimport(QtQuick.VirtualKeyboard.Settings.2)
#Requires:	xinit
#Provides:	lightdm-greeter
#Conflicts:	nymea-app-kiosk-wayland

#%%description nymea-app-kiosk-x11
#Run nymea:app in kiosk mode
# This package will install nymea:app in kiosk mode on your machine (using X11 and lightdm).

#%%package nymea-app-kiosk-wayland
#Conflicts:	nymea-app-kiosk-x11
#Conflicts:	lightdm
#Requires:	nymea-app
#Requires:	qt5qmlimport(QtQuick.VirtualKeyboard.Settings.2)

#%%description nymea-app-kiosk-wayland
#Run nymea:app in kiosk mode
# This package will install nymea:app in kiosk mode on your machine (using wayland).

%prep
%setup -n nymea-app 
mkdir build

%build
cd build
qmake-qt5 QMAKE_CFLAGS+="%optflags" QMAKE_CXXFLAGS+="%optflags" QMAKE_STRIP="/bin/true" ..
%make_build

%install
cd build
make install INSTALL_ROOT="%buildroot"

%files
%license LICENSES
%doc README.md
/usr/bin/nymea-app
/usr/share/applications/nymea-app.desktop
/usr/share/icons/*

#%%files nymea-app-kiosk-x11


#%%files nymea-app-kiosk-wayland
#packaging/linux-common/nymea-app-kiosk.service /lib/systemd/system/
#packaging/linux-common/udev/90-pi-backlight.rules /lib/udev/rules.d/


%changelog
