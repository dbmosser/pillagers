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

if ($s.Contains("  {v:'19.95',what:")) { throw "check 19.95 is in the fixture already" }

SubRx @'
  {v:'19.94',what:
'@ @'
  {v:'19.95',what:'the title speaks controller on a controller: with a pad on the title shows a pad key row (sticks, RT fire) instead of WASD and LMB, in PlayStation names on a PlayStation pad',
   run:function(){
     if(typeof pollPad!=='function') return 'SKIP: no controller poll here';
     var t=document.getElementById('title'), bad=[], had=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'), og=navigator.getGamepads, on0=PAD.on, b0=PAD.brand, pad, kb, pr, tOn;
     if(!t) return 'SKIP: no title screen';
     kb=t.querySelector('.kbrow')||[].slice.call(t.querySelectorAll('div')).filter(function(d){ return d.children.length>4&&/WASD/.test(d.textContent)&&/LMB/.test(d.textContent); })[0];
     if(!kb) return 'SKIP: no title key row';
     tOn=t.classList.contains('on');
     pad={id:'Xbox Wireless Controller (STANDARD GAMEPAD)',index:0,connected:true,mapping:'standard',timestamp:1,axes:[0,0,0,0],buttons:Array.apply(null,Array(17)).map(function(){ return {pressed:false,touched:false,value:0}; })};
     try{
       t.classList.add('on');
       navigator.getGamepads=function(){ pad.timestamp++; return [pad,null,null,null]; };
       pollPad(); pollPad();
       pr=t.querySelector('.padrow');
       if(getComputedStyle(kb).display!=='none') bad.push('with a pad on the title still shows the WASD row');
       if(!pr||getComputedStyle(pr).display==='none'||pr.textContent.indexOf('STICK')<0) bad.push('with a pad on the title shows no pad row');
       pad.id='DualSense Wireless Controller (STANDARD GAMEPAD Vendor: 054c Product: 0ce6)'; pollPad(); pollPad();
       if(pr&&PAD.brand==='ps'&&pr.textContent.indexOf('R2')<0) bad.push('on a PlayStation pad the title row does not say R2');
       navigator.getGamepads=function(){ return [null,null,null,null]; }; pollPad();
       if(getComputedStyle(kb).display==='none') bad.push('control: without a pad the WASD row is hidden');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ if(had) navigator.getGamepads=og; else delete navigator.getGamepads; try{ pollPad(); }catch(_p){} PAD.on=on0; PAD.brand=b0; try{ padBodyCls(); }catch(_b){} t.classList.toggle('on',tOn); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.94',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
