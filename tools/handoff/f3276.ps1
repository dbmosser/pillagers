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

if ($s.Contains("  {v:'32.76',what:")) { throw "check 32.76 is in the fixture already" }

SubRx @'
  {v:'32.75',what:
'@ @'
  {v:'32.76',what:'J8 disconnect action says reconnect and cannot resume an absent pad; returning pad enables resume and A restores the normal action',
   run:function(){
     var bad=[], pk=Object.assign({},PAD), b=document.getElementById('resumebtn'), text=b.textContent, disabled=b.disabled;
     function ck(ok,s){if(!ok)bad.push(s);}
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       __deploy({kit:['gun_rifle'],safe:null,mapIx:0,seed:4242});__topClear();
       if(pauseOpen)togglePauseBox(false);
       padLostStart(0);
       var normal=PAD.lossUi&&PAD.lossUi.text;
       ck(pauseOpen&&G.paused&&b.disabled&&b.textContent==='reconnect','lost pad still offers resume');
       b.onclick();ck(pauseOpen&&G.paused&&!!PAD.lost,'absent pad resumed by click');
       var gp={connected:true,index:0,id:'J8 action',axes:[0,0,0,0],buttons:[{pressed:false,value:0}]};
       padLostPoll(gp);
       ck(pauseOpen&&!b.disabled&&b.textContent==='resume'&&document.querySelector('#pausebox h3').textContent==='press a','return did not enable the action');
       gp.buttons[0]={pressed:true,value:1};padLostPoll(gp);
       ck(!pauseOpen&&!G.paused&&!PAD.lost&&!b.disabled&&b.textContent===normal,'A did not restore the normal action');
       gp.buttons[0]={pressed:false,value:0};padLostStart(0);padLostPoll(gp);b.onclick();
       ck(!pauseOpen&&!G.paused&&!PAD.lost&&!b.disabled,'returned pad resume click did not close cleanly');
       return bad.length?bad.join('; '):null;
     }finally{
       if(typeof padLostUi==='function')padLostUi(false,false);
       try{__endRaid('abandon');}catch(e){}__topClear();
       Object.keys(PAD).forEach(function(k){delete PAD[k];});Object.assign(PAD,pk);
       b.textContent=text;b.disabled=disabled;
     }
   }},
  {v:'32.75',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
