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

if ($s.Contains("  {v:'19.35',what:")) { throw "check 19.35 is in the fixture already" }

SubRx @'
  {v:'19.34',what:
'@ @'
  {v:'19.35',what:'the Undercroft walls sit in the room light: a floor frame paints no wall in the raid daylight wall colours, the lift walls included',
   run:function(){
     if(!(window.__hubEnter&&window.__hubFrame&&window.__showScreen)) return 'SKIP: this fixture cannot draw the floor';
     if(typeof DISTRICTS==='undefined'||typeof wc==='undefined') return 'SKIP: no districts here';
     var bad=[], used={}, oFR=null, t, raw=String(DISTRICTS[1].wallTop).toLowerCase();
     try{
       __topClear(); __runPrep();
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       G=null; keys={}; __showScreen('hub'); __hubEnter();
       oFR=CanvasRenderingContext2D.prototype.fillRect;
       CanvasRenderingContext2D.prototype.fillRect=function(){ if(this===wc) used[String(this.fillStyle).toLowerCase()]=1; return oFR.apply(this,arguments); };
       __hubFrame(0.016);
       if(used[raw]) bad.push('the lift walls are still painted in the raid daylight top colour '+raw);
       if(!Object.keys(used).length) return 'SKIP: nothing was painted on the floor canvas';
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ if(oFR) CanvasRenderingContext2D.prototype.fillRect=oFR; __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.34',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
