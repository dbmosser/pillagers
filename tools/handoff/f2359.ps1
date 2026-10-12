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

if ($s.Contains("  {v:'23.59',what:")) { throw "check 23.59 is in the fixture already" }

SubRx @'
  {v:'23.58',what:
'@ @'
  {v:'23.59',what:'his note: a running pillager fired on turns hostile, fights back, and does not bolt again',
   run:function(){
     if(typeof runnerTurns!=='function') return 'control: a running pillager fired on keeps running';
     var bad=[], g, p, all, e;
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; all=g.ents.slice();
       e=all.filter(function(x){ return x.kind==='raider'&&!x.merc&&!x.friendlyPC&&x.hp>0; })[0];
       if(!e) return 'SKIP: no pillager on this map';
       g.ents=[e]; e.state='extract'; e.fled=1; e.hostile=false; e.hp=Math.max(1,Math.floor(e.maxhp*0.2)); e.x=p.x+300; e.y=p.y;
       if(!runnerTurns(e,p.x,p.y)) bad.push('runnerTurns refused a running pillager');
       if(e.state!=='chase'||e.hostile!==true||!(e.retT>0)) bad.push('the pillager did not turn: state '+e.state+', hostile '+e.hostile+', retT '+e.retT);
       for(var i=0;i<20;i++) __ents(0.05);
       if(e.hp>0&&!e.downed&&e.state==='extract') bad.push('the cornered pillager bolted again at low health');
       var hire={kind:'raider',merc:1,hp:50,state:'extract'};
       if(runnerTurns(hire,p.x,p.y)) bad.push('a hire running for the ring was turned on you');
       var src=[].slice.call(document.scripts).map(function(s){ return s.text||''; }).join('');
       if(src.indexOf('runnerTurns'+'(en,p.x,p.y)')<0) bad.push('your own rounds do not reach runnerTurns');
       if(src.indexOf('runnerTurns'+'(e,sx,sy)')<0) bad.push('a party round does not reach runnerTurns');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{ try{ if(all) g.ents=all; var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'23.58',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
