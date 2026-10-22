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

if ($s.Contains("  {v:'34.04',what:")) { throw "check 34.04 is in the fixture already" }

SubRx @'
  {v:'34.03',what:
'@ @'
  {v:'34.04',what:'hostile human pillagers have triangles and unnumbered allies have plus signs with pixel or vector bodies',
   run:function(){
     if(typeof worldSideCue!=='function'||typeof colourCueGlyph!=='function')return 'world allegiance has no shape backup';
     var oldW=wc,oldPix=CFG.xfPix,oldR=RIM.on,oldCue=worldSideCue,oldSeat=seatMarkOf,calls=[],cv2=document.createElement('canvas'),c,g,st,mode,side,d;
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();__deploy({kit:['gun_rifle'],seed:4242,mapIx:0});g=__state();
       cv2.width=240;cv2.height=180;c=cv2.getContext('2d');wc=c;RIM.on=1;seatMarkOf=function(){return -1;};
       worldSideCue=function(x,y,st){calls.push(st.team);return oldCue.apply(this,arguments);};
       for(mode=0;mode<2;mode++)for(side=0;side<2;side++){
         CFG.xfPix=mode;pixFrame();c.clearRect(0,0,240,180);calls=[];
         st={hero:0,team:side?'ally':'foe',own:{hp:100},moving:false,ads:false,hurt:0,bulk:0,build:'lean',outfit:'outnone',skin:'fair',cut:'crop'};
         drawOp(100,130,0,0,'#46535a',0,0,'none',0,st);
         if(calls.length!==1||calls[0]!==st.team)return 'body path '+mode+' did not draw its side cue';
         d=c.getImageData(82,101,1,1).data;if(d[3]<240)return 'side cue was not painted in body path '+mode;
       }
       c.clearRect(0,0,240,180);colourCueGlyph(c,'ally',30,30,1,'#aaaaaa');
       d=c.getImageData(25,30,1,1).data;if(d[0]<200)return 'ally has no horizontal plus arm';
       d=c.getImageData(25,25,1,1).data;if(d[0]>100)return 'ally plus has a filled corner';
       c.clearRect(0,0,240,180);colourCueGlyph(c,'foe',30,30,1,'#aaaaaa');d=c.getImageData(30,25,1,1).data;if(d[0]<150)return 'hostile has no triangle apex';
       return null;
     }finally{wc=oldW;CFG.xfPix=oldPix;RIM.on=oldR;worldSideCue=oldCue;seatMarkOf=oldSeat;try{__endRaid('abandon');}catch(_e){}__topClear();}
   }},
  {v:'34.03',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
