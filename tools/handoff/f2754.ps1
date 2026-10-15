$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

if ($s.Contains("  {v:'27.54',what:")) { throw "check 27.54 is in the fixture already" }

SubRx @'
  {v:'27.53',what:
'@ @'
  {v:'27.54',what:'his 2026-10-14 note (UI cleanup uic6): the credits and XP readout is hidden on the title, the run card, the pause box, the DEMO pages and the welcome pack, map select, Settings, key, party and terms windows, and still shows on the shop and the stash',
   run:function(){
     var tr=document.getElementById('topright');
     if(!tr) return 'SKIP: no credits readout in this build';
     var bad=[], held=[];
     function vis(){ return getComputedStyle(tr).visibility; }
     function probe(id,want){
       var el=document.getElementById(id); if(!el){ return; }
       var had=el.classList.contains('on'); if(!had) el.classList.add('on');
       try{ var v=vis(); if(want==='hidden'&&v!=='hidden') bad.push(id+' still shows the credits readout'); if(want==='shown'&&v==='hidden') bad.push(id+' hides the credits readout, which it spends'); }
       finally{ if(!had) el.classList.remove('on'); }
     }
     try{
       var on=[].slice.call(document.querySelectorAll('.modal.on,.outcome.on,.pausebox.on,#title.on,#attract.on,#hub.on'));
       on.forEach(function(e){ held.push(e); e.classList.remove('on'); });
       if(vis()==='hidden') return 'SKIP: the readout is hidden with nothing open here';
       ['title','outcome','pausebox','attract','welcomemodal','sectormodal','settingsmodal','keysmodal','partymodal','termsmodal'].forEach(function(id){ probe(id,'hidden'); });
       ['tradermodal','hub','opmodal','gamblemodal','barmodal','appearmodal'].forEach(function(id){ probe(id,'shown'); });
       return bad.length?bad.join('; '):null;
     } finally { held.forEach(function(e){ e.classList.add('on'); }); } }},
  {v:'27.53',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
