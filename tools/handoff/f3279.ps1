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

if ($s.Contains("  {v:'32.79',what:")) { throw "check 32.79 is in the fixture already" }

SubRx @'
  {v:'32.78',what:
'@ @'
  {v:'32.79',what:'J8 disabled reconnect has at least 7:1 text contrast and full opacity; only the loss overlay hides the faint HUD and unrelated toast; A restores the regular pause style',
   run:function(){
     var bad=[], pk=Object.assign({},PAD), b=document.getElementById('resumebtn'), box=document.getElementById('pausebox'), text=b.textContent, disabled=b.disabled, focus=b.classList.contains('padfocus'), toast=document.getElementById('hubtoast'), toastStyle=toast?toast.style.cssText:'';
     function ck(ok,s){if(!ok)bad.push(s);}
     function rgba(s){var n=String(s).match(/[\d.]+/g)||[];return n.map(Number);}
     function lum(a){var v=a.slice(0,3).map(function(x){x/=255;return x<=0.04045?x/12.92:Math.pow((x+0.055)/1.055,2.4);});return v[0]*0.2126+v[1]*0.7152+v[2]*0.0722;}
     function contrast(s){var a=lum(rgba(s.color)),c=lum(rgba(s.backgroundColor));return (Math.max(a,c)+0.05)/(Math.min(a,c)+0.05);}
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242});__topClear();
       if(pauseOpen)togglePauseBox(false);
       if(toast)toast.style.display='block';
       padLostStart(0);
       var s=getComputedStyle(b), bg=rgba(getComputedStyle(box).backgroundColor);
       ck(b.disabled&&b.textContent==='reconnect'&&contrast(s)>=7&&+s.opacity===1,'disabled reconnect contrast below 7:1 or dimmed');
       b.classList.add('padfocus');s=getComputedStyle(b);ck(contrast(s)>=7&&+s.opacity===1,'disabled focus dims reconnect');if(!focus)b.classList.remove('padfocus');
       ck(box.classList.contains('padlost')&&bg.length>=3&&(bg.length===3||bg[3]===1)&&lum(bg)<0.01,'loss overlay still shows the HUD through its backdrop');
       ck(toast&&getComputedStyle(toast).display==='none','unrelated toast remains over loss card');
       var gp={connected:true,index:0,id:'J8 contrast',axes:[0,0,0,0],buttons:[{pressed:false,value:0}]};
       padLostPoll(gp);ck(box.classList.contains('padlost')&&!b.disabled,'returned pad lost the scoped backdrop');
       gp.buttons[0]={pressed:true,value:1};padLostPoll(gp);
       ck(!pauseOpen&&!G.paused&&!box.classList.contains('padlost')&&(!toast||getComputedStyle(toast).display!=='none'),'A left the disconnect appearance active');
       togglePauseBox(true);ck(!box.classList.contains('padlost')&&!b.disabled,'regular pause inherited disconnect style');togglePauseBox(false);
       return bad.length?bad.join('; '):null;
     }finally{
       if(typeof padLostUi==='function')padLostUi(false,false);
       try{__endRaid('abandon');}catch(e){}__topClear();box.classList.remove('padlost');
       Object.keys(PAD).forEach(function(k){delete PAD[k];});Object.assign(PAD,pk);
       b.textContent=text;b.disabled=disabled;b.classList.toggle('padfocus',focus);if(toast)toast.style.cssText=toastStyle;
     }
   }},
  {v:'32.78',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
