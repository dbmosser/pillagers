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

if ($s.Contains("  {v:'19.86',what:")) { throw "check 19.86 is in the fixture already" }

SubRx @'
  {v:'19.85',what:
'@ @'
  {v:'19.86',what:'a PlayStation pad is told its own buttons: with a DualSense on, the pause box key line and the stash pad row say SQUARE and CROSS, not X and A',
   run:function(){
     if(typeof pollPad!=='function'||typeof keysLegendHtml!=='function'||typeof padB!=='function') return 'SKIP: no pad legend here';
     var bad=[], had=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'), og=navigator.getGamepads, on0=PAD.on, b0=PAD.brand, pad, h, row;
     pad={id:'DualSense Wireless Controller (STANDARD GAMEPAD Vendor: 054c Product: 0ce6)',index:0,connected:true,mapping:'standard',timestamp:1,axes:[0,0,0,0],buttons:Array.apply(null,Array(17)).map(function(){ return {pressed:false,touched:false,value:0}; })};
     try{
       navigator.getGamepads=function(){ pad.timestamp++; return [pad,null,null,null]; };
       pollPad(); pollPad();
       if(PAD.brand!=='ps') return 'SKIP: the pad was not read as a PlayStation pad';
       h=String(keysLegendHtml());
       if(h.indexOf('>X</b>')>=0||h.indexOf('>A</b>')>=0) bad.push('the pause key line still names X and A');
       if(h.indexOf('SQUARE')<0) bad.push('the pause key line does not name SQUARE');
       row=document.getElementById('invkeybarpad');
       if(row&&(row.textContent.indexOf('CROSS')<0||/(^|\s)A(\s|$)/.test(row.textContent))) bad.push('the stash pad row still names A ('+row.textContent.replace(/\s+/g,' ').trim().slice(0,60)+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ navigator.getGamepads=function(){ return [null,null,null,null]; }; try{ pollPad(); }catch(_p){} if(had) navigator.getGamepads=og; else delete navigator.getGamepads; PAD.on=on0; PAD.brand=b0; try{ if(typeof padBodyCls==='function') padBodyCls(); }catch(_b){} }
     return bad.length?bad.join('; '):null; }},
  {v:'19.85',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
