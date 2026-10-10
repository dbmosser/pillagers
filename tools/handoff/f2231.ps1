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

if ($s.Contains("  {v:'22.31',what:")) { throw "check 22.31 is in the fixture already" }

SubRx @'
  {v:'22.30',what:
'@ @'
  {v:'22.31',what:'a FASHION tile that needs two or three Warden kills says how many and how far he has got, and a one-kill tile still says put a Warden down',
   run:function(){
     if(typeof cosNeed!=='function'||typeof cosOwned!=='function'||typeof COSMETICS==='undefined'||typeof renderCosmetics!=='function') return 'SKIP: no FASHION racks here';
     var bad=[], oK=P.kills, oAll=P.cosAll, kk={}, k, i, c, one=null, two=null, three=null, box, el, t;
     for(i=0;i<COSMETICS.length;i++){ c=COSMETICS[i]; if(c.how==='warden:1'&&!one) one=c; if(c.how==='warden:2'&&!two) two=c; if(c.how==='warden:3'&&!three) three=c; }
     if(!one||!two||!three) return 'SKIP: no Warden tiles of one, two and three kills';
     try{
       if(oK&&typeof oK==='object') for(k in oK) kk[k]=oK[k];
       kk.warden=1; P.kills=kk; P.cosAll=false;
       if(cosOwned(three)||cosOwned(two)) return 'SKIP: staging: a two or three kill tile is open after one kill';
       if(!cosOwned(one)) return 'SKIP: staging: a one kill tile is shut after one kill';
       t=cosNeed(three);
       if(t!=='put 3 Wardens down (1 of 3)') bad.push('a three kill tile after one kill reads "'+t+'"');
       t=cosNeed(two);
       if(t!=='put 2 Wardens down (1 of 2)') bad.push('a two kill tile after one kill reads "'+t+'"');
       kk.warden=0;
       t=cosNeed(one);
       if(t!=='put a Warden down') bad.push('a one kill tile now reads "'+t+'"');
       kk.warden=1;
       box=document.createElement('div');
       renderCosmetics(box,two.kind);
       el=box.querySelector('.costile[data-id="'+two.id+'"] .cosreq');
       if(!el) bad.push('the '+two.name+' tile was not drawn');
       else if(el.textContent!=='put 2 Wardens down (1 of 2)') bad.push('the '+two.name+' tile in FASHION reads "'+el.textContent+'" after one Warden kill');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       if(oK===undefined) delete P.kills; else P.kills=oK;
       if(oAll===undefined) delete P.cosAll; else P.cosAll=oAll;
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.30',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
