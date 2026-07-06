; Shared Inno Setup installer logic, reused by every nymea-app branding.
;
; This file only contains installer *logic*. Per-branding identity and
; assets are set as ISPP #define tokens by the branding's generated
; installer.iss (produced from installer.iss.in via qmake QMAKE_SUBSTITUTES)
; before this file is #include'd. Do not add branding-specific values here -
; add them to the branding's installer.iss.in instead.
;
; Required #define tokens (set by the includer):
;   AppId, AppName, AppPublisher, AppExeName, AppVersion, TargetDirName,
;   LicenseFile, IconFile, MetaDir, SourceDir, OutputDir, OutputBaseFilename

[Setup]
AppId={#AppId}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
DefaultDirName={autopf}\{#TargetDirName}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
PrivilegesRequired=admin
UninstallDisplayIcon={app}\{#AppExeName}
OutputBaseFilename={#OutputBaseFilename}
OutputDir={#OutputDir}
SetupIconFile={#MetaDir}\{#IconFile}
LicenseFile={#MetaDir}\{#LicenseFile}
WizardStyle=modern
CloseApplications=yes
ArchitecturesInstallIn64BitMode=x64compatible
Compression=lzma2
SolidCompression=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

; Both tasks default to checked; silent installs can override with
; /TASKS="desktopicon,startmenuicon" or /TASKS="" to select none.
[Tasks]
Name: "desktopicon"; Description: "Create a &desktop icon"; GroupDescription: "Additional icons:"; Flags: checkedonce
Name: "startmenuicon"; Description: "Create a &Start Menu entry"; GroupDescription: "Additional icons:"; Flags: checkedonce

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs ignoreversion

[Icons]
Name: "{group}\{#AppName}"; Filename: "{app}\{#AppExeName}"; Tasks: startmenuicon
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExeName}"; Tasks: desktopicon

[Code]
procedure InstallVCRedist;
var
  ResultCode: Integer;
begin
  if not FileExists(ExpandConstant('{app}\vc_redist.x64.exe')) then
    Exit;
  if not Exec(ExpandConstant('{app}\vc_redist.x64.exe'), '/quiet /norestart', '', SW_SHOW, ewWaitUntilTerminated, ResultCode) then
  begin
    Log('Failed to launch vc_redist.x64.exe');
    Exit;
  end;
  { 0: success. 1638: an equal/newer version is already installed. 3010: success, reboot required. }
  if (ResultCode <> 0) and (ResultCode <> 1638) and (ResultCode <> 3010) then
    Log(Format('vc_redist.x64.exe returned unexpected exit code %d', [ResultCode]));
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
    InstallVCRedist;
end;
