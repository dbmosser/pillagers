# The text document

`export-text.ps1` writes every piece of text a player can read into
`PILLAGERS-text-vN.docx`, one row per distinct line, with an ID, and a
manifest JSON beside it that remembers where each line came from.

He edits the TEXT column in Word and sends the file back. Then:

    powershell -NoProfile -ExecutionPolicy Bypass -File tools\textdoc\import-text.ps1 -Doc "<his file>"
    (read the report, then add -Apply to write)

The importer replaces each changed line's original text everywhere it appears
in the game file, escapes quotes to match the literal it sits in, turns curly
quotes and dashes plain, and writes non-ASCII inside script strings as \u
escapes. After -Apply the usual build steps follow: rebuild the fixture, parse
check, corpus, VER bump, DESIGN entry, commit.

Limits: single-word labels inside the script are not exported unless they sit
in a name:, n:, label: or title: field; a line the filter mistook for text
(a font spec, a selector) can appear and should be left alone.
