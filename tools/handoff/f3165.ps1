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

if ($s.Contains("  {v:'31.65',what:")) { throw "check 31.65 is in the fixture already" }

SubRx @'
  {v:'31.64',what:
'@ @'
  {v:'31.65',what:'Settings detail pane sits at the right of the rows and the block fills the card',
   run:function(){
     var bad=[], l, d, w, c, padWas=document.body.classList.contains('padon');
     __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     try{
       openSettings('display');
       l=document.getElementById('setlist').getBoundingClientRect(); d=document.getElementById('setdetail').getBoundingClientRect();
       w=document.getElementById('setwrap').getBoundingClientRect(); c=document.getElementById('settingsmodal').getBoundingClientRect();
       if(getComputedStyle(document.getElementById('setwrap')).flexDirection!=='row') bad.push('setwrap not a row');
       if(d.width>0 && d.left<l.right-2) bad.push('detail left '+Math.round(d.left)+' is under the list right '+Math.round(l.right));
       if(w.width<c.width*0.8) bad.push('block '+Math.round(w.width)+' of card '+Math.round(c.width));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var q=document.getElementById('settingsmodal'); if(q) q.classList.remove('on'); }catch(_k){} try{ __topClear(); }catch(_c){} document.body.classList.toggle('padon',padWas); }
     return bad.length?bad.join('; '):null; }},
  {v:'31.64',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
