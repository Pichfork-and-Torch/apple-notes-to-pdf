# Apple Notes to PDF

Double-click the app to export your Apple Notes into a PDF, an HTML file, and plain text.

## How to Use

Keep these files together in the same folder:

- `Apple Notes to PDF.app`
- `export-apple-notes.sh`
- `render-note-to-pdf.applescript`

Double-click **Apple Notes to PDF.app** to run.

The app will ask for necessary permissions the first time (Automation for Notes, Full Disk Access for attachments, and others). It will guide you to the correct System Settings.

It creates a dated folder on your Desktop with:
- `Apple_Notes_Master.pdf`
- `master.html` (open this in a browser and use Print → PDF for another version)
- `attachments/` folder (exported images and any audio/video you allowed)
- Plain text export as well

## Setting the Icon

If the app icon doesn't look right:
1. Right-click **Apple Notes to PDF.app** → Get Info
2. Drag `logo.png` onto the icon in the top left of the Get Info window

## Permissions

The app needs permission to read your Notes and export attachments. Grant them when prompted — the app will open the exact settings pane for you.

For a safe test, you can run from Terminal:
```
./export-apple-notes.sh --limit 5
```

## GitHub

https://github.com/Pichfork-and-Torch/Apple-Notes-to-PDF

Download the Release zip for the easiest experience.

## License

See LICENSE file.

Follow @SuddenlyJon on X 

