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

if ($s.Contains("  {v:'32.90',what:")) { throw "check 32.90 is in the fixture already" }

SubRx @'
  {v:'32.89',what:
'@ @'
  {v:'32.90',what:'job 55: the close X sits the same distance under its frame top in Settings, the shop and the stash (one close place, v31.02)',
   run:function(){
     if(!(window.__station&&window.__hubEnter)||typeof openSettings!=='function') return 'SKIP: this fixture cannot walk the Undercroft';
     var bad=[], got=[], m, b, mr, br, z, bs, ft, r;
     try{
       __topClear(); openSettings('display');
       m=document.getElementById('settingsmodal'); b=document.getElementById('closesettings');
       if(!m||!b||!m.classList.contains('on')) return 'SKIP: Settings did not open';
       mr=m.getBoundingClientRect(); br=b.getBoundingClientRect(); z=parseFloat(m.style.zoom)||1; bs=getComputedStyle(m,'::before');
       got.push(['settings',(br.top-(mr.top+(parseFloat(bs.top)||0)*z))/z]);
       __topClear(); __hubEnter(); r=__station('trader','KeyE');
       m=document.getElementById('tradermodal'); b=document.getElementById('closetrader');
       if(!m||!b||!m.classList.contains('on')) return 'SKIP: the shop did not open';
       mr=m.getBoundingClientRect(); br=b.getBoundingClientRect(); z=parseFloat(m.style.zoom)||1; bs=getComputedStyle(m,'::before');
       got.push(['shop',(br.top-(mr.top+(parseFloat(bs.top)||0)*z))/z]);
       __topClear(); __hubEnter(); r=__station('term','KeyE');
       m=document.getElementById('hub'); b=document.getElementById('stashclose');
       if(!m||!b||!m.classList.contains('on')) return 'SKIP: the stash did not open';
       mr=m.getBoundingClientRect(); br=b.getBoundingClientRect(); z=parseFloat(m.style.zoom)||1;
       got.push(['stash',(br.top-mr.top)/z]);
       var lo=Math.min.apply(null,got.map(function(g){return g[1];})), hi=Math.max.apply(null,got.map(function(g){return g[1];}));
       if(hi-lo>2) bad.push('the close X sits at different heights under its frame: '+got.map(function(g){ return g[0]+' '+Math.round(g[1]); }).join(', '));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'32.89',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
