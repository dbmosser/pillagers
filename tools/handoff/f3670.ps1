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

if ($s.Contains("  {v:'36.70',what:")) { throw "check 36.70 is in the fixture already" }

SubRx @'
  {v:'36.69',what:
'@ @'
  {v:'36.70',what:'text size starts at 100 percent for a new profile and for both demo windows; a save that chose 175 percent keeps it',
   run:function(){
     if(window.storage&&window.storage.set) return 'SKIP: this host saves through window.storage, not localStorage';
     if(typeof P_BORN!=='object'||!P_BORN) return 'no record of what a new profile is born with (still the old text size)';
     var bad=[], snap=JSON.stringify(P), oS=storeSet, oV=saveProfile, j, u;
     try{
       storeSet=function(){}; saveProfile=function(){};
       if(P_BORN.uiScale!==1||P_BORN.menuZoom!==1) bad.push('a new profile is born at '+P_BORN.uiScale+' / '+P_BORN.menuZoom+', not 1 / 1');
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       for(j=0;j<2;j++){
         if(!arcadeSandboxIn(j?'p2':'host')){ bad.push('the demo did not open'); break; }
         u=uiScale();
         if(Math.abs(u-1)>0.001||Math.abs((P.menuZoom||0)-1)>0.001) bad.push('the demo ('+(j?'player 2':'player 1')+') starts at text '+u+' / menu zoom '+P.menuZoom+', not 1 / 1');
         arcadeSandboxOut();
       }
       var s2=JSON.parse(snap); s2.uiScale=1.75; s2.menuZoom=1.4;
       applyLoadedProfile({value:JSON.stringify(s2)});
       if(P.uiScale!==1.75||Math.abs(uiScale()-1.75)>0.001||P.menuZoom!==1.4) bad.push('a save that chose 175 percent came back as '+P.uiScale+' / '+P.menuZoom);
       s2=JSON.parse(snap); delete s2.uiScale;
       applyLoadedProfile({value:JSON.stringify(s2)});
       if(Object.prototype.hasOwnProperty.call(P,'uiScale')) bad.push('a save with no text size choice was given one');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{ try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){} storeSet=oS; saveProfile=oV; try{ applyLoadedProfile({value:snap}); }catch(_r){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'36.69',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
