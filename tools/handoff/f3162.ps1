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

if ($s.Contains("  {v:'31.62',what:")) { throw "check 31.62 is in the fixture already" }

SubRx @'
  {v:'31.61',what:
'@ @'
  {v:'31.62',what:'the terms, party, gamble and bar windows draw the same 90 percent card frame as the shop (not a small box in the top left corner)',
   run:function(){
     if(!(window.__hubEnter&&window.__showScreen)) return 'SKIP: this fixture cannot walk the Undercroft';
     var bad=[], ids=['termsmodal','partymodal','gamblemodal','barmodal'], i, m, cs, tw=window.innerWidth, th=window.innerHeight, w, h, l, t;
     try{
       __topClear(); __cleanProfile();
       G=null; keys={}; __showScreen('hub'); __hubEnter();
       for(i=0;i<ids.length;i++){
         openModal(ids[i]);
         m=document.getElementById(ids[i]); if(!m){ bad.push('no '+ids[i]); continue; }
         cs=getComputedStyle(m,'::before');
         w=parseFloat(cs.width); h=parseFloat(cs.height); l=parseFloat(cs.left); t=parseFloat(cs.top);
         if(!(Math.abs(w+2*l-m.offsetWidth)<=4&&Math.abs(h+2*t-m.offsetHeight)<=4&&Math.abs(l-tw*0.05)<=4)) bad.push(ids[i]+' frame is '+Math.round(w)+' x '+Math.round(h)+' at '+Math.round(l)+','+Math.round(t)+' in a window '+m.offsetWidth+' x '+m.offsetHeight+', not the 90 percent card');
         if(cs.transform&&cs.transform!=='none') bad.push(ids[i]+' frame is shifted by '+cs.transform);
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'31.61',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
