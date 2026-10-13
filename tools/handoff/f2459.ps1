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

if ($s.Contains("  {v:'24.59',what:")) { throw "check 24.59 is in the fixture already" }

SubRx @'
  {v:'24.58',what:
'@ @'
  {v:'24.59',what:'his answer 34 a: a machine beeps (lockon, on the machine bus) the moment it acquires him, once per machine in three seconds; a pillager does not beep',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof mkSentry!=='function'||typeof updateEnts!=='function') return 'SKIP: no raid here';
     var bad=[], g, p, S=null, R=null, E0=null, oSfx=sfx, own=false, heard=[], f, i, osc=0;
     function look(e){ e.face=Math.atan2(p.y-e.y,p.x-e.x); e.state='patrol'; e.alert=0; e.tx=e.x; e.ty=e.y; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||!p) return 'SKIP: no live raid';
       p.iv=99; p.crouch=false;
       S=mkSentry(p.x+140,p.y); look(S);
       E0=g.ents; g.ents=[S];
       sfx=function(t){ heard.push(String(t)); }; own=true;
       g.beepAt=-99; g.seenT=0;
       for(f=0;f<4&&S.state!=='chase';f++) updateEnts(0.016);
       if(S.state!=='chase') return 'SKIP: staging: the sentry 140 away facing him did not acquire him ('+S.state+')';
       if(heard.indexOf('lockon')<0) bad.push('a sentry that acquired him made no lock-on beep ('+(heard.join(',')||'nothing')+')');
       heard.length=0; look(S); g.t+=1; g.beepAt=-99;
       for(f=0;f<4&&S.state!=='chase';f++) updateEnts(0.016);
       if(heard.indexOf('lockon')>=0) bad.push('the same machine beeped again inside three seconds');
       var rs=g.ents; g.ents=E0; E0=null;
       for(i=0;i<g.ents.length;i++) if(g.ents[i]&&g.ents[i].kind==='raider'&&!g.ents[i].merc&&g.ents[i].hp>0){ R=g.ents[i]; break; }
       if(R){
         var kr={x:R.x,y:R.y,face:R.face,state:R.state,alert:R.alert,tx:R.tx,ty:R.ty};
         E0=g.ents; R.x=p.x-140; R.y=p.y; look(R); g.ents=[R]; heard.length=0; g.beepAt=-99;
         for(f=0;f<4&&R.state!=='chase';f++) updateEnts(0.016);
         g.ents=E0; E0=null;
         if(heard.indexOf('lockon')>=0) bad.push('a pillager beeped like a machine');
         R.x=kr.x; R.y=kr.y; R.face=kr.face; R.state=kr.state; R.alert=kr.alert; R.tx=kr.tx; R.ty=kr.ty;
       }
       if(SND_CAT.lockon!=='mach') bad.push('the lock-on beep is not on the machine bus ('+SND_CAT.lockon+')');
       if(typeof __audio==='object'&&__audio.record&&__audio.blipRaw){
         var lg=__audio.record(function(){ __audio.blipRaw('lockon'); });
         osc=(lg&&lg.osc)?lg.osc.length:0;
         if(osc<2) bad.push('the lock-on beep makes '+osc+' oscillators, so it plays nothing');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ if(own) sfx=oSfx; try{ var g2=__state(); if(g2){ if(E0) g2.ents=E0; if(!g2.over){ g2.player.iv=0; __endRaid('abandon'); } } }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'24.58',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
