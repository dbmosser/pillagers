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

if ($s.Contains("  {v:'19.28',what:")) { throw "check 19.28 is in the fixture already" }

SubRx @'
  {v:'19.27',what:
'@ @'
  {v:'19.28',what:'the what is new card waits while the floor backpack is open: with the bag open no card line is drawn, and with it closed the card is back',
   run:function(){
     if(!(window.__wnseen&&window.__hubEnter&&window.__hubFrame&&window.__showScreen&&window.__hubBagSet)) return 'SKIP: this fixture cannot drive the floor card';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing renders';
     var bad=[], P2=__P(), keepRuns=P2.runs, rec=[], proto=CanvasRenderingContext2D.prototype, o=proto.fillText, shown;
     function card(){ rec.length=0; __wnseen(0); __hubFrame(0.016); return rec.some(function(r){ return r.indexOf('NEW IN v')===0; }); }
     try{
       __topClear(); __runPrep();
       P2.runs=Math.max(1,keepRuns||0);
       G=null; keys={}; __showScreen('hub'); __hubEnter();
       proto.fillText=function(t){ rec.push(String(t)); return o.apply(this,arguments); };
       __hubBagSet(true);
       if(card()) bad.push('the card is drawn under the open backpack');
       __hubBagSet(false);
       if(!card()) bad.push('control: with the backpack closed the card is not drawn');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ proto.fillText=o; try{ __hubBagSet(false); }catch(_b){} P2.runs=keepRuns; __wnseen(1); try{ saveProfile(); }catch(_s){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.27',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
