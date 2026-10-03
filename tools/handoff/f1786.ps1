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

if ($s.Contains("  {v:'17.86',what:")) { throw "check 17.86 is in the fixture already" }

SubRx @'
  {v:'17.85',what:
'@ @'
  {v:'17.86',what:'the pause legend built from the key map says CTRL / C crouch toggle, as the written legend always did',
   run:function(){
     if(typeof keysLegendHtml!=='function') return 'SKIP: this build has no key map legend';
     var bad=[], km0=P.keymap, h;
     try{ P.keymap={}; KEYS.inv=null; keysInv(); h=keysLegendHtml().replace(/<[^>]*>/g,'').replace(/&nbsp;/g,' '); if(!/CTRL \/ C crouch toggle/.test(h)) bad.push('the legend reads '+JSON.stringify(h.slice(0,160))); }
     catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ P.keymap=km0||{}; KEYS.inv=null; keysInv(); try{ keysLegendApply(); }catch(_k){} }
     return bad.length?bad.join('; '):null; }},
  {v:'17.85',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
