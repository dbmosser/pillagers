$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# ---- A CHECK THAT CRASHES ON THE OLD BUILD IS NOT A CONTROL, IT IS A CRASH.
# ---- The first assertion guards for the missing shelf rule and then the control
# ---- below called it anyway, so on a v10.96 fixture this threw instead of
# ---- reporting the three items it was written to find.
SubRx @'
       var junkN=0, junkEg=null;
       for(k in ITEMS){
         if(wanted[k]||ITEMS[k].use) continue;
         if(stashTabOf(k)==='salvage'&&sellable(k)){ junkN++; if(!junkEg) junkEg=ITEMS[k].name; }
       }
       if(junkN<3) bad.push('control: only '+junkN+' items are still loose salvage, so the sell button has been turned off rather than taught');
'@ @'
       var junkN=0, junkEg=null;
       for(k in ITEMS){
         if(wanted[k]||ITEMS[k].use) continue;
         if(typeof stashTabOf==='function'&&stashTabOf(k)!=='salvage') continue;
         if(sellable(k)){ junkN++; if(!junkEg) junkEg=ITEMS[k].name; }
       }
       if(junkN<3) bad.push('control: only '+junkN+' items are still loose salvage, so the sell button has been turned off rather than taught');
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
