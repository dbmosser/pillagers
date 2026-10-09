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

if ($s.Contains("  {v:'21.34',what:")) { throw "check 21.34 is in the fixture already" }

SubRx @'
  {v:'21.33',what:
'@ @'
  {v:'21.34',what:'YOUR STATS names the usual killer the way the player knows it, in capitals: deaths logged to a raider read PILLAGER and deaths to the warden read WARDEN, never the lower case name the run log keeps',
   run:function(){
     if(typeof renderStatCards!=='function'||typeof P!=='object'||!P) return 'SKIP: no stat cards here';
     var g=document.getElementById('statgrid');
     if(!g) return 'SKIP: no stat grid on this page';
     var bad=[], log0=P.log, hadScan=Object.prototype.hasOwnProperty.call(P,'achScan'), scan0=P.achScan, v;
     function row(k,n){ return {n:n,outcome:'dead',deathKiller:k,haul:0,dur:97,containers:0,kills:{},shots:0,hits:0,acc:0,downs:0,revives:0,mapName:'COLD STORAGE'}; }
     function killer(){
       var c=g.querySelectorAll('.scard'), j, sk, sv;
       for(j=0;j<c.length;j++){ sk=c[j].querySelector('.sk'); sv=c[j].querySelector('.sv'); if(sk&&sv&&/usually killed/i.test(sk.textContent)) return String(sv.textContent).replace(/\s+/g,' ').trim(); }
       return null;
     }
     try{
       P.achScan=1;   // the achievements under the cards are not rescanned from the staged log
       P.log=[row('raider',1),row('raider',2),row('raider',3),row('warden',4)];
       renderStatCards(); v=killer();
       if(v===null) return 'SKIP: staging: no USUALLY KILLED BY card was drawn';
       if(v!=='PILLAGER') bad.push('three deaths to pillagers read '+JSON.stringify(v)+' on the card, not PILLAGER');
       P.log=[row('warden',1),row('warden',2),row('raider',3)];
       renderStatCards(); v=killer();
       if(v!=='WARDEN') bad.push('two deaths to the Warden read '+JSON.stringify(v)+' on the card, not WARDEN');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       P.log=log0;
       if(hadScan) P.achScan=scan0; else delete P.achScan;
       try{ renderStatCards(); }catch(_r){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'21.33',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
