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

if ($s.Contains("  {v:'37.41',what:")) { throw "check 37.41 is in the fixture already" }

SubRx @'
  {v:'37.40',what:
'@ @'
  {v:'37.41',what:'job 267 diagnostic: what the melee key does on this build; never shipped',
   run:function(){
     if(typeof GATE_PROBE==='undefined') return 'no mark: this is the build before';
     window.__d267=(window.__d267|0)+1;
     function kd(c){ window.dispatchEvent(new KeyboardEvent('keydown',{code:c,key:c,bubbles:true,cancelable:true})); }
     function ku(c){ window.dispatchEvent(new KeyboardEvent('keyup',{code:c,key:c,bubbles:true,cancelable:true})); }
     function res(v,n){ var t=__REGRESS.find(function(x){return x.v===v}), r; if(!t) return v+':none'; try{ __runPrep(); __topClear(); r=t.run(); }catch(e){ r='threw '+e; } try{ __topClear(); }catch(_t){} return v+':'+(r?String(r).slice(0,n):'ok'); }
     if(window.__d267===1){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player, T=null, i, W=__weapons();
       for(i=0;i<g.ents.length;i++){ var e=g.ents[i]; if(e.kind==='raider'&&!e.downed&&!e.finished){ T=e; break; } }
       if(!T) return 'no pillager';
       T.merc=0; T.hostile=true; T.downed=false; T.finished=false; p.x=2020; p.y=3300; p.face=0;
       function arm(){ T.hp=T.maxhp||80; T.x=p.x+28; T.y=p.y; T.downed=false; p.meleeAt=undefined; p.lastShot=undefined; p.roll=0; g.barT=0; }
       function sw(c){ arm(); var m0=g.tel.melee||0, h0=T.hp; kd(c); T.x=p.x+28; T.y=p.y; __loop(performance.now()); ku(c); return c.slice(3)+':m'+((g.tel.melee||0)-m0)+'d'+Math.round(h0-T.hp); }
       var md=[].map.call(document.querySelectorAll('.modal.on'),function(x){ return x.id; }).join(',');
       var s='km'+JSON.stringify(P.keymap||{})+' v'+P.keymapV+' V>'+keyRemap('KeyV')+' Z>'+keyRemap('KeyZ')+' of='+keysOf('KeyV')+' po'+(pauseOpen?1:0)+' mf'+(g.mapFirst?1:0)+' gp'+(g.paused?1:0)+' se'+(g.searching?1:0)+' ro'+p.roll+' ck'+(p.cooking?1:0)+' md['+md+']';
       s+=' bare('+p.wep.id+','+p.wep.mag+') '+sw('KeyV')+' '+sw('KeyZ');
       arm(); var h0=T.hp, fr=meleeStrike(); s+=' fn='+fr+'d'+Math.round(h0-T.hp);
       var gun={}; for(var k in W.rifle) gun[k]=W.rifle[k]; gun.q='field'; gun.qRank=1; p.wep=gun; p.ammo=25;
       s+=' rifle '+sw('KeyV')+' '+sw('KeyZ')+' a'+p.ammo;
       __topClear();
       return s;
     }
     var v0=window.__meleeKey, ids=['10.64','11.27','11.38'], a=ids.map(function(v){ return res(v,24); }).join(' ');
     window.__meleeKey=function(){ return keysOf('KeyV'); };
     var b=ids.map(function(v){ return res(v,44); }).join(' ');
     window.__meleeKey=v0;
     return 'NOW '+a+' FOLLOWMAP '+b;
   }},
  {v:'37.40',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
