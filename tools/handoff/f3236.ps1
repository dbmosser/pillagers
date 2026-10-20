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

if ($s.Contains("  {v:'32.36',what:")) { throw "check 32.36 is in the fixture already" }

SubRx @'
  {v:'32.35',what:
'@ @'
  {v:'32.36',what:'the extract inbound countdown stands on a plate measured to its words (critic 37)',
   run:function(){
     if(typeof extBanPlate!=='function') return 'the extract banner has no plate function (extBanPlate)';
     var s='EXTRACT B INBOUND  15s', r, f=ctx.font;
     ctx.save(); ctx.font=extBanFont(15);
     try{ r=extBanPlate(s,960,900,1); }finally{ ctx.restore(); ctx.font=f; }
     if(!r||!(r.w>0)) return 'extBanPlate gave no rectangle';
     if(r.x>960-hudRawW(s)/2||r.x+r.w<960+hudRawW(s)/2) return 'the plate does not cover the words';
     if(String(drawHUD).indexOf('extBanPlate(')<0) return 'drawHUD does not draw the plate';
     return null;
   }},
  {v:'32.35',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
