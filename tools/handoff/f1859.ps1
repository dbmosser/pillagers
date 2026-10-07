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

if ($s.Contains("  {v:'18.59',what:")) { throw "check 18.59 is in the fixture already" }

SubRx @'
  {v:'18.58',what:
'@ @'
  {v:'18.59',what:'prompts name the key you set: with interact moved to G, the keyboard prompt label and the Undercroft footer say G, and with no change they still say E',
   run:function(){
     if(typeof keyLabel!=='function'||typeof keysBind!=='function') return 'SKIP: no key binding here';
     var bad=[], km=(P&&P.keymap)?JSON.parse(JSON.stringify(P.keymap)):null, oSave=saveProfile, oPad=padOn, f0;
     try{
       saveProfile=function(){}; padOn=function(){ return false; };
       P.keymap={}; KEYS.inv=null;
       if(keyLabel('KeyE','E')!=='E') bad.push('control: with no change the prompt says '+keyLabel('KeyE','E'));
       if(typeof hubFootKeys==='function'){ f0=hubFootKeys('WASD WALK  x  SHIFT JOG  x  E USE STATION  x  E TAKE THE DROPPED ITEM'); if(f0!=='WASD WALK  x  SHIFT JOG  x  E USE STATION  x  E TAKE THE DROPPED ITEM') bad.push('control: the default footer changed to '+f0); }
       keysBind('KeyE','KeyG');
       if(keyLabel('KeyE','E')!=='G') bad.push('with interact on G the prompt still says '+keyLabel('KeyE','E'));
       if(typeof hubFootKeys!=='function') bad.push('the Undercroft footer has no way to name the keys as set');
       else { f0=hubFootKeys('WASD WALK  x  SHIFT JOG  x  E USE STATION  x  E TAKE THE DROPPED ITEM'); if(f0.indexOf('G USE STATION')<0||f0.indexOf('G TAKE THE DROPPED ITEM')<0) bad.push('with interact on G the footer says '+f0); }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ saveProfile=oSave; padOn=oPad; if(P){ if(km) P.keymap=km; else delete P.keymap; } KEYS.inv=null; try{ keysInv(); keysLegendApply(); }catch(_k){} }
     return bad.length?bad.join('; '):null; }},
  {v:'18.58',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
