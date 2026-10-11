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

if ($s.Contains("  {v:'22.74',what:")) { throw "check 22.74 is in the fixture already" }

SubRx @'
  {v:'22.73',what:
'@ @'
  {v:'22.74',what:'wind-ups show on the use bar only: a Bandage used at 50 health and a plate slotted at no armour draw APPLYING BANDAGE and SLOTTING on the use bar, and no line said starts with Applying or Slotting',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy or draw a frame';
     if(typeof useMedical!=='function'||typeof useArmor!=='function'||!ITEMS.bandage) return 'SKIP: no Bandage, medical verb or plate verb in this build';
     var bad=[], g=null, p=null, keep=null, keepBag=null, _say=say, lines=[], oFT=ctx.fillText, rec=[], ak=null, k, i, hits=[], AP='APPL'+'YING', SL='SLOT'+'TING';
     function grab(){ rec=[]; ctx.fillText=function(s,x,y){ rec.push(String(s)); return oFT.apply(this,arguments); }; try{ __frame(0.001); } finally { delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; } }
     function drew(w){ for(var j=0;j<rec.length;j++) if(rec[j].indexOf(w)===0) return true; return false; }
     for(k in ITEMS) if(!ak&&ITEMS[k]&&ITEMS[k].use==='armor') ak=k;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       p=g.player; g.ents.length=0; g.bagOpen=false; g.mapOpen=false;
       keep={hp:p.hp,maxhp:p.maxhp,prep:p.prep,prepA:p.prepA,armor:p.armor,armorCap:p.armorCap,healQ:p.healQ,iv:p.iv};
       keepBag=g.bag.slice();
       p.iv=99; p.maxhp=100; p.hp=50; p.healQ=0; p.prep=null; p.prepA=null;
       g.bag=['bandage'];
       say=function(m){ lines.push(String(m)); try{ return _say.apply(this,arguments); }catch(_s){} };
       // ONE: a Bandage at 50 health.
       useMedical();
       if(!p.prep) return 'SKIP: staging: a Bandage at 50 health started no wind-up here ('+lines.join(' | ')+')';
       grab();
       if(!drew(AP+' ')) return 'SKIP: the use bar drew no '+AP+' line here, so it cannot be the line that says it';
       // TWO: a plate at no armour.
       if(ak){
         p.armorCap=60; p.armor=0; g.bag.push(ak);
         useArmor();
         if(p.prepA){ grab(); if(!drew(SL+' ')) bad.push('a plate going on drew no '+SL+' line on the use bar'); }
       }
       for(i=0;i<lines.length;i++){ var u=lines[i].toUpperCase(); if(u.indexOf(AP)===0||u.indexOf(SL)===0) hits.push(lines[i]); }
       if(hits.length) bad.push('the wind-up said '+hits.length+' feed lines the use bar already draws: '+hits.join(' | '));
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       say=_say;
       try{ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; }catch(_f){}
       try{ if(p&&keep){ for(var f2 in keep){ if(keep[f2]===undefined) delete p[f2]; else p[f2]=keep[f2]; } } if(g&&keepBag) g.bag=keepBag; }catch(_k){}
       try{ var g2=__state(); if(g2){ g2.msgT=0; g2.msg=''; g2.feed=[]; g2.msgQ=[]; g2.msgQM=[]; g2.alert=null; g2.alertQ=[]; g2.pick=[]; } if(g2&&!g2.over){ g2.player.downed=false; g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.73',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
