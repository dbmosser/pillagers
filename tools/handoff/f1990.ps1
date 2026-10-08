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

if ($s.Contains("  {v:'19.90',what:")) { throw "check 19.90 is in the fixture already" }

SubRx @'
  {v:'19.89',what:
'@ @'
  {v:'19.90',what:'the pause box frame holds its content: with an extra tall line in the box the frame grows to hold all of it, and it is never smaller than 400px',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof togglePauseBox!=='function') return 'SKIP: no pause box here';
     var bad=[], b=document.getElementById('pausebox'), x=document.createElement('div'), g, i, c, t=1e9, bo=-1e9, fh;
     if(!b) return 'SKIP: no pause box';
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       x.style.cssText='height:180px;width:20px'; x.id='zqpausetall'; b.appendChild(x);
       togglePauseBox(true);
       if(!b.offsetHeight) return 'SKIP: the box did not open';
       for(i=0;i<b.children.length;i++){ c=b.children[i]; if(c.offsetHeight>0){ t=Math.min(t,c.offsetTop); bo=Math.max(bo,c.offsetTop+c.offsetHeight); } }
       fh=parseFloat(getComputedStyle(b,'::before').height);
       if(!(fh>=bo-t)) bad.push('the frame is '+Math.round(fh)+' px for '+Math.round(bo-t)+' px of content');
       togglePauseBox(false); b.removeChild(x);
       togglePauseBox(true); fh=parseFloat(getComputedStyle(b,'::before').height); togglePauseBox(false);
       if(fh<399&&b.offsetHeight>430) bad.push('with nothing extra the frame shrank to '+Math.round(fh)+' px');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(x.parentNode) x.parentNode.removeChild(x); }catch(_x){} try{ if(pauseOpen) togglePauseBox(false); }catch(_t){} try{ if(typeof pauseFrameFit==='function'){ b.style.removeProperty('--pbh'); } }catch(_p){} try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.89',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
