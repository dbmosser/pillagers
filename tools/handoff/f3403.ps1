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

if ($s.Contains("  {v:'34.03',what:")) { throw "check 34.03 is in the fixture already" }

SubRx @'
  {v:'34.02',what:
'@ @'
  {v:'34.03',what:'backpack rarity pips are at least eight solid pixels tall on a 52px item icon',
   run:function(){
     var cv2=document.createElement('canvas'),c,k=null,d,x,y,y0,y1,n=0,S=52,pass,oldSpr=ICONSPR;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       Object.keys(ITEMS).some(function(id){if(ITEMS[id].use==='gun'&&dispR(id)==='gold'){k=id;return true;}return false;});
       if(!k)return 'no gold icon staged';
       cv2.width=100;cv2.height=100;c=cv2.getContext('2d',{willReadFrequently:true});ICONSPR={m:{},n:0};
       x=Math.floor(50-S*.29);y0=Math.ceil(40+S*.39);y1=Math.ceil(40+S*.57);
       for(pass=0;pass<2;pass++){
         c.clearRect(0,0,100,100);
         if(pass)drawIconSprite(c,k,50,40,S);else drawItemIcon(c,k,50,40,S);
         d=c.getImageData(x,y0,1,y1-y0).data;n=0;
         for(y=0;y<d.length;y+=4)if(d[y]>200&&d[y+1]>200&&d[y+2]>180&&d[y+3]>240)n++;
         if(n<8)return (pass?'cached':'direct')+' rank pip is only '+n+' solid pixels tall';
       }
       return null;
     }finally{ICONSPR=oldSpr;__topClear();}
   }},
  {v:'34.02',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
