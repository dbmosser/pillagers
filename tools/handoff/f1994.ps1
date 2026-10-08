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

if ($s.Contains("  {v:'19.94',what:")) { throw "check 19.94 is in the fixture already" }

SubRx @'
  {v:'19.93',what:
'@ @'
  {v:'19.94',what:'the pause box frame is wide enough for its content: with an extra wide line in the box the frame grows to hold it, and it is never narrower than 780px',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof togglePauseBox!=='function') return 'SKIP: no pause box here';
     var bad=[], b=document.getElementById('pausebox'), x=document.createElement('div'), g, fw;
     if(!b) return 'SKIP: no pause box';
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       x.style.cssText='height:10px;width:960px;flex:0 0 auto'; x.id='zqpausewide'; b.appendChild(x);
       togglePauseBox(true);
       if(!b.offsetHeight) return 'SKIP: the box did not open';
       if(b.offsetWidth<1000) return 'SKIP: the box is too narrow here to hold the test line';
       fw=parseFloat(getComputedStyle(b,'::before').width);
       if(!(fw>=960)) bad.push('the frame is '+Math.round(fw)+' px wide for a 960 px line');
       togglePauseBox(false); b.removeChild(x);
       togglePauseBox(true); fw=parseFloat(getComputedStyle(b,'::before').width); togglePauseBox(false);
       if(fw<779) bad.push('with nothing extra the frame narrowed to '+Math.round(fw)+' px');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(x.parentNode) x.parentNode.removeChild(x); }catch(_x){} try{ if(pauseOpen) togglePauseBox(false); }catch(_t){} try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.93',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
