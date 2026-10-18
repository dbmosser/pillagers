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

if ($s.Contains("  {v:'29.98',what:")) { throw "check 29.98 is in the fixture already" }

SubRx @'
  {v:'29.97',what:
'@ @'
  {v:'29.98',what:'the header X buttons are ghosts with a tx-2 glyph, the Keys section labels are tx-1',
   run:function(){
     var bad=[], x, cs, k, sec, tx1, probe, padWas=document.body.classList.contains('padon');
     __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     try{
       document.body.classList.remove('padon');
       openSettings('display');
       x=document.getElementById('closesettings'); cs=x?getComputedStyle(x):null;
       if(!cs) bad.push('no settings X');
       else {
         if(cs.backgroundColor!=='rgba(0, 0, 0, 0)') bad.push('the settings X has a fill: '+cs.backgroundColor);
         if(cs.borderTopColor!=='rgb(74, 82, 87)') bad.push('the settings X border is '+cs.borderTopColor+', not line-hi');
         var gl=getComputedStyle(x,'::after').backgroundImage;
         if(gl.indexOf('rgb(170, 164, 152)')<0) bad.push('the X glyph is not tx-2: '+gl.slice(0,120));
       }
       document.getElementById('settingsmodal').classList.remove('on'); try{ __topClear(); }catch(_c){}
       keysOpen(false); sec=document.querySelector('#keyslist .keysec');
       if(!sec) bad.push('no Keys section label');
       else {
         probe=document.createElement('i'); probe.style.color='var(--tx-1)'; document.body.appendChild(probe); tx1=getComputedStyle(probe).color; probe.remove();
         if(getComputedStyle(sec).color!==tx1) bad.push('the Keys section label is '+getComputedStyle(sec).color+', not tx-1 '+tx1);
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var q=document.getElementById('settingsmodal'); if(q) q.classList.remove('on'); q=document.getElementById('keysmodal'); if(q) q.classList.remove('on'); }catch(_k){} try{ __topClear(); }catch(_c){} document.body.classList.toggle('padon',padWas); }
     return bad.length?bad.join('; '):null; }},
  {v:'29.97',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
