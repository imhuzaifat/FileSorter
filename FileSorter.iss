; ====================================================================
;  FileSorter installer script (Inno Setup 6, free: jrsoftware.org)
;
;  Put these 3 files in the same folder:
;    FileSorter.bat   FileSorter.ico   FileSorter.iss
;  Open FileSorter.iss in Inno Setup and press Ctrl+F9 (Compile).
;  The installer appears in a new "Output" folder as FileSorter_Setup.exe
; ====================================================================

#define AppName "FileSorter"
#define AppVersion "1.0.0"
#define AppPublisher "Huzaifa"

[Setup]
AppId={{8F3A2C71-5B64-4D2E-9A1F-7C0E4B6D2A15}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
DefaultDirName={localappdata}\{#AppName}
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
OutputDir=Output
OutputBaseFilename=FileSorter_Setup
SetupIconFile=FileSorter.ico
UninstallDisplayIcon={app}\FileSorter.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Tasks]
Name: "contextmenu"; Description: "Add ""Sort with FileSorter"" to the right-click menu of folders"
Name: "desktopicon"; Description: "Create a desktop shortcut"; Flags: unchecked

[Files]
Source: "FileSorter.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "FileSorter.ico"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\{#AppName}"; Filename: "{app}\FileSorter.bat"; IconFilename: "{app}\FileSorter.ico"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\FileSorter.bat"; IconFilename: "{app}\FileSorter.ico"; Tasks: desktopicon

[Registry]
; Right-click ON a folder
Root: HKCU; Subkey: "Software\Classes\Directory\shell\FileSorter"; ValueType: string; ValueName: ""; ValueData: "Sort with FileSorter"; Flags: uninsdeletekey; Tasks: contextmenu
Root: HKCU; Subkey: "Software\Classes\Directory\shell\FileSorter"; ValueType: string; ValueName: "Icon"; ValueData: "{app}\FileSorter.ico"; Tasks: contextmenu
Root: HKCU; Subkey: "Software\Classes\Directory\shell\FileSorter\command"; ValueType: string; ValueName: ""; ValueData: """{app}\FileSorter.bat"" ""%1"""; Tasks: contextmenu

; Right-click on the EMPTY SPACE inside an open folder
Root: HKCU; Subkey: "Software\Classes\Directory\Background\shell\FileSorter"; ValueType: string; ValueName: ""; ValueData: "Sort this folder with FileSorter"; Flags: uninsdeletekey; Tasks: contextmenu
Root: HKCU; Subkey: "Software\Classes\Directory\Background\shell\FileSorter"; ValueType: string; ValueName: "Icon"; ValueData: "{app}\FileSorter.ico"; Tasks: contextmenu
Root: HKCU; Subkey: "Software\Classes\Directory\Background\shell\FileSorter\command"; ValueType: string; ValueName: ""; ValueData: """{app}\FileSorter.bat"" ""%V"""; Tasks: contextmenu
