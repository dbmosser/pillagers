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

if ($s.Contains("  {v:'34.01',what:")) { throw "check 34.01 is in the fixture already" }

SubRx @'
  {v:'34.00',what:
'@ @'
  {v:'34.01',what:'every item icon has one to five cream rarity pips in menus, backpack and belt, in every colour mode',
   run:function(){
     var ranks=['common','uncommon','rare','elite','gold'], keysByRank={}, oldCb=CFG.cb, oldSpr=ICONSPR, oldURL=_iconURL, oldCreate=document.createElement, cv2=document.createElement('canvas'), menuCanvas=null, c, i,j,m,key,d,x,y,want,bad=[];
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       Object.keys(ITEMS).forEach(function(k){if(ITEMS[k].use==='gun') keysByRank[dispR(k)]=k;});
       cv2.width=160; cv2.height=160; c=cv2.getContext('2d');
       function pixels(label,cx,cy,S){
         for(j=0;j<5;j++){
           x=Math.floor(cx-S*.29+j*S*.145); y=Math.floor(cy+S*.48);
           d=c.getImageData(x,y,1,1).data; want=j<i+1;
           if(want?!(d[0]>200&&d[1]>200&&d[2]>180&&d[3]>240):!(d[0]<35&&d[1]<35&&d[2]<35&&d[3]>240)) bad.push(label+' '+ranks[i]+' pip '+(j+1)+' wrong');
         }
       }
       for(m=0;m<4;m++){
         CFG.cb=m; cbApply(); ICONSPR={m:{},n:0}; _iconURL={};
         for(i=0;i<ranks.length;i++){
           key=keysByRank[ranks[i]]; if(!key) return 'no gun staged for '+ranks[i];
           c.clearRect(0,0,160,160); drawItemIcon(c,key,80,60,80); pixels('direct mode '+m,80,60,80);
           c.clearRect(0,0,160,160); drawIconSprite(c,key,80,60,80); pixels('sprite mode '+m,80,60,80);
           menuCanvas=null;
           document.createElement=function(tag){var el=oldCreate.apply(this,arguments);if(tag==='canvas'&&!menuCanvas) menuCanvas=el;return el;};
           try{itemIconURL(key,80);}finally{document.createElement=oldCreate;}
           if(!menuCanvas) return 'menu icon was not painted';
           c.clearRect(0,0,160,160); c.drawImage(menuCanvas,40,20,80,80); pixels('menu mode '+m,80,60,80*.82);
         }
       }
       return bad.length?bad.slice(0,8).join('; '):null;
     }finally{ document.createElement=oldCreate; CFG.cb=oldCb; cbApply(); ICONSPR=oldSpr; _iconURL=oldURL; __topClear(); }
   }},
  {v:'34.00',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
