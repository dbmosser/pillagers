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

if ($s.Contains("  {v:'21.77',what:")) { throw "check 21.77 is in the fixture already" }

SubRx @'
  {v:'21.76',what:
'@ @'
  {v:'21.77',what:'his note: a Listener touching a player who stands still keeps striking and never goes dormant at his side',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__sim) return 'SKIP: no raid here';
     var bad=[], g, p, all, e, hpAt8=null, st=[];
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; if(!g||g.over) return 'SKIP: no live raid';
       all=g.ents.slice(); e=all.filter(function(x){ return x.kind==='listener'&&x.hp>0; })[0];
       if(!e) return 'SKIP: no Listener on this map';
       g.ents=[e]; p.hp=100000; p.iv=0; p.armor=0; p.downed=false;
       for(var k in keys) keys[k]=false;
       e.x=p.x+(e.r+(p.r||11)+2); e.y=p.y; e.state='hunt'; e.wakeT=0; e.heardX=p.x; e.heardY=p.y; e.millT=0; e.cd=0; e.windup=null;
       for(var i=0;i<12*60;i++){
         __sim(1/60);
         if(i===8*60) hpAt8=p.hp;
         if(i%120===0) st.push(e.state);
       }
       if(e.state==='dormant') bad.push('the Listener went dormant beside a player standing still ('+st.join(',')+')');
       if(hpAt8!==null&&!(p.hp<hpAt8)) bad.push('the Listener struck nothing after 8 seconds at his side');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{ try{ if(all) g.ents=all; var g2=__state(); if(g2&&!g2.over){ g2.player.hp=100; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'21.76',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
