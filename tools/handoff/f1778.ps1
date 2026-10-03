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

if ($s.Contains("  {v:'17.78',what:")) { throw "check 17.78 is in the fixture already" }

SubRx @'
  {v:'17.77',what:
'@ @'
  {v:'17.78',what:'a PlayStation pad is named in its own words: the pad id picks the make, keyLabel says SQUARE for the X prompt, the backpack line says CROSS pick up, CIRCLE close, and the short pad legend names his layout (A roll, RT fire)',
   run:function(){
     if(typeof padB!=='function'||typeof padBrandOf!=='function') return 'every prompt names Xbox buttons whatever pad is plugged in';
     var bad=[], b0=PAD.brand, on0=PAD.on, st0=state, s;
     try{
       if(padBrandOf({id:'Wireless Controller (STANDARD GAMEPAD Vendor: 054c Product: 09cc)'})!=='ps') bad.push('a DualShock id was not read as PlayStation');
       if(padBrandOf({id:'Xbox 360 Controller (XInput STANDARD GAMEPAD)'})!=='xbox') bad.push('an Xbox id was not read as Xbox');
       PAD.brand='ps'; PAD.on=true; state='raid';
       s=keyLabel('KeyE','E'); if(s!=='SQUARE') bad.push('on a PlayStation pad the X prompt reads '+s);
       s=padB('A pick up or place   B close'); if(s!=='CROSS pick up or place   CIRCLE close') bad.push('the backpack line reads '+s);
       s=padB('VIEW  BACKPACK'); if(s!=='SHARE  BACKPACK') bad.push('VIEW BACKPACK reads '+s);
       s=padB('LT / RS'); if(s!=='L2 / R3') bad.push('LT / RS reads '+s);
       PAD.brand='xbox'; if(keyLabel('KeyE','E')!=='X') bad.push('on an Xbox pad the X prompt reads '+keyLabel('KeyE','E'));
       if(!LEGEND_MINI_PAD.some(function(r){ return r[0]==='A'&&r[1]==='roll'; })||!LEGEND_MINI_PAD.some(function(r){ return r[0]==='RT'&&/fire/.test(r[1]); })) bad.push('the short pad legend does not name his layout (A roll, RT fire)');
       if(LEGEND_MINI_PAD.some(function(r){ return r[0]==='B'&&r[1]==='roll'; })) bad.push('the short pad legend still says B roll');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ PAD.brand=b0; PAD.on=on0; state=st0; }
     return bad.length?bad.join('; '):null; }},
  {v:'17.77',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
