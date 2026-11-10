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

if ($s.Contains("  {v:'37.68',what:")) { throw "check 37.68 is in the fixture already" }

SubRx @'
  {v:'37.67',what:
'@ @'
  {v:'37.68',what:'cw-cx-wornbody: six worn slots draw three variants per rarity in both body renderers, no jewelry or wardrobe overlay; old saves reload unchanged',run:function(){
    if(typeof wornBodyLook!=='function'||typeof wornPxHead!=='function')return 'no worn gear body renderer';
    var saved=P,oldStore=storeSet,oldSave=saveProfile,oldDraw=WORN_DRAW,oldWC=wc,oldSim,oldArc,arc=typeof ARCADE==='object'&&ARCADE,bad=[],base,snap,k,i,r,v,s,L,empty,seen={},cv,st={hero:1,own:{hp:100},moving:false},g;
    function need(ok,msg){if(!ok)bad.push(msg);}
    function sig(){var d=cv.getContext('2d').getImageData(0,0,180,180).data,h=2166136261;for(var j=0;j<d.length;j++){h^=d[j];h=Math.imul(h,16777619);}return h>>>0;}
    function body(pixel){cv.getContext('2d').clearRect(0,0,180,180);wc=cv.getContext('2d');wc.save();wc.translate(90,150);wc.scale(pixel?2:3,pixel?2:3);if(pixel){var a=pxBuildUpper({head:'short',skin:'fair',clothes:'scav',bot:0,mir:0,pup:0,arms:1}),b=pxBuildLegs({clothes:'scav',bot:0,mir:0,kind:'s',fr:0});wc.drawImage(b.c,-b.ax,-b.ay);wc.drawImage(a.c,-a.ax,-a.ay);}else drawOpB(0,0,0,0,'#777777',0,0,'none',0,st);wc.restore();return sig();}
    try{
      __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
      storeSet=function(){};saveProfile=function(){};
      base=JSON.parse(JSON.stringify(P));base.cfg=JSON.parse(JSON.stringify(CFG));base.cfgv=18;
      base.credits=12345;base.stash=['scrap','core'];base.weapons=['pistol','smg'];base.equipped='smg';
      // The build before has these same fields; this render-only job adds none.
      base.gear=[];base.worn={};base.worn.head=wornCleanPc(wornMake('head',2,46,9001));base.worn.head.id='wg9001';
      function keep(p){var q={};['credits','stash','weapons','equipped','contracts','forged','pil','hall','lifeEarn','gear','worn','cosSkin','cosCut','cosBought'].forEach(function(n){q[n]=p[n];});return JSON.stringify(q);}
      var before=keep(base);applyLoadedProfile({value:JSON.stringify(base)});need(keep(P)===before,'old save lost gear, body or account data');
      snap=JSON.parse(JSON.stringify(P));applyLoadedProfile({value:JSON.stringify(snap)});need(keep(P)===keep(snap),'second reload moved old save');
      __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242});g=__state();oldSim=g.sim;oldArc=arc&&arc.on;if(arc)arc.on=false;g.sim=false;
      need(g.ents.length===85&&g.containers.length===165,'seed 4242 map zero fingerprint moved');
      cv=document.createElement('canvas');cv.width=cv.height=180;
      P.worn={};empty=wornBodyLook(st);need(empty&&Object.keys(empty.g).length===0,'empty wear paints gear');
      for(i=0;i<WORN_BODY_SLOTS.length;i++){
        s=WORN_BODY_SLOTS[i];seen={};
        for(r=0;r<4;r++)for(v=0;v<3;v++){
          P.worn={};P.worn[s]=wornMake(s,r,45+v,124+r*3+v);L=wornBodyLook(st);WORN_DRAW=L;
          need(L.g[s]&&L.g[s].r===r&&L.g[s].v===v,'slot or rarity lost: '+s+r+v);
          k=body(true);need(!seen['p'+k],'duplicate pixel variant '+s+r+v);seen['p'+k]=1;
          k=body(false);need(!seen['v'+k],'duplicate smooth variant '+s+r+v);seen['v'+k]=1;
          P.worn={};need(wornBodyLook(st).key===empty.key,'removed piece still has look');
        }
      }
      P.worn={amulet:wornMake('amulet',3,50,2),ring1:wornMake('ring',3,50,3)};need(wornBodyLook(st).key===empty.key,'jewelry visible');
      P.cosOutfit='outskeleton';P.cosHat='hood';WORN_DRAW=empty;L=pxLookOf(st);
      need(L&&L.clothes!=='skeleton'&&L.head!=='hood','saved wardrobe overrides gear/body');
      P.worn={};P.gear=[];var pc=wornAdd(P,wornMake('pack',2,47,555));
      need(wornBodyLook(st).key===empty.key,'stashed gear is visible');
      wornWear(P,pc.id,'pack');need(!!wornBodyLook(st).g.pack,'equipping pack does not show it');
      wornOff(P,'pack');need(wornBodyLook(st).key===empty.key,'unequipped pack still visible');
      need(wornBodyLook({hero:0})===null,'other pillager borrowed local gear');g.sim=true;need(wornBodyLook(st)===null,'sim uses saved gear');g.sim=false;
      if(arc){arc.on=true;need(wornBodyLook(st)===null,'demo uses career gear');arc.on=false;}
      need(!pixWear('clothes','heavy',false)&&!pixWear('set','skeleton',false),'fashion clothing still selectable');
      WORN_DRAW=null;need(wornBodyChoice('hat')===null,'gear context leaked outside render');
      return bad.length?bad.join('; '):null;
    }finally{
      wc=oldWC;WORN_DRAW=oldDraw;storeSet=oldStore;saveProfile=oldSave;
      if(g)g.sim=oldSim;if(arc&&oldArc!==undefined)arc.on=oldArc;
      try{__endRaid('abandon');}catch(e){}P=saved;__topClear();
    }
  }},
  {v:'37.67',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
