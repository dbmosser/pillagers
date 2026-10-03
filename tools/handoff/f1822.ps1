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

if ($s.Contains("  {v:'18.22',what:")) { throw "check 18.22 is in the fixture already" }

SubRx @'
  {v:'18.21',what:
'@ @'
  {v:'18.22',what:'T with the backpack open is the trade key and nothing else: on an empty cell it does not start patching a teammate, with the Peddler stall open it does nothing, and with the backpack closed and no offer waiting it still patches up as before',
   run:function(){
     if(typeof netAidHold!=='function'||typeof netGiftKey!=='function') return 'SKIP: no aid or trade here';
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     var bad=[], oAid=netAidHold, n=0, g, keep={on:NET.on,roster:NET.roster}, K=window.KeyboardEvent;
     function press(){ keys={}; document.body.dispatchEvent(new K('keydown',{code:'KeyT',key:'t',bubbles:true,cancelable:true})); document.body.dispatchEvent(new K('keyup',{code:'KeyT',key:'t',bubbles:true,cancelable:true})); }
     try{
       netAidHold=function(){ n++; return false; };
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); NET.on=true; NET.roster=[{seat:0,name:'HOST'},{seat:1,name:'KID'}]; g.giftIn=null; g.giftOut=null; g.paused=false;
       g.bag.length=0; g.bagOpen=true; g.bagSel=0;
       n=0; press(); if(n) bad.push('T on an empty backpack cell started patching a teammate');
       g.bagOpen=false; g.trade={stock:[],x:0,y:0};
       n=0; press(); if(n) bad.push('T with the Peddler stall open started patching a teammate');
       g.trade=null;
       n=0; press(); if(!n) bad.push('control: T with the backpack closed and nothing waiting no longer patches up');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ netAidHold=oAid; NET.on=keep.on; NET.roster=keep.roster; keys={}; try{ var g2=__state(); if(g2){ g2.trade=null; g2.bagOpen=false; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.21',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
