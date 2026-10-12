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

if ($s.Contains("  {v:'23.60',what:")) { throw "check 23.60 is in the fixture already" }

SubRx @'
  {v:'23.59',what:
'@ @'
  {v:'23.60',what:'his note: a round that MISSES a running pillager turns him too (hostile, chasing, firing back), as one that lands does',
   run:function(){
     var bad=[], g, p, all, e, bl, sv={};
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; all=g.ents.slice(); bl=g.bullets.slice();
       e=all.filter(function(x){ return x.kind==='raider'&&!x.merc&&!x.friendlyPC&&x.hp>0; })[0];
       if(!e) return 'SKIP: no pillager on this map';
       g.ents=[e]; g.bullets=[];
       e.state='extract'; e.fled=1; e.hostile=true; e.cornered=0; e.alert=0; e.retT=0; e.roll=0; e.hp=Math.max(1,Math.floor(e.maxhp*0.2));
       var hp0=e.hp, off=e.r+18;
       g.bullets.push({x:e.x,y:e.y+off,vx:0.01,vy:0,dmg:0,life:0.5,player:true,owner:p,tint:'#ffffff',thru:0});
       updateBullets(0.016);
       if(e.hp!==hp0) bad.push('the staged round was meant to miss and hit him (hp '+hp0+' to '+e.hp+')');
       if(e.state==='extract') bad.push('control: a round '+off+' from a running pillager left him running for the ring');
       else if(e.state!=='chase'||e.hostile!==true||!(e.retT>0)) bad.push('the missed pillager did not turn on you: state '+e.state+', hostile '+e.hostile+', retT '+e.retT);
       var f={kind:'raider',friendlyPC:1,hostile:false,merc:0,hp:50,maxhp:100,r:e.r,x:e.x,y:e.y,state:'extract',alert:0};
       g.ents=[f]; g.bullets=[{x:f.x,y:f.y+off,vx:0.01,vy:0,dmg:0,life:0.5,player:true,owner:p,tint:'#ffffff',thru:0}];
       updateBullets(0.016);
       if(f.state!=='extract'||f.hostile!==false) bad.push('a round past a pillager who joined you turned him on you');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{ try{ if(all) g.ents=all; if(bl) g.bullets=bl; var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'23.59',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
