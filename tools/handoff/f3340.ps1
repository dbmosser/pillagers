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

if ($s.Contains("  {v:'33.40',what:")) { throw "check 33.40 is in the fixture already" }

SubRx @'
  {v:'33.39',what:
'@ @'
  {v:'33.40',what:'J3: B cancels the save-delete confirmation, retains the title and never erases a save, without keyboard events',
   run:function(){
     var ng=navigator.getGamepads,own=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'),pk=Object.assign({},PAD),ns=NET.same,ao=ARCADE.on,at=ATT.on;
     var title=document.getElementById('title'),dc=document.getElementById('delconfirm'),dn=document.getElementById('delno'),ds=dc.style.display,cls=title.className;
     var dg=document.getElementById('delgo'),keep=dn.onclick,erase=dg.onclick,calls=0,erases=0,events=0,pad={connected:true,index:0,id:'Xbox J3 back',mapping:'standard',axes:[0,0,0,0],buttons:[]},bad=[],i,modals=[];
     function keyboard(){events++;}
     function poll(b){for(var j=0;j<17;j++)pad.buttons[j]={pressed:j===b,value:j===b?1:0};pollPad();}
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       NET.same=null;ARCADE.on=false;ATT.on=false;
       [].forEach.call(document.querySelectorAll('.modal.on,.pausebox.on,#hub.on,#outcome.on'),function(e){modals.push(e);e.classList.remove('on');});
       title.classList.add('on');dc.style.display='block';
       dn.onclick=function(){calls++;return keep.apply(this,arguments);};
       dg.onclick=function(){erases++;return erase.apply(this,arguments);};
       navigator.getGamepads=function(){return [pad];};PAD.prev=[];PAD.prevMap=null;PAD.mSpent=[];PAD.held={};PAD.focus=null;PAD.announced=true;
       window.addEventListener('keydown',keyboard,true);window.addEventListener('keyup',keyboard,true);
       poll(-1);poll(1);poll(-1);
       if(calls!==1||dc.getBoundingClientRect().height>0)bad.push('B did not run KEEP exactly once');
       if(!title.classList.contains('on'))bad.push('B dismissed the title');
       if(erases)bad.push('B invoked erase');
       poll(1);poll(-1);if(calls!==1)bad.push('B on the plain title repeated KEEP');
       if(events)bad.push('pad emitted keyboard events');
       return bad.length?bad.join('; '):null;
     }finally{
       window.removeEventListener('keydown',keyboard,true);window.removeEventListener('keyup',keyboard,true);
       dn.onclick=keep;dg.onclick=erase;dc.style.display=ds;title.className=cls;modals.forEach(function(e){e.classList.add('on');});
       NET.same=ns;ARCADE.on=ao;ATT.on=at;
       if(own)navigator.getGamepads=ng;else delete navigator.getGamepads;
       Object.keys(PAD).forEach(function(k){delete PAD[k];});Object.assign(PAD,pk);
       try{__endRaid('abandon');}catch(_e){}__topClear();
     }
   }},
  {v:'33.39',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
