$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# v11.75 CHECK, inserted before the v11.74 entry. The hold is stepped by hand
# through the same function the frame loop calls, so the clock is exact. The
# old click wiring is assembled from pieces so this check never matches itself.
SubRx @'
  {v:'11.74',what:'the boarding window tells him to act: EXTRACT NOW with the ring letter and the seconds left, in both the banner above the belt and the label on an off-screen ring, and nowhere does it say the old in-progress wording',
'@ @'
  {v:'11.75',what:'the craft button is a hold: it fills as you hold it, nothing is spent until it is full, and letting go early spends nothing',
   run:function(){
     if(typeof craftHoldStart!=='function'||typeof craftHoldStep!=='function'||typeof craftHoldCancel!=='function') return 'the craft button is a plain click; there is no hold to drive';
     if(typeof CRAFT_HOLD==='undefined') return 'SKIP: no hold length in this build';
     var bad=[], fired=0, stub=document.createElement('button');
     stub.disabled=false; document.body.appendChild(stub);
     try{
       // A HOLD FILLS AND THEN FIRES, ONCE.
       craftHoldStart(stub,function(){ fired++; });
       craftHoldStep(CRAFT_HOLD*0.5);
       if(fired) bad.push('the craft fired at half the hold');
       var bg=String(stub.style.backgroundImage||'');
       if(bg.indexOf('50%')<0) bad.push('at half the hold the button is not half full (background "'+bg.slice(0,70)+'")');
       craftHoldStep(CRAFT_HOLD*0.6);
       if(fired!==1) bad.push('past the full hold the craft fired '+fired+' time(s) and not once');
       if(String(stub.style.backgroundImage||'')) bad.push('after firing the button still carries a fill');
       // LETTING GO EARLY SPENDS NOTHING.
       fired=0; craftHoldStart(stub,function(){ fired++; }); craftHoldStep(CRAFT_HOLD*0.7); craftHoldCancel(); craftHoldStep(CRAFT_HOLD*2);
       if(fired) bad.push('a hold released early still crafted');
       if(String(stub.style.backgroundImage||'')) bad.push('a cancelled hold left a fill on the button');
       // A DEAD BUTTON CANNOT BE HELD.
       fired=0; stub.disabled=true; craftHoldStart(stub,function(){ fired++; }); craftHoldStep(CRAFT_HOLD*2);
       if(fired) bad.push('a disabled button crafted on a hold');
       // CONTROL: the real panel wires the hold, and no longer crafts on a click.
       var src=''; try{ src=renderCraftDetail.toString(); }catch(_s){}
       if(src.indexOf('craftHoldStart(')<0) bad.push('control: the craft panel does not wire the hold to its button');
       var oldClick=['b.onclick=function(){ btn.','click(); };'].join('');
       if(src.indexOf(oldClick)>=0) bad.push('control: the craft panel still crafts on a plain click');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ craftHoldCancel(); }catch(_c){} try{ document.body.removeChild(stub); }catch(_r){} }
     return bad.length?bad.join('; '):null; }},
  {v:'11.74',what:'the boarding window tells him to act: EXTRACT NOW with the ring letter and the seconds left, in both the banner above the belt and the label on an off-screen ring, and nowhere does it say the old in-progress wording',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
