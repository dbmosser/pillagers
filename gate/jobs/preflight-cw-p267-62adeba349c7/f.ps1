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

if ($s.Contains("  {v:'37.42',what:")) { throw "check 37.42 is in the fixture already" }

SubRx @'
  {v:'37.41',what:
'@ @'
  {v:'37.42',what:'job 267 probe: the swing through the key a player presses, and the four retargeted checks; never shipped',
   run:function(){
     if(typeof GATE_PROBE==='undefined') return 'no mark: this is the build before';
     window.__p267=(window.__p267|0)+1;
     function kd(c){ window.dispatchEvent(new KeyboardEvent('keydown',{code:c,key:c,bubbles:true,cancelable:true})); }
     function ku(c){ window.dispatchEvent(new KeyboardEvent('keyup',{code:c,key:c,bubbles:true,cancelable:true})); }
     if(window.__p267===1){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player, T=null, i, W=__weapons();
       for(i=0;i<g.ents.length;i++){ var e=g.ents[i]; if(e.kind==='raider'&&!e.downed&&!e.finished){ T=e; break; } }
       if(!T) return 'no pillager';
       T.merc=0; T.hostile=true; T.downed=false; T.finished=false; p.x=2020; p.y=3300;
       function gun(id){ var o={}; for(var k in W[id]) o[k]=W[id][k]; o.q='field'; o.qRank=1; return o; }
       function arm(){ T.hp=T.maxhp||80; T.downed=false; T.finished=false; T.x=p.x+28; T.y=p.y; p.face=0; p.meleeAt=undefined; p.lastShot=undefined; p.roll=0; g.barT=0; }
       function sw(c){ arm(); var m0=g.tel.melee||0, h0=T.hp; kd(c); var a=Math.round(h0-T.hp); T.x=p.x+28; T.y=p.y; __loop(performance.now()); ku(c); return c.slice(3)+':m'+((g.tel.melee||0)-m0)+'d'+a+'/'+Math.round(h0-T.hp); }
       var s='dealt('+p.wep.id+') '+sw('KeyV')+' '+sw('KeyZ');
       p.wep=gun('fists'); s+=' fists(mag'+p.wep.mag+') '+sw('KeyV')+' '+sw('KeyZ');
       p.wep=gun('rifle'); p.ammo=25; s+=' rifle '+sw('KeyV')+' '+sw('KeyZ')+' a'+p.ammo;
       arm(); var h0=T.hp, fr=meleeStrike(); s+=' fn='+fr+'d'+Math.round(h0-T.hp);
       // WHY THE FIRST PROBE READ d0: a frame turns him to the mouse, and that probe never faced him back at the target
       arm(); __loop(performance.now()); var f=p.face; T.hp=T.maxhp||80; T.x=p.x+28; T.y=p.y; p.meleeAt=undefined; p.lastShot=undefined; g.barT=0; h0=T.hp; kd('KeyZ'); ku('KeyZ');
       s+=' face='+f.toFixed(2)+' stale d'+Math.round(h0-T.hp);
       T.hp=T.maxhp||80; T.x=p.x+Math.cos(f)*28; T.y=p.y+Math.sin(f)*28; p.face=f; p.meleeAt=undefined; p.lastShot=undefined; g.barT=0; h0=T.hp; kd('KeyZ'); ku('KeyZ');
       s+=' aimed d'+Math.round(h0-T.hp);
       __topClear();
       return s;
     }
     function res(v){ var t=__REGRESS.find(function(x){return x.v===v}), r; if(!t) return v+':none'; try{ __runPrep(); __topClear(); r=t.run(); }catch(e){ r='threw '+e; } try{ __topClear(); }catch(_t){} return v+':'+(r?String(r).slice(0,50):'ok'); }
     return 'helper '+__meleeKey()+','+__meleeKeyName()+' km'+JSON.stringify(P.keymap||{})+' '+['10.64','11.27','11.38','25.67','35.74'].map(res).join(' ');
   }},
  {v:'37.41',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
