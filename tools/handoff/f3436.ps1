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

if ($s.Contains("  {v:'34.36',what:")) { throw "check 34.36 is in the fixture already" }

SubRx @'
  {v:'34.35',what:
'@ @'
  {v:'34.36',what:'the gambler panels are as tall as their content (not the whole card) and their section labels are the 20px body size',
   run:function(){
     var bad=[], snap=null, m=document.getElementById('gamblemodal');
     if(!m||typeof renderGamble!=='function'||!window.__applyLoaded||!window.__P) return 'SKIP: no Wirt counter in this build';
     try{
       __topClear(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       var q=__P(); q.wirtLotBought=null; q.credits=0; renderGamble(); m.classList.add('on');
       var a=document.getElementById('wirtsec_gamble'), hd=a&&a.firstElementChild;
       if(!hd) return 'no gamble panel';
       var fs=parseFloat(getComputedStyle(hd).fontSize);
       if(fs<19||fs>24) bad.push('gamble section label is '+getComputedStyle(hd).fontSize+', not the 20px body size');
       var ra=a.getBoundingClientRect(), mr=m.getBoundingClientRect();
       if(ra.bottom>mr.top+mr.height*0.9) bad.push('gamble panel still runs to the card floor: ends '+Math.round(ra.bottom)+' of '+Math.round(mr.bottom));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ m.classList.remove('on'); }catch(_x){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ if(typeof wirtLotTick==='function') wirtLotTick(); }catch(_t){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'34.35',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
