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
  {v:'14.77',what:
'@ @'
  {v:'14.78',what:'his vocabulary in the raid and the rewards: no season reward name and neither refusal for putting a gun away from its belt key uses the retired word for the backpack (first-hour audit findings 2 and 3)',
   run:function(){
     if(typeof SEASON_TIERS==='undefined'||typeof tierLabel!=='function'||typeof bagHeldGun!=='function'||!window.__startRaid) return 'SKIP: no reward list or belt drop in this build';
     var W=new RegExp('\\b'+'ba'+'g'+'\\b','i'), bad=[];
     var labs=SEASON_TIERS.map(function(T){ return String(tierLabel(T)||''); });
     // CONTROL: the reward names are there, frags among them.
     if(!labs.some(function(l){ return (/FRAGS/i).test(l); })) return 'SKIP: no frag reward is named here';
     labs.forEach(function(l){ if(W.test(l)) bad.push('the season reward '+l+' uses a retired word'); });
     function rd(){ return (G&&G.msg)?((typeof G.msg==='string')?G.msg:JSON.stringify(G.msg)):''; }
     try{
       __topClear(); __startRaid({mapIx:0,seed:4242});
       var pl=G&&G.player; if(!pl) return 'SKIP: no player in the raid';
       var keepW=pl.wep, keepS=pl.swapped, keepI=pl.wepIssued;
       pl.swapped=false; pl.wep=WEAPONS.fists; G.msg=null;
       bagHeldGun('gunA'); var m1=rd();
       pl.wep={id:'zzqnoitem',name:'Probe Gun',mag:5}; pl.wepIssued=false; G.msg=null;
       bagHeldGun('gunA'); var m2=rd();
       pl.wep=keepW; pl.swapped=keepS; pl.wepIssued=keepI;
       // CONTROL: both refusals said something.
       if(!m1||!m2) return 'SKIP: a refused belt drop said nothing here ('+m1+' / '+m2+')';
       if(W.test(m1)) bad.push('with nothing in hand the belt drop says: '+m1);
       if(W.test(m2)) bad.push('a gun with no backpack item says: '+m2);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'14.77',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
