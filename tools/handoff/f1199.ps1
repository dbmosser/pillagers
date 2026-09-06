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

# v11.99 CHECK, inserted before the v11.98 entry. The gate the floor asks
# before firing a station is read with the character screen on and off.
SubRx @'
  {v:'11.98',what:'the notes-logged line in the raid HUD is drawn below the corner credits and XP readout, not through it (2026-09-06 first-ten-minutes audit)',
'@ @'
  {v:'11.99',what:'the floor treats the character screen as a modal: hubModalOpen reads open while #title is on, so E, R, F and T no longer reach the stations behind it (2026-09-06 menu audit)',
   run:function(){
     if(typeof hubModalOpen!=='function'||!window.__hubEnter||!window.__showScreen) return 'SKIP: this fixture cannot reach the floor gate';
     var ttl=document.getElementById('title'); if(!ttl) return 'SKIP: no character screen element';
     var bad=[], wasOn=ttl.classList.contains('on');
     try{
       __topClear(); __cleanProfile();
       G=null; keys={}; __showScreen('hub'); __hubEnter();
       ttl.classList.remove('on');
       var pb=document.getElementById('pausebox'); if(pb) pb.classList.remove('on');
       if(hubModalOpen()) bad.push('control: with nothing open the gate already reads open, so it proves nothing');
       ttl.classList.add('on');
       if(!hubModalOpen()) bad.push('with the character screen on, the floor gate reads closed, so the stations behind it still take keys');
       ttl.classList.remove('on');
       if(hubModalOpen()) bad.push('control: with the character screen off again the gate still reads open');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(wasOn) ttl.classList.add('on'); else ttl.classList.remove('on'); }catch(_t){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'11.98',what:'the notes-logged line in the raid HUD is drawn below the corner credits and XP readout, not through it (2026-09-06 first-ten-minutes audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
