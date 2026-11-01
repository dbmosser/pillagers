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

if ($s.Contains("  {v:'37.08',what:")) { throw "check 37.08 is in the fixture already" }

SubRx @'
  {v:'37.07',what:
'@ @'
  {v:'37.08',what:'the gun jam branches are out of the fire code and the jam cleared line is gone (cw-dead5): guns never jam',
   run:function(){
     var s=[].slice.call(document.scripts).map(function(x){ return x.text||''; }).join('\n'), bad=[];
     if(s.indexOf('JAM '+'CLEARED')>=0) bad.push('the jam cleared line is still there');
     if(s.indexOf('p.wep.jam>0&&'+'rr()<p.wep.jam')>=0) bad.push('the player jam roll is still there');
     if(s.indexOf('var jr=(p.wep.jam'+'>0)')>=0) bad.push('the bot jam roll is still there');
     return bad.length?bad.join('; '):null; }},
  {v:'37.07',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
