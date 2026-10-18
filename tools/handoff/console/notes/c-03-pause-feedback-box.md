# c-03-pause-feedback-box (shipped v30.37, cw-pausefb, d1a90622)

## What shipped
- Pause menu (raid pause box) has a "Report a problem" text box (#pausefb, 560x72, 1000 chars max) between Settings and Feedback.
- Type, then the Feedback button reads "Send feedback" (or Ctrl+Enter) -> note saved via the SAME fbSave as the Feedback window:
  note + version + time + where + screenshot (fbShot). Pause menu stays open, box clears. Empty box: button opens the Feedback window as before.
- Pad: D-pad steps onto the box, A focuses it (pad nav list includes #pausefb). ESC blurs it.
- Q61 kept: feedback line, Feedback button, Send play data untouched.
- Pictures: notes/shots/c-03-before/25-raid-pause-box-1080.jpg, notes/shots/c-03-after/25-raid-pause-box-1080.jpg

## WHERE NOTES LAND (for routing to helpers)
Collector running (tools\collector.ps1, port 8799, game served from localhost / 127.0.0.1 so LOCAL_DROP is set):
- C:\claudecode\dark raiders\exports\feedback-STAMP.txt   (note, version, time, where)
- C:\claudecode\dark raiders\exports\feedback-STAMP.png   (screenshot; a -2, -3 suffix if the stamp repeats)
Collector not running / not localhost (e.g. itch, or the party PC without the collector): browser downloads folder
- pillagers_feedback_STAMP.txt and pillagers_feedback_STAMP.png (the Downloads folder of that PC)
Embedded page (iframe): the note is copied to the clipboard instead ("Feedback copied").
Play data (Send play data) lands separately in exports\run-STAMP*.txt.
Session routing: look at exports\feedback-*.txt newer than the last routed one.
