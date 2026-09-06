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

# v12.15 CHECK, inserted before the v12.14 entry. The real setSafe and the
# real loader, with a frag, an ammo box and a medkit.
SubRx @'
  {v:'12.14',what:'the controls card no longer teaches an X (or pad Y) gun swap that has no handler; it names the belt keys instead (2026-09-06 first-ten-minutes audit)',
'@ @'
  {v:'12.15',what:'the safe pocket refuses a grenade and an ammo box, which cannot come home from it, still takes a medkit, and a saved pocket on a grenade is cleared on load (2026-09-06 menu audit)',
   run:function(){
     if(typeof setSafe!=='function'||!window.__P||!window.__applyLoaded) return 'SKIP: this fixture cannot reach the pocket or the loader';
     var bad=[], snap=null;
     try{
       __topClear(); __cleanProfile();
       snap=JSON.stringify(__P());   // the loader below replaces the profile; it is put back at the end
       var P=__P(); P.safe=null;
       var r1=setSafe('frag');
       if(!r1) bad.push('the pocket took a Frag Charge without a word');
       if(P.safe==='frag') bad.push('the pocket is saved on a Frag Charge');
       var r2=setSafe('ammobox');
       if(!r2) bad.push('the pocket took an Ammo Box without a word');
       if(P.safe==='ammobox') bad.push('the pocket is saved on an Ammo Box');
       var r3=setSafe('medkit');
       if(r3) bad.push('control: the pocket refused a Medkit ('+r3+')');
       if(P.safe!=='medkit') bad.push('control: the pocket did not keep the Medkit');
       __applyLoaded({credits:900,safe:'frag'});
       if(__P().safe==='frag') bad.push('a saved pocket on a Frag Charge survived the load');
       __applyLoaded({credits:900,safe:'medkit'});
       if(__P().safe!=='medkit') bad.push('control: a saved pocket on a Medkit did not survive the load ('+__P().safe+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(snap) __applyLoaded(JSON.parse(snap)); }catch(_rs){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'12.14',what:'the controls card no longer teaches an X (or pad Y) gun swap that has no handler; it names the belt keys instead (2026-09-06 first-ten-minutes audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
