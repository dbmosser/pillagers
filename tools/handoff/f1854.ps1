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

if ($s.Contains("  {v:'18.54',what:")) { throw "check 18.54 is in the fixture already" }

SubRx @'
  {v:'18.53',what:
'@ @'
  {v:'18.54',what:'every key that does something is on the keys list: binding reload onto G swaps it with the belt item, and the cursor and Superhot keys refuse a bind',
   run:function(){
     if(typeof keysBind!=='function'||typeof keyRemap!=='function'||typeof KEYS_ACTS==='undefined') return 'SKIP: no key binding here';
     var bad=[], km=(P&&P.keymap)?JSON.parse(JSON.stringify(P.keymap)):null, oSave=saveProfile;
     try{
       saveProfile=function(){};
       P.keymap={}; KEYS.inv=null;
       if(!keysBind('KeyR','KeyG')) bad.push('reload could not be put on G');
       if(keyRemap('KeyG')!=='KeyR') bad.push('control: G does not reload after the bind');
       if(keyRemap('KeyR')!=='KeyG') bad.push('binding reload onto G lost the belt item key (R still reloads)');
       P.keymap={}; KEYS.inv=null;
       if(keysBind('KeyE','Backquote')) bad.push('interact was put on the Superhot key');
       if(keysBind('KeyE','Backspace')) bad.push('interact was put on the cursor key');
       ['KeyG','KeyQ','KeyZ','KeyV','KeyO'].forEach(function(c){ if(!KEYS_ACTS.some(function(a){ return a[0]===c; })) bad.push(c.slice(3)+' is not on the keys list'); });
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ saveProfile=oSave; if(P){ if(km) P.keymap=km; else delete P.keymap; } KEYS.inv=null; try{ keysInv(); keysLegendApply(); }catch(_k){} }
     return bad.length?bad.join('; '):null; }},
  {v:'18.53',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
