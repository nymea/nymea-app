# Visual C++ Redistributable

The Windows installer (`packaging/windows/common/installer-common.iss`) silently installs
`vc_redist.x64.exe` after copying the app files.

This binary is **not checked into git** (large, official Microsoft-distributed binary). Instead,
`make wininstaller` downloads and caches it automatically here via
`packaging/windows/ensure-vcredist.ps1`, from Microsoft's stable "latest supported" URL
(https://aka.ms/vs/17/release/vc_redist.x64.exe - per Microsoft, this runtime is compatible with
apps built by any MSVC toolset from VS2015 through the current version). This requires internet
access on the build machine; the download is skipped if `vc_redist.x64.exe` already exists here.

For offline/air-gapped builds, pre-place the file manually at:

```
3rdParty/windows/vc_redist/vc_redist.x64.exe
```

(download from https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist, x64) to
skip the automatic download step.

Note: prior to this change, this file was referenced by the installer but never actually
provided by the build or documented anywhere - it was an undocumented manual prerequisite.
