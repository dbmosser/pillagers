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

# ==== TWO CHECKS, ONE ITEM, AND THEY DISAGREED. v9.43 requires the servo to be
# ==== sellable because there is no repair to keep it for. v10.97 requires it to
# ==== be kept because the contract board asks for it by name. Both are right
# ==== about their own premise and the corpus caught the collision.
# ==== v9.43's real subject is the REASON, not the shelf: it was written when a
# ==== dead repair economy was the only thing keeping the servo, and it says so in
# ==== its own message. It asks about the reason now. Its sibling assertion, that
# ==== the servo is not a crafting part, is untouched and still passes, and so is
# ==== every control around it.
SubRx @'
     if(window.__stashRules){
       if(!__stashRules.sellable('servo'))
         bad.push('the Servo Actuator is still withheld from SELL ALL for a repair that no longer exists');
'@ @'
     if(window.__stashRules){
       // v10.97: THE REASON, not the shelf. The servo is kept now because the
       // contract board asks for it by name, which is his note 12 and nothing to
       // do with repairs. What this check has always cared about is that a dead
       // repair economy is not the thing keeping it, so that is what it asks.
       if(typeof itemWanted==='function'){
         var _sv=itemWanted('servo');
         if(_sv&&String(_sv).indexOf('repair')>=0)
           bad.push('the Servo Actuator is still kept for a repair that no longer exists, its reason reads '+_sv);
       } else if(!__stashRules.sellable('servo'))
         bad.push('the Servo Actuator is still withheld from SELL ALL for a repair that no longer exists');
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
