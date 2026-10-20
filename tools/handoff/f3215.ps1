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

if ($s.Contains("  {v:'32.15',what:")) { throw "check 32.15 is in the fixture already" }

SubRx @'
  {v:'32.14',what:
'@ @'
  {v:'32.15',what:'a new demo run puts the easy or normal card up for that player, and starts on normal (his 2.28 c)',
   run:function(){
     if(typeof easyStartAsk!=='function') return 'no easyStartAsk';
     if(String(arcadeDeploy).indexOf('easyStartAsk')<0) return 'arcadeDeploy does not ask';
     var on0=ARCADE.on, so0=ARCADE.solo, e0=ARCADE.easy, a0=ARCADE.easyAsk, k0=ARCADE.easyAsked, r;
     try{
       ARCADE.on=1; ARCADE.solo=0; ARCADE.easy=1; ARCADE.easyAsk=null; ARCADE.easyAsked=1;
       r=easyStartAsk();
       if(!r||!ARCADE.easyAsk) return 'no card after a new run';
       if(ARCADE.easy) return 'the new run did not start on normal';
       ARCADE.on=0; ARCADE.easyAsk=null;
       if(easyStartAsk()||ARCADE.easyAsk) return 'card shown outside the demo';
       return null;
     } finally { ARCADE.on=on0; ARCADE.solo=so0; ARCADE.easy=e0; ARCADE.easyAsk=a0; ARCADE.easyAsked=k0; } }},
  {v:'32.14',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
