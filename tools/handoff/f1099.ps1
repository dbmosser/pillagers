$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'10.98',what:'every control on the character screen can be pressed without throwing
'@ @'
  {v:'10.99',what:'a pillager wears the hat, the beard and the tattoo his look rolled, and the fringe is still hers alone',
   run:function(){
     if(!(window.__opShot&&window.__canvases&&window.__P)) return 'SKIP: this fixture cannot draw one figure at a time';
     if(!__vpAlive()) return 'SKIP: the pane has no layout, there are no pixels to read';
     var bad=[];
     __runPrep(); __resetCfg(); __pinDefaults(0); __forceSize(1920,1080);
     var CN=__canvases(), wx=CN.world.getContext('2d'), Wd=CN.world.width, Hd=CN.world.height;
     function shot(look){ var r=__opShot(look,0,9); return r&&r.thrown?null:wx.getImageData(0,0,Wd,Hd).data; }
     function diff(a,b){ if(!a||!b) return -1; var k=0;
       for(var q=0;q<a.length;q+=4)
         if(Math.abs(a[q]-b[q])+Math.abs(a[q+1]-b[q+1])+Math.abs(a[q+2]-b[q+2])>24) k++;
       return k; }
     var BASE={hero:0,faceMark:'faceplain',eyes:'eyeblue',skin:'skinfair',hat:'none',
               hair:'blonde',cut:'long',beard:'clean',tattoo:'tatnone'};
     function look(over){ var o={},k; for(k in BASE) o[k]=BASE[k]; if(over) for(k in over) o[k]=over[k]; return o; }
     shot(look());                      // one warm draw, then the baseline
     var A=shot(look());
     if(!A) return 'drawing one pillager threw';
     // CONTROL FIRST: the same look twice must be identical, or every number
     // below is noise dressed as a finding.
     if(diff(A,shot(look()))!==0) bad.push('control: the same pillager drawn twice is not identical, so this instrument cannot measure a rack');
     // 1. THE THREE RACKS REACH A PILLAGER. Measured on v10.98 all three changed
     //    a pillager by exactly ZERO while changing the hero by thousands.
     var RACKS=[{k:'hat',v:'spartan',floor:2000,pk:'cosHat',hv:'spartan',h0:'none',name:'headgear'},
                {k:'beard',v:'fullbeard',floor:800,pk:'cosBeard',hv:'fullbeard',h0:'clean',name:'the beard'},
                {k:'tattoo',v:'tatspider',floor:300,pk:'cosTattoo',hv:'tatspider',h0:'tatnone',name:'the tattoo'}];
     var prof=__P(), i;
     for(i=0;i<RACKS.length;i++){
       var R=RACKS[i], o={}; o[R.k]=R.v;
       var d=diff(A,shot(look(o)));
       if(d<R.floor) bad.push(R.name+' changes a pillager by '+d+' pixels, so a rack he rolled is not drawn on him');
       // AND THE HERO STILL HAS IT. Fixing the pillager by breaking her would
       // pass every line above.
       var was=prof[R.pk];
       prof[R.pk]=R.h0; var H1=shot({hero:1});
       prof[R.pk]=R.hv; var H2=shot({hero:1});
       prof[R.pk]=was;
       var dh=diff(H1,H2);
       if(dh<300) bad.push('control: '+R.name+' now changes the operator by only '+dh+' pixels, so this was fixed by taking it off her');
     }
     // 2. AND THE FRINGE IS STILL HERS. It sits in the same branch and is the one
     //    thing in there that is her own styling rather than something picked up.
     //    Same look on both: v10.99 measures 30,490 pixels of difference, which is
     //    her hair. Ungating the whole branch would collapse this.
     var keep={}, KEYS=['cosHat','cosBeard','cosTattoo','cosHair','cosCut','cosSkin','cosEyes','cosFace','cosOutfit'];
     for(i=0;i<KEYS.length;i++) keep[KEYS[i]]=prof[KEYS[i]];
     prof.cosHat='none'; prof.cosBeard='clean'; prof.cosTattoo='tatnone'; prof.cosHair='blonde';
     prof.cosCut='long'; prof.cosSkin='skinfair'; prof.cosEyes='eyeblue'; prof.cosFace='faceplain';
     prof.cosOutfit='outnone';
     var dHP=diff(shot({hero:1}),shot(look()));
     for(i=0;i<KEYS.length;i++) prof[KEYS[i]]=keep[KEYS[i]];
     if(dHP<5000) bad.push('the operator and a pillager wearing the same things differ by only '+dHP+' pixels, so her own fringe has been handed out with the racks');
     // 3. CONTROL: A SUIT STILL OVERRULES THE RACKS, which is the order v10.54
     //    set and which this change reaches straight through.
     if(typeof OUTFITS!=='undefined'||typeof cosFind==='function'){
       var suited=look({outfit:'outskeleton',hat:'spartan'});
       var suitedNoHat=look({outfit:'outskeleton',hat:'none'});
       var ds=diff(shot(suited),shot(suitedNoHat));
       if(ds>400) bad.push('a hat is drawn over a full-body suit, '+ds+' pixels, and a suit is supposed to overrule every rack');
     }
     return bad.length?bad.join('; '):null; }},
  {v:'10.98',what:'every control on the character screen can be pressed without throwing
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
