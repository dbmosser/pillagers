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

if ($s.Contains("  {v:'21.24',what:")) { throw "check 21.24 is in the fixture already" }

SubRx @'
  {v:'21.23',what:
'@ @'
  {v:'21.24',what:'the hot ground keeps moving for the party after the host is out: the raid the host keeps running moves it, and silently on his side',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof tickHot!=='function'||typeof netSpecTick!=='function'||typeof NET!=='object'||!NET) return 'SKIP: no hot ground or party here';
     var bad=[], nd='tick'+'Hot(', g, H, m0, oSfx=sfx, oSay=say, said=0, st0=NET.specTick;
     if(String(netSpecTick).indexOf(nd)<0) bad.push('the raid the host keeps for his party never moves the hot ground');
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.hotZone) return bad.length?bad.join('; '):'SKIP: no hot ground';
       H=g.hotZone; m0=H.moves|0; H.at=HOT_EVERY;
       sfx=function(){ said++; }; say=function(){ said++; };
       NET.specTick=true;
       tickHot(0.01);
       NET.specTick=st0;
       if((H.moves|0)!==m0+1) bad.push('the hot ground did not move ('+m0+' to '+(H.moves|0)+')');
       if(said) bad.push('the host watching his party was told or played a sound for a raid he is out of');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ NET.specTick=st0; sfx=oSfx; say=oSay; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'21.23',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
