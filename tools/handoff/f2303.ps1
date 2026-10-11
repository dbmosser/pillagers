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

if ($s.Contains("  {v:'23.03',what:")) { throw "check 23.03 is in the fixture already" }

SubRx @'
  {v:'23.02',what:
'@ @'
  {v:'23.03',what:'names keep their capitals: a survivor who needs an Armour Plate says HE NEEDS AN ARMOUR PLATE when you have none and SURVIVOR FOUND with He needs an Armour Plate. when found, never a armour plate, and an aid line for a teammate with no seat name starts with Your teammate',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof strayGive!=='function'||typeof mkStray!=='function'||typeof netAidFinish!=='function'||typeof canSee!=='function'||!ITEMS.plate) return 'SKIP: no survivor or teammate aid here';
     var bad=[], g=null, p=null, i, e, a, ang=0, rr=null, said=[], realSay=say, all, keepN={on:NET.on,seat:NET.seat,roster:NET.roster,up:NET.up,role:NET.role}, PN=ITEMS.plate.name, LOW='a '+'armour';
     function line(x){ return String(x.m)+(x.sub?(' | '+x.sub):''); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); keys={};
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; p.downed=false;
       say=function(m,k,o){ said.push({m:String(m),k:k,sub:(o&&o.sub)||''}); return realSay.apply(this,arguments); };
       // ONE: the give refusal
       for(i=g.bag.length-1;i>=0;i--) if(g.bag[i]==='plate') g.bag.splice(i,1);
       e=mkStray(p.x+40,p.y); e.want='plate'; e.helped=0;
       said.length=0; strayGive(e);
       all=said.map(line).join(' / ');
       if(!said.length) bad.push('giving a survivor who needs an '+PN+' with none on you said nothing');
       else {
         if(all.toLowerCase().indexOf(LOW)>=0) bad.push('the survivor refusal reads '+JSON.stringify(all)+', a lowercased name with the wrong article');
         if(all.toUpperCase().indexOf('NEEDS AN '+PN.toUpperCase())<0) bad.push('the survivor refusal does not say he needs an '+PN+': '+JSON.stringify(all));
       }
       // TWO: the found line, through the update
       for(a=0;a<16&&!rr;a++){ ang=a*Math.PI/8; var tx=p.x+Math.cos(ang)*110, ty=p.y+Math.sin(ang)*110; p.face=ang; if(canSee(p.x,p.y,p.face,tx,ty,g.vseg)) rr={x:tx,y:ty}; }
       if(rr){
         e=mkStray(rr.x,rr.y); e.want='plate'; e.helped=0; e.found=0; e.face=ang+Math.PI;
         g.ents.length=0; g.ents.push(e);
         said.length=0; __ents(0.016);
         if(e.found){
           all=said.map(line).join(' / ');
           if(all.toLowerCase().indexOf(LOW)>=0) bad.push('the survivor found line reads '+JSON.stringify(all));
           if(all.indexOf('He needs an '+PN+'.')<0) bad.push('the survivor found line does not read He needs an '+PN+'. ('+JSON.stringify(all)+')');
         }
       }
       // THREE: an aid line for a teammate with no seat name
       NET.roster=[]; NET.up=[]; NET.role='join';
       said.length=0;
       netAidFinish({aid:1,key:'bandage'});
       all=said.map(line);
       if(!all.length) bad.push('a heal for a teammate who moved away said nothing');
       else if(!(/^(Your teammate|YOUR TEAMMATE)/).test(all[0])) bad.push('an aid line for a teammate with no seat name reads '+JSON.stringify(all[0])+', not starting with Your teammate');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       say=realSay; NET.on=keepN.on; NET.seat=keepN.seat; NET.roster=keepN.roster; NET.up=keepN.up; NET.role=keepN.role; keys={};
       try{ var g2=__state(); if(g2){ g2.ents.length=0; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.02',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
