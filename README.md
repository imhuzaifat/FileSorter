# FileSorter

A small Windows tool that cleans up any messy folder by sorting files into folders based on their type. Great for Downloads folders, recovered hard drive data, USB dumps, and old backups.

## Features

- Works on any folder: paste a path, drag a folder in, or right-click it
- Scan just one folder, or every subfolder too
- Two sorting styles:
  - By extension: `jpg`, `pdf`, `docx`
  - By category: `Images`, `Documents`, `Videos`, `Audio`, `Archives`, `Code`, `Programs`
- Dry run mode to preview everything before any file moves
- Undo the last sort
- Duplicate names are renamed (`photo_1.jpg`), never overwritten
- Skips half-finished downloads (`crdownload`, `part`, `tmp`) and hidden/system files
- Safe with strange filenames (`!`, `&`, `^`, spaces)
- Refuses to run on system folders like Windows or Program Files

## Install

1. Go to the **Releases** page of this repo
2. Download `FileSorter_Setup.exe`
3. Run it and choose whether you want the right-click menu and a desktop shortcut

Windows may show a "Windows protected your PC" screen because the installer is not code signed. Click **More info**, then **Run anyway**.

No install needed if you prefer: just download `FileSorter.bat` and double-click it.

## How to use

### Easy way

1. Right-click a folder and choose **Sort with FileSorter** (or open FileSorter from the Start Menu)
2. Answer the questions: scan depth, grouping style, extensions to skip, dry run
3. Done

On Windows 11 the right-click entry is under **Show more options** (or hold Shift while right-clicking).

### Command line

```
FileSorter.bat "D:\Downloads" /top /cat /dry
```

Using any flag skips the questions.

| Flag | What it does |
|------|--------------|
| `/top` | Only files directly inside the folder |
| `/sub` | Include all subfolders (default) |
| `/ext` | Folders by extension (default) |
| `/cat` | Folders by category |
| `/dry` | Preview only, nothing is changed |
| `/keepempty` | Do not delete empty folders afterwards |
| `/undo` | Undo the last sort in that folder |
| `/?` | Show help |

## Categories

| Folder | Extensions |
|--------|-----------|
| Images | jpg, jpeg, png, gif, bmp, webp, tif, tiff, svg, ico, heic, raw, cr2, nef, psd |
| Documents | pdf, doc, docx, txt, rtf, odt, xls, xlsx, csv, ppt, pptx, odp, ods, md, epub |
| Videos | mp4, mkv, avi, mov, wmv, flv, webm, m4v, 3gp, mpg, mpeg |
| Audio | mp3, wav, flac, aac, ogg, m4a, wma |
| Archives | zip, rar, 7z, tar, gz, bz2, iso |
| Code | c, cpp, h, hpp, py, java, js, ts, html, css, php, cs, asm, sh, bat, json, xml, sql |
| Programs | exe, msi, apk, dmg |
| Other\\ext | anything else, kept in its own extension folder |

## Undo

Every real run saves `_SortLog.txt` inside the sorted folder. Run FileSorter again and choose **Undo**, or use the `/undo` flag. Only the most recent run in a folder can be undone.

## Tips

- Always do a dry run first on a new folder
- Try it on a small test folder before using it on important data
- When sorting by subfolders, everything is flattened: `Recovered\old\stuff\a.jpg` becomes `Recovered\jpg\a.jpg`

## Uninstall

Settings, then Apps, then FileSorter, then Uninstall. This also removes the right-click menu entries.

## Build the installer yourself

1. Install [Inno Setup 6](https://jrsoftware.org/isinfo.php)
2. Open `FileSorter.iss`
3. Press `Ctrl+F9`
4. The installer appears in the `Output` folder

## License

MIT, see the `LICENSE` file.

## Author

Made by Huzaifa.
