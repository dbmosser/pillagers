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

if ($s.Contains("  {v:'24.35',what:")) { throw "check 24.35 is in the fixture already" }

SubRx @'
  {v:'24.34',what:
'@ @'
  {v:'24.35',what:'his #50 (UI redesign ui5q1b, from the AAA judge of the Wirt and Last Pour shots): the room behind a window is dimmed to at least 90 percent, and the floor money line is not painted while a window is open (and still is with none open)',
   run:function(){
     if(!(window.__station&&window.__hubEnter)) return 'SKIP: this fixture cannot walk the Undercroft';
     if(typeof drawHubHUD!=='function'||typeof hubWinOn!=='function') return 'SKIP: no floor HUD here';
     var bad=[], m, c, a, seen, own, need='in st'+'ash';
     function draws(){ var out=[], real=CanvasRenderingContext2D.prototype.fillText; ctx.fillText=function(t){ out.push(String(t)); return real.apply(this,arguments); };
       try{ drawHubHUD(0,0); }finally{ delete ctx.fillText; } return out.join('|'); }
     try{
       __topClear(); __hubEnter();
       seen=draws();
       if(seen.indexOf(need)<0) bad.push('control: with no window open the floor money line was not painted ('+seen.slice(0,80)+')');
       __station('gamble','KeyE');
       m=document.getElementById('gamblemodal');
       if(!m||!m.classList.contains('on')) return 'SKIP: Wirt did not open';
       c=getComputedStyle(m).backgroundColor; a=/rgba\(/.test(c)?parseFloat(c.split(',')[3]):1;
       if(!(a>=0.9)) bad.push('the room behind a window is dimmed only to '+a+' ('+c+')');
       seen=draws();
       if(seen.indexOf(need)>=0) bad.push('the floor money line is painted behind Wirt');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ delete ctx.fillText; }catch(_d){} try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'24.34',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
