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

if ($s.Contains("  {v:'33.33',what:")) { throw "check 33.33 is in the fixture already" }

SubRx @'
  {v:'33.32',what:
'@ @'
  {v:'33.33',what:'the four experimental group names show with a real height on the experimental page',
   run:function(){
     var bad=[], modal=document.getElementById('settingsmodal'), list=document.getElementById('setlist'), oldCls, oldSub=SETSUB, gs, i, r;
     if(!modal||!list||typeof renderSettings!=='function') return 'SKIP: no settings page';
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       oldCls=modal.className; modal.classList.add('on'); SETSUB='exp'; renderSettings();
       gs=list.querySelectorAll('[data-exp-group]');
       if(gs.length!==4) return 'expected four group rows, found '+gs.length;
       for(i=0;i<gs.length;i++){
         r=gs[i].getBoundingClientRect();
         if(r.height<40) bad.push('group '+gs[i].getAttribute('data-exp-group')+' is '+Math.round(r.height)+'px tall');
         if(parseFloat(getComputedStyle(gs[i].querySelector('b')).fontSize)<14) bad.push('group name under 14px');
       }
       return bad.length?bad.join('; '):null;
     } finally { SETSUB=oldSub; try{ renderSettings(); }catch(_e){} modal.className=oldCls; }
   }},
  {v:'33.32',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
