$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'14.29',what:
'@ @'
  {v:'14.30',what:'the level is worked out from the XP when a profile loads: a save with 1,980 XP and a stored level of 1 loads through the real loader at level 4 (progression audit finding 3)',
   run:function(){
     if(typeof syncXpLevel!=='function'||!window.__applyLoaded) return 'SKIP: no level sync or loader in this build';
     var bad=[], snap=null;
     try{
       __topClear(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       var d=JSON.parse(JSON.stringify(snap));
       d.xp=1980; d.xpLevel=1;
       var want=1+Math.floor(Math.sqrt(1980/220));
       __applyLoaded(d);
       var q=__P();
       if(q.xp!==1980) return 'SKIP: the loader did not keep the XP of the save ('+q.xp+'), so the level cannot be judged';
       if(q.xpLevel!==want) bad.push('a save with 1,980 XP and a stored level of 1 loaded at level '+q.xpLevel+', not '+want);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(snap) __applyLoaded(snap); }catch(_r){} try{ __topClear(); __cleanProfile(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'14.29',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
