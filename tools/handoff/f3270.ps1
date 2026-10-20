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

if ($s.Contains("  {v:'32.70',what:")) { throw "check 32.70 is in the fixture already" }

SubRx @'
  {v:'32.69',what:
'@ @'
  {v:'32.70',what:'large sixteen-letter pad name dialog, one Menu done action, named stash without floor HUD or orphan belt caption (J4 critic)',
   run:function(){
     var pin=document.getElementById('pnamein'),iv=pin.value,it=pin.__typed,top=document.getElementById('title'),tc=top.className,pk=Object.assign({},PAD),ik=Object.assign({},INDEV),f=ctx.fillText,bad=[],seq=[];
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();__wnseen(1);
       top.classList.add('on');PAD.on=true;INDEV.dev='pad';INDEV.legacy=false;pin.value='milo';
       if(!padNameStart(pin))return 'pad name card did not open';
       var card=PADNAME.card,cells=card.querySelectorAll('.pnl>span'),hint=card.querySelector('.pnhint'),done=card.querySelector('.pndone');
       if(cells.length!==16||parseFloat(getComputedStyle(cells[0]).fontSize)<55||+getComputedStyle(cells[0]).fontWeight<800)bad.push('name is not sixteen readable hero-size letters');
       if(hint.querySelector('svg[aria-label="menu"]')||!done.querySelector('svg[aria-label="menu"]'))bad.push('Menu done is duplicated or missing from its action');
       var a=cells[0].getBoundingClientRect(),z=cells[15].getBoundingClientRect(),box=card.querySelector('.pnbox').getBoundingClientRect();
       if(a.left<box.left||z.right>box.right)bad.push('sixteen letters do not fit the card');
       padNameOp('up');padNameOp('next');padNameOp('back');padNameOp('done');if(pin.value!=='nilo')bad.push('pad editing no longer keeps the typed name');
       __hubEnter();P.pname='nilo';__station('term','KeyE');renderHub();
       if(document.getElementById('stashname').textContent!=='nilo')bad.push('stash lost the entered name');
       ctx.fillText=function(s){seq.push(String(s).toLowerCase());return f.apply(this,arguments);};drawHubHUD(0,0);ctx.fillText=f;
       if(seq.some(function(s){return s==='the undercroft'||/items? in stash/.test(s);}))bad.push('floor title or counters leak behind the stash');
       var row=document.querySelector('#hotplanwrap>div>div>div'),caption=row&&row.lastElementChild,slots=document.querySelectorAll('#hotplanwrap [data-plan]');
       if(slots.length!==9)bad.push('belt no longer has nine slots');
       if(!caption||getComputedStyle(caption).display!=='none')bad.push('orphan belt caption remains visible');
       if(slots.length===9){var first=slots[0].getBoundingClientRect(),last=slots[8].getBoundingClientRect(),r=row.getBoundingClientRect();if(Math.abs(first.left-r.left)>2||Math.abs(last.right-r.right)>2)bad.push('belt slots do not span the pane');}
       if(document.querySelector('#hubfreekit .fkbtn').textContent!=='take')bad.push('freebie action repeats its kit label');
       if(parseFloat(getComputedStyle(document.getElementById('hub')).paddingBottom)>24.1)bad.push('empty old floor-action footer remains');
       return bad.length?bad.join('; '):null;
     }finally{
       ctx.fillText=f;if(PADNAME)padNameClose(false);try{__endRaid('abandon');}catch(e){}__topClear();document.getElementById('hub').classList.remove('on');pin.value=iv;pin.__typed=it;top.className=tc;
       Object.keys(PAD).forEach(function(k){delete PAD[k];});Object.assign(PAD,pk);Object.keys(INDEV).forEach(function(k){delete INDEV[k];});Object.assign(INDEV,ik);
     }
   }},
  {v:'32.69',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
