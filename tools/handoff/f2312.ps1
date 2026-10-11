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

if ($s.Contains("  {v:'23.12',what:")) { throw "check 23.12 is in the fixture already" }

SubRx @'
  {v:'23.11',what:
'@ @'
  {v:'23.12',what:'raid details are short, never explaining sentences: the gun key reads [5] GUN on the keyboard and [LB] [RB] GUN on a pad, a survivor who wants ammunition you lack says NOT ENOUGH AMMUNITION with Needs 40 rounds., a dead hire names the real death benefit, and no line keeps the old explaining details (hot ground, the seal, the controller, the recorder, a gun with no backpack form, the loaner headline)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)||typeof gunKeyLine!=='function'||typeof padOn!=='function'||typeof mkStray!=='function'||typeof strayGive!=='function') return 'SKIP: no gun key line or survivor here';
     var bad=[], src='', i, cut, ss, OLD, NEW, oPad=padOn, said=[], realSay=say, g=null, p=null, e, kl, pl, gc, n0;
     try{
       try{ ss=document.getElementsByTagName('script'); for(i=0;i<ss.length;i++) src+=ss[i].textContent||''; }catch(_s){}
       cut=src.indexOf('window.__frame=function'); if(cut>0) src=src.slice(0,cut);
       if(src.length>100000){
         OLD=['Extra loot'+' in here','What Meridian'+' sealed','You owe his'+' family','Plug it in,'+' then resume','stops it, or it'+' stops','A copy is in your'+' downloads',' has no backpack'+' form','YOU CARRY A'+' LOANER',"{sub:'He needs '+"+"aOrAn",'You cannot'+' spare'," for your"+" gun.'",'LB or RB to'+' your gun'];
         for(i=0;i<OLD.length;i++) if(src.indexOf(OLD[i])>=0) bad.push('the build still says '+JSON.stringify(OLD[i]));
         NEW=["'Death benefit $'"+"+MERC_DEATH","'Bonus"+" loot.'","'SAVED TO"+" DOWNLOADS'","'RECONNECT TO"+" RESUME'"];
         for(i=0;i<NEW.length;i++) if(src.indexOf(NEW[i])<0) bad.push('the build has no '+JSON.stringify(NEW[i]));
       }
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); keys={};
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; p.downed=false;
       padOn=function(){ return false; };
       gc=(typeof gunCell==='function')?gunCell():4;
       kl=String(gunKeyLine());
       if(kl!=='['+keyLabel('Digit'+(gc+1),String(gc+1))+'] GUN') bad.push('on the keyboard the gun key line reads '+JSON.stringify(kl));
       padOn=function(){ return true; };
       pl=String(gunKeyLine());
       if(!(/^\[\S+\] \[\S+\] GUN$/).test(pl)) bad.push('on a pad the gun key line reads '+JSON.stringify(pl));
       padOn=oPad;
       say=function(m,k,o){ said.push({m:String(m),sub:(o&&o.sub)?String(o.sub):''}); return realSay.apply(this,arguments); };
       e=mkStray(p.x+40,p.y); e.want='ammobox'; e.helped=0; p.reserve=0;
       for(i=g.bag.length-1;i>=0;i--) if(g.bag[i]==='ammobox') g.bag.splice(i,1);
       n0=said.length; strayGive(e);
       var need=(ITEMS.ammobox&&ITEMS.ammobox.amt)||40, hit=null;
       for(i=n0;i<said.length;i++) if(said[i].m.indexOf('AMMUNITION')>=0) hit=said[i];
       if(!hit) bad.push('a survivor who wants ammunition you lack said no AMMUNITION line ('+JSON.stringify(said.slice(n0))+')');
       else if(hit.m!=='NOT ENOUGH AMMUNITION'||hit.sub!=='Needs '+need+' rounds.') bad.push('the ammunition line reads '+JSON.stringify(hit.m+' | '+hit.sub));
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       padOn=oPad; say=realSay; keys={};
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.11',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
