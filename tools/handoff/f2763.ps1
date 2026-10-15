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

if ($s.Contains("  {v:'27.63',what:")) { throw "check 27.63 is in the fixture already" }

SubRx @'
  {v:'27.62',what:
'@ @'
  {v:'27.63',what:'cloud-menus-held-aim-blur: with AIM on HOLD a right button held when the window loses focus no longer leaves the aim (slow walk) on after focus returns; a toggled aim stays',
   run:function(){
     if(typeof releaseAllKeys!=='function'||typeof cv==='undefined'||!cv) return 'SKIP: this fixture has no canvas or releaseAllKeys';
     var bad=[], a0=CFG.aimTgl, b0=CFG.pauseBlur, g, p, i;
     function setup(){ __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242}); var gg=__state(); gg.player.iv=99; gg.ents.length=0; return gg; }
     function rdown(){ cv.dispatchEvent(new MouseEvent('mousedown',{button:2,bubbles:true,cancelable:true})); }
     function away(){ window.dispatchEvent(new Event('blur')); try{ if(pauseOpen) togglePauseBox(false); }catch(_pb){} window.dispatchEvent(new Event('focus')); for(i=0;i<10;i++) __sim(0.05); }
     try{
       CFG.pauseBlur=0; CFG.aimTgl=0;
       g=setup(); p=g.player;
       rdown();
       if(!p.ads) return 'SKIP: a right press on the canvas did not aim';
       away();
       if(p.ads) bad.push('AIM on HOLD: a right button held while the window lost focus left the aim on after focus came back');
       __endRaid('abandon');
       CFG.aimTgl=1;
       g=setup(); p=g.player;
       rdown();
       if(!p.ads) bad.push('AIM on TOGGLE: a right press did not turn the aim on');
       else { away(); if(!p.ads) bad.push('AIM on TOGGLE: a focus change turned a toggled aim off'); }
       __endRaid('abandon');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       try{ if(G&&G.player) G.player.ads=false; }catch(_a){}
       try{ if(G&&!G.over&&state==='raid') __endRaid('abandon'); }catch(_e){}
       CFG.aimTgl=a0; CFG.pauseBlur=b0;
       try{ releaseAllKeys(); }catch(_r){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'27.62',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
