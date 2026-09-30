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

if ($s.Contains("  {v:'17.40',what:")) { throw "check 17.40 is in the fixture already" }

SubRx @'
  {v:'17.39',what:
'@ @'
  {v:'17.40',what:'achievements: a first clean extraction earns FIRST OUT and UNTOUCHED and names them for the end card, the Mainframe lists every achievement with how many are earned, and runs already in the log count the first time the list is drawn',
   run:function(){
     if(typeof achRun!=='function'||typeof ACHS==='undefined') return 'this build has no achievements';
     if(!window.__deploy||!window.__endRaid||!(window.__P&&window.__applyLoaded)||typeof renderStatCards!=='function') return 'SKIP: no raid or Mainframe in this fixture';
     var bad=[], snap=null, q, el, g=document.getElementById('statgrid');
     if(!g) return 'SKIP: no stats grid in this document';
     try{
       __topClear(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       q=__P(); q.ach={}; q.achN={}; q.achScan=1;
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over) return 'SKIP: staging: no raid';
       __endRaid('extract');
       q=__P();
       if(!q.ach||!q.ach.firstout) bad.push('a first extraction did not earn FIRST OUT');
       if(!q.ach||!q.ach.untouched) bad.push('an extraction without a hit did not earn UNTOUCHED');
       if(!(G&&G.achNew&&G.achNew.some(function(a){ return a.id==='firstout'; }))) bad.push('the new achievement was not handed to the end card');
       renderStatCards();
       el=document.getElementById('achlist');
       if(!el||!/FIRST OUT/.test(el.textContent||'')||!/OF 12/.test(el.textContent||'')) bad.push('the Mainframe does not list the achievements with a count ('+(el?(el.textContent||'').slice(0,80):'no list')+')');
       q=__P(); q.ach={}; q.achN={}; q.achScan=0;
       q.log=[{outcome:'extract',haul:25000,kills:{raider:2},dmg:{},downs:0,firstContact:5}];
       renderStatCards();
       if(!__P().ach.haul20k) bad.push('a $25,000 extraction already in the log did not earn MOTHERLODE when the list was first drawn');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ var al=document.getElementById('achlist'); if(al&&al.parentNode) al.parentNode.removeChild(al); }catch(_a){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.39',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
