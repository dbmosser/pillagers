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

if ($s.Contains("  {v:'35.21',what:")) { throw "check 35.21 is in the fixture already" }

SubRx @'
  {v:'35.20',what:
'@ @'
  {v:'35.21',what:'cw-fszoom, his report 2026-10-27 (the main PC build had no fullscreen gate, the VM did): a normal window at 75 percent page zoom is not taken for F11, so the start gate opens; real F11 at 75 and 100 percent still counts, a normal window at 100 percent does not',
   run:function(){
     if(typeof fsFull!=='function') return 'SKIP: no fsFull in this build';
     if(typeof fsOn==='function'&&fsOn()) return 'SKIP: the test page is really fullscreen';
     var bad=[], kept=[], mq0=(typeof FSG!=='undefined')?FSG.mq:undefined;
     function pin(o,k,v){ var own=Object.prototype.hasOwnProperty.call(o,k), d=own?Object.getOwnPropertyDescriptor(o,k):null; kept.push([o,k,own,d]); Object.defineProperty(o,k,{configurable:true,enumerable:true,get:function(){ return v; }}); }
     function put(sw,sh,ow,oh,iw,ih){ pin(window.screen,'width',sw); pin(window.screen,'height',sh); pin(window,'outerWidth',ow); pin(window,'outerHeight',oh); pin(window,'innerWidth',iw); pin(window,'innerHeight',ih); }
     function back(){ var e; while(kept.length){ e=kept.pop(); try{ if(e[2]) Object.defineProperty(e[0],e[1],e[3]); else delete e[0][e[1]]; }catch(_b){} } }
     function look(name,want,sw,sh,ow,oh,iw,ih){ var got; try{ put(sw,sh,ow,oh,iw,ih); got=!!fsFull(); } finally { back(); } if(got!==want) bad.push(name+' reads as '+(got?'fullscreen':'windowed')+', not '+(want?'fullscreen':'windowed')); }
     try{
       if(typeof FSG!=='undefined') FSG.mq={matches:false};
       look('his window (3825x2016 at 300 percent, 75 percent zoom)',false,1280,720,1275,672,1679,750);
       look('a normal window at 100 percent',false,1280,720,1280,672,1264,560);
       look('F11 at 75 percent zoom',true,1280,720,1280,720,1707,960);
       look('F11 at 100 percent',true,1280,720,1280,720,1280,720);
     }catch(e){ back(); return 'SKIP: the window sizes could not be pinned here ('+(e&&e.message||e)+')'; }
     finally{ back(); if(typeof FSG!=='undefined') FSG.mq=mq0; }
     return bad.length?bad.join('; '):null; }},
  {v:'35.20',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
