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

if ($s.Contains("  {v:'19.88',what:")) { throw "check 19.88 is in the fixture already" }

SubRx @'
  {v:'19.87',what:
'@ @'
  {v:'19.88',what:'the Undercroft pause box lists the floor pad buttons: on the floor with a pad on it says A use a station and not A dodge roll, and in a raid the raid buttons',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__hubEnter&&window.__showScreen)) return 'SKIP: this fixture cannot reach the floor and a raid';
     if(typeof togglePauseBox!=='function'||typeof PAD==='undefined') return 'SKIP: no pause box or pad here';
     var bad=[], el=document.getElementById('pausekeys'), on0=PAD.on, tf, tr, g;
     if(!el) return 'SKIP: no pause key line';
     try{
       __topClear(); __runPrep(); __cleanProfile();
       G=null; keys={}; __showScreen('hub'); __hubEnter();
       PAD.on=true; togglePauseBox(true); tf=String(el.textContent); togglePauseBox(false);
       if(tf.indexOf('dodge roll')>=0) bad.push('on the floor the pad box says A dodge roll');
       if(tf.indexOf('use a station')<0) bad.push('on the floor the pad box does not say how to use a station');
       __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       PAD.on=true; togglePauseBox(true); tr=String(el.textContent); togglePauseBox(false);
       if(tr.indexOf('dodge roll')<0) bad.push('control: in a raid the pad box lost the raid buttons');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ PAD.on=on0; try{ if(pauseOpen) togglePauseBox(false); }catch(_t){} try{ keysLegendApply(); }catch(_k){} try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.87',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
