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

if ($s.Contains("  {v:'30.04',what:")) { throw "check 30.04 is in the fixture already" }

SubRx @'
  {v:'30.03',what:
'@ @'
  {v:'30.04',what:'starting the arcade closes any window still open on the title: the welcome pack of a fresh profile stayed open under the party attract and showed through the backdrop (screens 46 64)',
   run:function(){
     if(typeof arcadeEnter!=='function'||typeof arcadeLeave!=='function'||typeof ARCADE!=='object'||!ARCADE) return 'SKIP: no arcade here';
     var m=document.getElementById('welcomemodal'), res=null, o;
     if(!m) return 'SKIP: no welcome window';
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       m.classList.add('on');
       if(!arcadeEnter('host')||!ARCADE.on) return 'SKIP: arcadeEnter did not turn the arcade on';
       o=document.querySelector('.modal.on');
       if(o) res='a window is still open over the party attract: '+o.id;
       return res;
     } finally {
       try{ if(ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ m.classList.remove('on'); __topClear(); __cleanProfile(); }catch(_c){}
     }
   }},
  {v:'30.03',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
