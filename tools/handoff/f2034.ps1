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

if ($s.Contains("  {v:'20.34',what:")) { throw "check 20.34 is in the fixture already" }

SubRx @'
  {v:'20.33',what:
'@ @'
  {v:'20.34',what:'an armoury gun dropped for the party leaves this window armoury list, so an abandon cannot put it back while the host keeps it',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET||typeof dropItem!=='function') return 'SKIP: no raid or party in this fixture';
     var NK={}, k, bad=[], oSend=netSend, sent=[], gk=null, key=null, rs0, i, ks=Object.keys(ITEMS);
     for(i=0;i<ks.length;i++) if(/^gun_/.test(ks[i])&&ITEMS[ks[i]]&&ITEMS[ks[i]].gk){ key=ks[i]; gk=ITEMS[key].gk; break; }
     if(!key) return 'SKIP: no armoury gun item here';
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over||!G.player) return 'SKIP: staging: no raid';
       rs0=P.raidSpliced;
       NET.on=true; NET.role='join'; NET.seat=1; NET.max=4; NET.peers=[{seat:0,state:'in'}]; NET.upSeed=G.seed>>>0;
       netSend=function(q,m){ sent.push(m); return true; };
       G.spliced=[gk]; P.raidSpliced=[gk]; G.bag.push(key);
       dropItem(G.bag.length-1);
       if(!sent.some(function(m){ return m.t==='pile'&&m.k===key; })) bad.push('no pile word went to the host');
       if(G.spliced.indexOf(gk)>=0) bad.push('the dropped gun is still on the raid list of armoury guns carried up');
       if(P.raidSpliced.indexOf(gk)>=0) bad.push('the dropped gun is still on the saved list an instant quit puts back');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       netSend=oSend;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ if(G&&!G.over){ G.spliced=[]; G.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       if(rs0!==undefined) P.raidSpliced=rs0;
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.33',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
