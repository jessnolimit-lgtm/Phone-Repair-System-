#define MyAppName "PhoneRepairSystem"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "PhoneRepairsystem"
#define MyAppExeName "repair_shop_system.exe"

[Setup]
AppId={{PHONEFIX-APP-2026}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\PhoneFix
DefaultGroupName=PhoneFix
OutputDir=Output
OutputBaseFilename=PhoneFix-Setup
Compression=lzma
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64
PrivilegesRequired=admin
UninstallDisplayName=PhoneFix
SetupIconFile=windows\runner\resources\app_icon.ico
WizardStyle=modern

[Files]
Source: "C:\Users\tidul\OneDrive\Desktop\PhoneRepairSystem\repair_shop_system\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs
Source: "windows\runner\resources\app_icon.ico"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\PhoneFix"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\app_icon.ico"
Name: "{autodesktop}\PhoneFix"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\app_icon.ico"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Launch PhoneFix"; Flags: nowait postinstall skipifsilent