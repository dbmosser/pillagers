$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# TAGS AND A NOTE CHOSEN AFTER COPY REPORT WERE DROPPED. Copy report commits
# the run first (v10.65, so the pasted report holds the raid he just played),
# and the commit nulls pendingRun. Anything he tags or types AFTER that, and
# then confirms with Log run and return, hits the early return: the row is
# already written, so it keeps the tags it had at Copy time and the note is
# lost. The comment on ocCommit promised the late tags would be "patched onto
# the already written row"; nothing did. Now the committed row is remembered
# for the life of the card, and a second commit patches tags and note onto it
# and re-sends the report when they changed.
SubRx @'
var pendingRun=null,selTags=[];
'@ @'
var pendingRun=null,selTags=[],committedRun=null;   // v11.57: the row Copy report wrote, for late tags
'@
SubRx @'
function ocCommit(){
  if(!pendingRun) return false;
'@ @'
function ocCommit(){
  if(!pendingRun){
    // v11.57: the commit already happened (Copy report does it first). Tags and
    // a note chosen since then land on the row it wrote, and the report goes
    // out again with them, instead of being thrown away at the early return.
    if(committedRun){
      var _lt=selTags.slice(), _ln=document.getElementById('oc_note');
      _ln=_ln?_ln.value.trim():'';
      if(_lt.join('|')!==(committedRun.tags||[]).join('|')||_ln!==(committedRun.note||'')){
        committedRun.tags=_lt; committedRun.note=_ln;
        saveProfile(); autoExport();
      }
    }
    return false;
  }
'@
SubRx @'
  commitRun(pendingRun);
  pendingRun=null;
'@ @'
  commitRun(pendingRun);
  committedRun=pendingRun;
  pendingRun=null;
'@

# STAMPS.
SubRx @'
var VER='11.56';
'@ @'
var VER='11.57';
'@
SubRx @'
var WHATSNEW_VER='11.56';
'@ @'
var WHATSNEW_VER='11.57';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'TAGS AND NOTES ADDED AFTER COPY REPORT ARE KEPT. Copy report logs the run first so the paste holds it, and anything you tagged or typed after that was thrown away when you pressed Log run and return. It lands on the run now, and the report goes out again with it.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.56:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.56 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.56:[^']*'",{ param($m) "now:'v11.57: tags and a note chosen after Copy report were dropped. Copy report commits the run first and nulls pendingRun, so Log run and return afterwards hit the early return and the row kept the tags it had at Copy time; the ocCommit comment promised a patch onto the written row that did not exist. The committed row is remembered for the life of the card and a later commit patches tags and note onto it and re-sends the report when they changed. From the v11.46 audit, P1.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
