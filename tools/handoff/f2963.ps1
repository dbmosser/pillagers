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

if ($s.Contains("  {v:'29.63',what:")) { throw "check 29.63 is in the fixture already" }

SubRx @'
  {v:'29.62',what:
'@ @'
  {v:'29.63',what:'Settings and Keys are centred cards with one 48 by 48 close X in the header row',
   run:function(){
     if(typeof openSettings!=='function'||typeof keysOpen!=='function') return 'SKIP: no Settings here';
     var bad=[], W=window.innerWidth, H=window.innerHeight, x, b, r, wr, m, kl;
     try{
       openSettings('display'); m=document.getElementById('settingsmodal'); b=document.getElementById('closesettings'); wr=document.getElementById('setwrap');
       if(!m||!b||!wr) return 'SKIP: the Settings window did not build';
       r=b.getBoundingClientRect(); wr=wr.getBoundingClientRect();
       if(Math.abs(r.width/r.height-1)>.02) bad.push('the Settings close is '+Math.round(r.width)+' by '+Math.round(r.height));
       if(r.top+r.height/2>H*.15||r.left+r.width/2<W*.6) bad.push('the Settings close is not top right ('+Math.round(r.left)+','+Math.round(r.top)+')');
       if(wr.left<W*.08) bad.push('the Settings list starts at '+Math.round(wr.left)+', a full width wall');
       if(wr.right>W*.92) bad.push('the Settings list ends at '+Math.round(wr.right));
       b.click(); if(m.classList.contains('on')) bad.push('the Settings X did not close the window');
       keysOpen(); x=document.getElementById('closekeys'); kl=document.getElementById('keyslist');
       if(!x||!kl) bad.push('no Keys window');
       else { r=x.getBoundingClientRect(); wr=kl.getBoundingClientRect();
         if(Math.abs(r.width/r.height-1)>.02) bad.push('the Keys close is '+Math.round(r.width)+' by '+Math.round(r.height));
         if(r.top+r.height/2>H*.15||r.left+r.width/2<W*.6) bad.push('the Keys close is not top right');
         if(wr.left<W*.08) bad.push('the Keys list starts at '+Math.round(wr.left));
         x.click(); if(document.getElementById('keysmodal').classList.contains('on')) bad.push('the Keys X did not close the window'); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ KEYS.waiting=null; ['settingsmodal','keysmodal'].forEach(function(i){ var q=document.getElementById(i); if(q) q.classList.remove('on'); }); }catch(_k){} try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'29.62',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
