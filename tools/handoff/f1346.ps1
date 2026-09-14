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

# v13.46 CHECK, above the newest check, plus two checks that computed the menu size
# themselves: they now ask the game for it when menuScale exists.
SubRx @'
  {v:'13.45',what:
'@ @'
  {v:'13.46',what:'on a 1280x720 itch window the menus fit the screen: the Undercroft and the corner readout are drawn at the size that fits instead of their 1080p size times his menu size, while at 1920x1080 his size of 1.3 still applies in full',
   run:function(){
     if(!(window.__forceSize&&window.__P)||typeof applyMenuZoom!=='function'||typeof titleRes!=='function') return 'SKIP: no menu zoom or size forcing in this build';
     var bad=[], P2=__P(), keepZ=P2.menuZoom;
     try{
       P2.menuZoom=1.3;
       __forceSize(1280,720); applyMenuZoom();
       var hub=document.getElementById('hub'), tr=document.getElementById('topright');
       var hz=parseFloat(hub&&hub.style.zoom)||0, tz=parseFloat(tr&&tr.style.zoom)||0;
       if(!(hz>0)) return 'SKIP: the Undercroft carries no zoom to read';
       if(hz>0.667*0.92+0.02) bad.push('at 1280x720 the Undercroft is drawn at '+hz.toFixed(2)+', larger than the 0.61 that fits the window');
       if(tz>0.667+0.02) bad.push('at 1280x720 the corner readout is drawn at '+tz.toFixed(2)+', larger than the 0.67 that fits');
       // CONTROL: at 1920x1080 his size of 1.3 still applies in full.
       __forceSize(1920,1080); applyMenuZoom();
       var hz2=parseFloat(hub.style.zoom)||0;
       if(Math.abs(hz2-1.3*0.92)>0.02) bad.push('control: at 1920x1080 the Undercroft is drawn at '+hz2.toFixed(2)+', not his 1.3 times 0.92');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ P2.menuZoom=keepZ; __forceSize(1920,1080); applyMenuZoom(); }catch(_f){} }
     return bad.length?bad.join('; '):null; }},
  {v:'13.45',what:
'@
SubRx @'
Math.max(1,P2.menuZoom)*titleRes(), c=rd();
'@ @'
((typeof menuScale==='function')?menuScale():Math.max(1,P2.menuZoom)*titleRes()), c=rd();
'@
SubRx @'
:Math.max(1,(P2.menuZoom||1))*titleRes();
'@ @'
:((typeof menuScale==='function')?menuScale():Math.max(1,(P2.menuZoom||1))*titleRes());
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
