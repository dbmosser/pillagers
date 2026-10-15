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

if ($s.Contains("  {v:'27.56',what:")) { throw "check 27.56 is in the fixture already" }

SubRx @'
  {v:'27.55',what:
'@ @'
  {v:'27.56',what:'his 2026-10-14 note (UI cleanup uic8): the What is New card and the Undercroft backpack are solid plates (the station signs of the floor read through both at 94 and 96 percent)',
   run:function(){
     if(!(window.__wnseen&&window.__hubEnter&&window.__hubFrame&&window.__showScreen&&window.__hubBagSet)||typeof hudPanel!=='function'||typeof drawHubBag!=='function') return 'SKIP: this fixture cannot draw the floor card and the backpack';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing renders';
     var bad=[], P2=__P(), keepRuns=P2.runs, hp=hudPanel, seen=[], wide, said=false, proto=CanvasRenderingContext2D.prototype, oft=proto.fillText;
     try{
       __topClear(); __runPrep();
       P2.runs=Math.max(1,keepRuns||0);
       G=null; keys={}; __showScreen('hub'); __hubEnter();
       hudPanel=function(x,y,w,h,a){ seen.push({w:w,h:h,a:(a===undefined?0.88:a)}); return hp.apply(this,arguments); };
       proto.fillText=function(t){ if(String(t).indexOf('NEW IN v')===0) said=true; return oft.apply(this,arguments); };
       __wnseen(0); __hubFrame(0.016);
       proto.fillText=oft;
       if(!said) return 'SKIP: the card was not drawn here';
       wide=seen.filter(function(s){ return s.w>=600&&s.h>=120; });
       if(!wide.length) bad.push('the What is New card is a flat rectangle, not the HUD plate');
       wide.forEach(function(s){ if(s.a<0.99) bad.push('the What is New card plate is '+Math.round(s.w)+'x'+Math.round(s.h)+' at '+Math.round(s.a*100)+' percent, not solid'); });
       seen.length=0; __wnseen(1);
       __hubBagSet(true); drawHubBag(); __hubBagSet(false);
       wide=seen.filter(function(s){ return s.w>=600&&s.h>=120; });
       if(!wide.length) return bad.length?bad.join('; '):'SKIP: the Undercroft backpack was not drawn as a plate here';
       wide.forEach(function(s){ if(s.a<0.99) bad.push('the Undercroft backpack plate is '+Math.round(s.w)+'x'+Math.round(s.h)+' at '+Math.round(s.a*100)+' percent, not solid'); });
       return bad.length?bad.join('; '):null;
     } finally { hudPanel=hp; proto.fillText=oft; try{ __hubBagSet(false); }catch(_b){} P2.runs=keepRuns; __wnseen(1); try{ saveProfile(); }catch(_s){} try{ __topClear(); __cleanProfile(); }catch(_c){} } }},
  {v:'27.55',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
