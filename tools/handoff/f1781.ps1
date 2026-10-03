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

if ($s.Contains("  {v:'17.81',what:")) { throw "check 17.81 is in the fixture already" }

SubRx @'
  {v:'17.80',what:
'@ @'
  {v:'17.81',what:'the full controls legend (H twice) names a PlayStation pad in its own words: CIRCLE crouch, CROSS dodge roll',
   run:function(){
     if(typeof padB!=='function') return 'SKIP: this build has no pad names';
     if(!window.__deploy||!window.__endRaid||typeof drawHUD!=='function') return 'SKIP: no raid in this fixture';
     var bad=[], b0=PAD.brand, on0=PAD.on, oFT=ctx.fillText, seen=[], oSay=say;
     try{
       say=function(){};
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over) return 'SKIP: staging: no raid';
       PAD.brand='ps'; PAD.on=true; G.legendOn=2;
       ctx.fillText=function(s){ seen.push(String(s)); return oFT.apply(this,arguments); };
       try{ drawHUD(); }catch(_h){}
       ctx.fillText=oFT;
       if(seen.indexOf('CIRCLE')<0||seen.indexOf('CROSS')<0) bad.push('the full legend on a PlayStation pad drew '+JSON.stringify(seen.filter(function(s){ return /^(A|B|X|Y|CROSS|CIRCLE|SQUARE|TRIANGLE)$/.test(s); })));
       if(seen.indexOf('B')>=0) bad.push('the full legend still says B on a PlayStation pad');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ ctx.fillText=oFT; PAD.brand=b0; PAD.on=on0; say=oSay; try{ if(G){ G.legendOn=1; __endRaid('abandon'); } __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'17.80',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
