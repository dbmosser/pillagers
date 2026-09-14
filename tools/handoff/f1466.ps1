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

SubRx @'
  {v:'14.65',what:
'@ @'
  {v:'14.66',what:'the weather hint does not promise a bonus Blackout Protocol cancels: blackout weather at night reads the XP bonus without the term, and no bonus with the term signed (ascent audit finding 2)',
   run:function(){
     if(typeof syncSectorWx!=='function'||typeof wxPicked!=='function'||typeof hasTerm!=='function'||typeof isDay!=='function') return 'SKIP: no sector weather hint in this build';
     var hint=document.getElementById('wxhint');
     if(!hint||!document.getElementById('sectorwx')) return 'SKIP: no weather hint elements in this document';
     var bad=[], _wp=wxPicked, _ht=hasTerm, _id=isDay;
     try{
       wxPicked=function(){ return 'blackout'; }; isDay=function(){ return false; };
       // CONTROL: no term, blackout at night promises the bonus.
       hasTerm=function(){ return false; };
       syncSectorWx();
       if(String(hint.textContent).indexOf('x.')<0) return 'SKIP: blackout at night did not promise the bonus here ("'+String(hint.textContent).slice(0,60)+'")';
       // THE FIX: the term signed.
       hasTerm=function(id){ return id==='blackout'; };
       syncSectorWx();
       var tx=String(hint.textContent);
       if(tx.indexOf('No bonus')<0) bad.push('with Blackout Protocol signed the hint said "'+tx.slice(0,80)+'", a bonus the run never pays');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ wxPicked=_wp; hasTerm=_ht; isDay=_id; try{ syncSectorWx(); }catch(_s){} }
     return bad.length?bad.join('; '):null; }},
  {v:'14.65',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
