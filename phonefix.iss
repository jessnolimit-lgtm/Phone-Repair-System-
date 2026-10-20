#define MyAppName "Fixora"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Fixora"
#define MyAppExeName "repair_shop_system.exe"

[Setup]
AppId={{PHONEFIX-APP-2026}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\Fixora
DefaultGroupName=Fixora
OutputDir=Output
OutputBaseFilename=Fixora-Setup
Compression=lzma
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64
PrivilegesRequired=admin
UninstallDisplayName=Fixora
SetupIconFile=windows\runner\resources\app_icon.ico
WizardStyle=modern

[Files]
Source: "C:\Users\tidul\OneDrive\Desktop\PhoneRepairSystem\repair_shop_system\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs
Source: "windows\runner\resources\app_icon.ico"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\Fixora"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\app_icon.ico"
Name: "{autodesktop}\Fixora"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\app_icon.ico"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Launch Fixora"; Flags: nowait postinstall skipifsilent