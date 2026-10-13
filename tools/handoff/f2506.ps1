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

if ($s.Contains("  {v:'25.06',what:")) { throw "check 25.06 is in the fixture already" }

SubRx @'
  {v:'25.05',what:
'@ @'
  {v:'25.06',what:'his #35/#50 (UI redesign ui5q2p): the raid HUD panels draw a chevron for their fold toggle, not the text [-] or [+]',
   run:function(){
     if(typeof hudChev!=='function') return 'the HUD has no chevron toggle';
     var src=[].slice.call(document.scripts).map(function(s){ return s.text||''; }).join(''), n=0, k=0;
     var nd="fillText(HO"+"c.c?'[+]'", nd2="fillText(HO"+"r.c?'[+]'", nd3="fillText('[-"+"]',mx";
     if(src.indexOf(nd)>=0||src.indexOf(nd2)>=0||src.indexOf(nd3)>=0) return 'a HUD panel still prints [-] as its toggle';
     var real=ctx.stroke;
     try{ ctx.stroke=function(){ n++; }; hudChev(200,200,true); hudChev(200,200,false); }
     finally{ delete ctx.stroke; if(ctx.stroke!==real) ctx.stroke=real; }
     return n===2?null:('the chevron drew '+n+' strokes for two calls'); }},
  {v:'25.05',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
