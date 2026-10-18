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

if ($s.Contains("  {v:'30.13',what:")) { throw "check 30.13 is in the fixture already" }

SubRx @'
  {v:'30.12',what:
'@ @'
  {v:'30.13',what:'Settings ends in a key-hint line (Esc Close, or A Change and B Back on a pad) and its backdrop is 98 percent void',
   run:function(){
     var bad=[], m, c, bg, pm, padWas=document.body.classList.contains('padon');
     __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     try{
       document.body.classList.remove('padon');
       openSettings('display');
       m=document.getElementById('settingsmodal');
       if(!m) bad.push('no settings modal');
       else{
         c=getComputedStyle(m,'::after').content||'';
         if(c.indexOf('Esc')<0) bad.push('no Esc hint under Settings: '+c);
         bg=getComputedStyle(m).backgroundColor;
         pm=bg.match(/rgba?\(([^)]*)\)/);
         if(!pm) bad.push('backdrop colour unreadable: '+bg);
         else{ var p=pm[1].split(','); var al=p.length>3?parseFloat(p[3]):1; if(al<0.975) bad.push('the backdrop is '+al+' opaque'); }
         document.body.classList.add('padon');
         c=getComputedStyle(m,'::after').content||'';
         if(c.indexOf('B  Back')<0) bad.push('no B Back hint on a pad: '+c);
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var q=document.getElementById('settingsmodal'); if(q) q.classList.remove('on'); }catch(_k){} try{ __topClear(); }catch(_c){} document.body.classList.toggle('padon',padWas); }
     return bad.length?bad.join('; '):null; }},
  {v:'30.12',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
