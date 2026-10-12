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

if ($s.Contains("  {v:'23.66',what:")) { throw "check 23.66 is in the fixture already" }

SubRx @'
  {v:'23.65',what:
'@ @'
  {v:'23.66',what:'his note: your own frag into a running pillager turns him for good, as a round does',
   run:function(){
     if(typeof runnerTurns!=='function'||typeof explodeFrag!=='function') return 'SKIP: no runnerTurns or explodeFrag here';
     var bad=[], g, p, all, e;
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; all=g.ents.slice();
       e=all.filter(function(x){ return x.kind==='raider'&&!x.merc&&!x.friendlyPC&&x.hp>0; })[0];
       if(!e) return 'SKIP: no pillager on this map';
       g.ents=[e]; e.x=p.x+400; e.y=p.y; e.maxhp=2000; e.hp=400; e.state='extract'; e.fled=1; e.hostile=false; e.cornered=0;
       explodeFrag({x:e.x+60,y:e.y,t:0,fuse:0});
       if(e.hp>0&&!e.downed){
         for(var i=0;i<10;i++) __ents(0.05);
         if(e.state==='extract') bad.push('a pillager running for a ring went back to running after your frag (state '+e.state+', cornered '+e.cornered+')');
         if(e.cornered!==1) bad.push('the fragged runner was not cornered');
       } else return 'SKIP: the frag killed or downed the staged runner';
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{ try{ if(all) g.ents=all; var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; g2.player.hp=100; __endRaid('abandon'); } }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'23.65',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
