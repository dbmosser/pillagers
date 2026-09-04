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

# ---- THE RELOAD IS ARMED, NOT FIRED, AND THAT HAS TO BE VISIBLE.
# ---- The reload waits 400ms so the profile write lands first: storeSet can go
# ---- through a promise on a host that provides one, and a page that reloads
# ---- before the write completes loses the character it just restored, which is
# ---- the one failure this feature cannot have.
# ---- But a check cannot see a timer, and a timer it cannot see is a timer that
# ---- fires four hundred milliseconds later in the middle of the next check and
# ---- reloads the tab. So the arming is recorded where anything can read it, and
# ---- the handle is kept where a check can cancel it.
SubRx @'
    // Everything on the floor was built from the old profile, so it comes back
    // the way switching save does.
    try{ setTimeout(function(){ location.reload(); },400); }catch(_rl){ location.reload(); }
'@ @'
    // Everything on the floor was built from the old profile, so it comes back
    // the way switching save does. The wait is for the profile WRITE, which can
    // be a promise on a host that provides storage, and reloading before it
    // lands would lose the character that was just restored.
    RESTORE_RELOAD=1;
    try{ RESTORE_TIMER=setTimeout(function(){ RESTORE_RELOAD=2; location.reload(); },400); }
    catch(_rl){ RESTORE_RELOAD=2; location.reload(); }
'@
SubRx @'
function restoreApply(o){
'@ @'
// v11.04: 0 none, 1 armed, 2 fired. RESTORE_TIMER is the handle, so anything
// driving this without wanting the page to go can cancel it.
var RESTORE_RELOAD=0, RESTORE_TIMER=null;
function restoreApply(o){
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
