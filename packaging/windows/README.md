# Windows packaging

The Windows installer is built with [Inno Setup](https://jrsoftware.org/isinfo.php) (`ISCC.exe`),
replacing the previous Qt Installer Framework (`binarycreator`) setup.

## One-time setup

1. Install Inno Setup and add its install directory (containing `ISCC.exe`) to `PATH` - same
   class of prerequisite as `windeployqt` already being on `PATH` today, not a new burden.
2. Set up your MSVC environment (e.g. `call "C:\Program Files (x86)\Microsoft Visual
   Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat"`).

`vc_redist.x64.exe` is downloaded and cached automatically by `make wininstaller` (see
`3rdParty/windows/vc_redist/README.md`) - no manual step needed as long as the build machine has
internet access.

## Building

```
qmake
make
make wininstaller
```

or, for an overlay branding:

```
qmake OVERLAY_PATH=..\nymea-app-energy-overlay BRANDING=chargebyte
make
make wininstaller
```

This produces `<PACKAGE_NAME>-win-installer-<APP_VERSION>.exe` under
`packaging/windows/packages/` (or the overlay branding's equivalent directory).

`packaging/windows/create-standalone-zip.ps1` still works unchanged afterward, and produces a
portable zip of the same staged app files (now also including `vc_redist.x64.exe`).

## How branding works

There is a single shared installer script, `packaging/windows/common/installer-common.iss`,
containing all installer logic (silent-install support, the Add/Remove-Programs registry entry,
optional desktop icon / Start Menu task, and the post-install `vc_redist.x64.exe` step). It is
never duplicated per branding.

Each branding supplies a small `installer.iss.in` file at
`packaging/windows/packages/<PACKAGE_URN>/meta/installer.iss.in` (or the overlay equivalent under
`brandings/<name>/packaging/windows/packages/<PACKAGE_URN>/meta/installer.iss.in`), which sets a
handful of ISPP `#define` tokens - most already sourced automatically from existing qmake
variables (`PACKAGE_URN`, `ORGANISATION_NAME`, `APPLICATION_NAME`, `PACKAGE_NAME`, `APP_VERSION`)
- and then `#include`s the shared logic file. Only `AppName` (the display name shown in the
installer UI/Start Menu) and the branding's asset filenames (`logo.ico`, `license-gpl.txt`) are
literal, hand-written values. qmake generates the final `installer.iss` from this template via
`QMAKE_SUBSTITUTES` (see the `win32 { }` block in `nymea-app/nymea-app/nymea-app.pro`) - it never
writes to the source-controlled `.in` file.

To add Windows packaging for a branding that doesn't have it yet, add:
- `packaging/windows/packages/<PACKAGE_URN>/meta/logo.ico`
- `packaging/windows/packages/<PACKAGE_URN>/meta/license-gpl.txt` (or an appropriate license)
- `packaging/windows/packages/<PACKAGE_URN>/meta/installer.iss.in` (copy an existing branding's
  and change `AppName`)

**Important contract:** `PACKAGE_URN` is used as the installer's `AppId` and must never change
for a branding once it has shipped. Inno Setup uses `AppId` (via the registry) to detect an
existing install and upgrade it in place when a user re-runs a newer installer; changing it would
make existing installs invisible to future upgrades (users would get a side-by-side install
instead of an in-place upgrade).

## Silent install / upgrade

```
<name>-win-installer-<version>.exe /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /TASKS="desktopicon,startmenuicon"
```

- `/TASKS="desktopicon,startmenuicon"` enables both the desktop icon and Start Menu shortcut
  (both default to checked in interactive installs too). Use `/TASKS=""` to select neither.
- Re-running a newer installer (silently or interactively) over an existing install upgrades it
  in place - no manual uninstall needed first - because `AppId` is held stable per branding.
- Uninstalling shows up correctly under Settings -> Apps / Control Panel -> Programs, using the
  `DisplayName`/`DisplayVersion`/`Publisher`/`UninstallString` values Inno Setup writes
  automatically to `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\<AppId>_is1`. The
  `_is1` suffix and the generated uninstaller filename (`unins000.exe`) are Inno Setup internals
  and don't affect what's shown in Control Panel/Settings, which read the `DisplayName` value.

## Known follow-up

`nymea`/`schrack` overlay brandings have no Windows packaging yet. Add
`packaging/windows/packages/<PACKAGE_URN>/meta/{logo.ico,license-gpl.txt,installer.iss.in}` for
them, following the `chargebyte`/`pce` examples, when needed.
