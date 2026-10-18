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

if ($s.Contains("  {v:'31.54',what:")) { throw "check 31.54 is in the fixture already" }

SubRx @'
  {v:'31.53',what:
'@ @'
  {v:'31.54',what:'Pad buttons table is wide, the pointed Settings row has an accent line, lists fade over 48px',
   run:function(){
     var bad=[], kl, w, row, cs, mk, padWas=document.body.classList.contains('padon');
     __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     try{
       document.body.classList.remove('padon');
       keysOpen(false); kl=document.getElementById('keyslist');
       if(!kl) bad.push('no keys list');
       else{
         w=kl.getBoundingClientRect().width;
         if(!(w>1200)) bad.push('the keys table is only '+Math.round(w)+' wide');
         if(parseFloat(getComputedStyle(kl).paddingBottom)<47) bad.push('keys list has less than 48px under the last row: '+getComputedStyle(kl).paddingBottom);
       }
       try{ document.getElementById('keysmodal').classList.remove('on'); }catch(_k){}
       openSettings('display');
       row=document.querySelector('#setlist .row:not(.setjump)');
       if(!row) bad.push('no settings row');
       else{
         row.classList.add('dshow'); cs=getComputedStyle(row);
         if(cs.boxShadow.replace(/\s/g,'').split('inset').length<3) bad.push('the pointed row has no accent line: '+cs.boxShadow);
         row.classList.remove('dshow');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var q=document.getElementById('settingsmodal'); if(q) q.classList.remove('on'); q=document.getElementById('keysmodal'); if(q) q.classList.remove('on'); }catch(_k){} try{ __topClear(); }catch(_c){} document.body.classList.toggle('padon',padWas); }
     return bad.length?bad.join('; '):null; }},
  {v:'31.53',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
