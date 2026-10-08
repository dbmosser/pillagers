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

if ($s.Contains("  {v:'19.71',what:")) { throw "check 19.71 is in the fixture already" }

SubRx @'
  {v:'19.70',what:
'@ @'
  {v:'19.71',what:'the pause box speaks controller on a controller: with a pad on it lists RT and the sticks, not LMB and WASD, and without one the keyboard keys',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof togglePauseBox!=='function'||typeof PAD==='undefined') return 'SKIP: no pause box or pad here';
     var bad=[], g, el=document.getElementById('pausekeys'), on0=PAD.on, tp, tk;
     if(!el) return 'SKIP: no pause key line here';
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       PAD.on=true; togglePauseBox(true); tp=String(el.textContent||''); togglePauseBox(false);
       PAD.on=false; togglePauseBox(true); tk=String(el.textContent||''); togglePauseBox(false);
       if(tp.indexOf('LMB')>=0||tp.indexOf('MOUSE')>=0) bad.push('on a controller the pause box still lists the mouse');
       if(tp.indexOf('RT')<0||tp.indexOf('STICK')<0) bad.push('on a controller the pause box does not list the pad buttons');
       if(tk.indexOf('LMB')<0) bad.push('control: with keyboard and mouse the pause box does not list LMB');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ PAD.on=on0; try{ if(pauseOpen) togglePauseBox(false); }catch(_t){} try{ keysLegendApply(); }catch(_k){} try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.70',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
