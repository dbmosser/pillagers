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

if ($s.Contains("  {v:'27.57',what:")) { throw "check 27.57 is in the fixture already" }

SubRx @'
  {v:'27.56',what:
'@ @'
  {v:'27.57',what:'his 2026-10-14 note (UI cleanup uic9): the line under THE UNDERCROFT says the stash and the runs and no longer prints credits and XP a second time (the corner readout shows them)',
   run:function(){
     if(typeof drawHubHUD!=='function'||typeof __hubEnter!=='function'||typeof __loop!=='function') return 'SKIP: no Undercroft floor here';
     var oFT=ctx.fillText, rec=[], i, st=null;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       var t=document.getElementById('title'); if(t) t.classList.remove('on');
       __hubEnter(); __loop(performance.now()); __loop(performance.now()+17);
       ctx.fillText=function(s){ rec.push(String(s)); return oFT.apply(this,arguments); };
       try{ __loop(performance.now()+34); } finally { delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; }
       for(i=0;i<rec.length;i++) if(rec[i].indexOf(' in stash')>=0) st=rec[i];
       if(!st) return 'SKIP: the floor line was not drawn';
       if(!/^\d+ items? in stash\s+\S\s+\d+ runs?$/.test(st)) return 'the line under the heading reads "'+st+'", not the stash and the runs alone';
       return null;
     } finally { try{ __topClear(); __cleanProfile(); }catch(_c){} } }},
  {v:'27.56',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
