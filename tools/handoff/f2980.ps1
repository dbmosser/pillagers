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

if ($s.Contains("  {v:'29.80',what:")) { throw "check 29.80 is in the fixture already" }

SubRx @'
  {v:'29.79',what:
'@ @'
  {v:'29.80',what:'Settings and Keys cards are centred and about 720 tall, not full height',
   run:function(){
     if(typeof openSettings!=='function'||typeof keysOpen!=='function') return 'SKIP: no Settings here';
     var bad=[], m, h, t, lim, bx;
     try{
       lim=Math.max(48,(innerHeight-720)/2)-30;   /* the card is still scaling in when read */
       openSettings('display'); m=document.getElementById('settingsmodal'); h=m&&m.querySelector('h3');
       if(!h||!h.offsetWidth) return 'SKIP: no title';
       t=h.getBoundingClientRect().top;
       if(t<lim) bad.push('Settings title sits at '+Math.round(t)+'px (needs '+Math.round(lim)+')');
       bx=document.getElementById('setlist').getBoundingClientRect().bottom;
       if(bx>innerHeight-lim) bad.push('Settings list ends at '+Math.round(bx)+'px, past the card');
       m.classList.remove('on'); try{ __topClear(); }catch(_c){}
       keysOpen(false); m=document.getElementById('keysmodal'); h=m&&m.querySelector('h3');
       if(!h||!h.offsetWidth) return bad.length?bad.join('; '):'SKIP: no keys title';
       t=h.getBoundingClientRect().top;
       if(t<lim) bad.push('Keys title sits at '+Math.round(t)+'px (needs '+Math.round(lim)+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var q=document.getElementById('settingsmodal'); if(q) q.classList.remove('on'); q=document.getElementById('keysmodal'); if(q) q.classList.remove('on'); }catch(_k){} try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'29.79',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
