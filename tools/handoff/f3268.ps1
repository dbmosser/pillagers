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

if ($s.Contains("  {v:'32.68',what:")) { throw "check 32.68 is in the fixture already" }

SubRx @'
  {v:'32.67',what:
'@ @'
  {v:'32.68',what:'career letter picker readable hints, boxed letter and arrows, single footer and isolated title focus (J4 critic)',
   run:function(){
     var pin=document.getElementById('pnamein'),top=document.getElementById('title'),root=document.getElementById('root'),tc=top.className,iv=pin.value,pk=Object.assign({},PAD),ik=Object.assign({},INDEV),bad=[];
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       if(PADNAME)padNameClose(false);top.classList.add('on');PAD.on=true;INDEV.dev='pad';INDEV.legacy=false;pin.value='pillager';padSetFocus(pin);
       if(!padNameStart(pin))return 'career name picker did not open';
       var card=PADNAME.card,hint=card.querySelector('.pnhint'),cur=card.querySelector('.pnl .cur'),hs=getComputedStyle(hint),cs=getComputedStyle(cur),ps=getComputedStyle(card.querySelector('.pnl'));
       if(parseFloat(hs.fontSize)<16)bad.push('pad controls below 16px');
       if(!hint.querySelector('.pad-a')||!hint.querySelector('.pad-b')||!hint.querySelector('svg[aria-label="menu"]'))bad.push('pad button pictures missing');
       if(!card.querySelector('footer .pnhint'))bad.push('controls are outside the footer');
       // v28.xx (cw-cx-padnameview): Chrome snaps borders to pixels under menu zoom; compare the real letter with the required border at the same zoom.
       var borderProbe=document.createElement('i');borderProbe.style.cssText='position:absolute;visibility:hidden;pointer-events:none;border:2px solid var(--acc);border-bottom-width:3px';card.appendChild(borderProbe);
       var bs=getComputedStyle(borderProbe),wantTop=parseFloat(bs.borderTopWidth),wantBottom=parseFloat(bs.borderBottomWidth),wantColor=bs.borderTopColor;
       if(Math.abs(parseFloat(cs.borderTopWidth)-wantTop)>0.01||Math.abs(parseFloat(cs.borderBottomWidth)-wantBottom)>0.01||cs.borderTopStyle!=='solid'||cs.borderTopColor!==wantColor||cs.borderBottomColor!==wantColor)bad.push('active letter lacks its boxed focus: '+cs.borderTopWidth+'/'+cs.borderBottomWidth+' expected '+wantTop+'/'+wantBottom+'; '+cs.borderTopColor+' expected '+wantColor);
       borderProbe.remove();
       if(parseFloat(ps.columnGap)<8)bad.push('letter spacing below 8px');
       var up=getComputedStyle(cur,':before').content,down=getComputedStyle(cur,':after').content;
       if(!up||up==='none'||!down||down==='none')bad.push('active letter lacks up and down arrows');
       if(getComputedStyle(top).visibility!=='hidden')bad.push('underlying title and its input focus remain visible');
       var hb=hint.getBoundingClientRect(),db=card.querySelector('.pndone').getBoundingClientRect();
       if(hb.right>db.left-12)bad.push('controls overlap the done button');
       padNameOp('up');padNameOp('next');padNameOp('back');padNameOp('done');
       if(pin.value!=='qillager')bad.push('presentation change lost the typed name');
       if(root.classList.contains('padnaming')||getComputedStyle(top).visibility==='hidden')bad.push('title focus not restored after done');
       padNameStart(pin);padNameClose(false);if(root.classList.contains('padnaming'))bad.push('cancel left the title hidden');
       return bad.length?bad.join('; '):null;
     }finally{
       if(PADNAME)padNameClose(false);root.classList.remove('padnaming');pin.value=iv;top.className=tc;
       try{__endRaid('abandon');}catch(e){}__topClear();
       Object.keys(PAD).forEach(function(k){delete PAD[k];});Object.assign(PAD,pk);Object.keys(INDEV).forEach(function(k){delete INDEV[k];});Object.assign(INDEV,ik);
     }
   }},
  {v:'32.67',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
