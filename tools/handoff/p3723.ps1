$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
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

# SEASON ZERO M1: THE RANK STRIP READS FROM THE COUCH (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  lab='font-size:13px;letter-spacing:.14em;color:var(--ash);line-height:18px';
  el.innerHTML=
    '<div style="flex:none;min-width:190px"><div style="'+lab+'">rank</div><div id="rankname" style="font-size:26px;line-height:32px;font-weight:700;letter-spacing:.04em;color:var(--amber)">'+R.n+'</div></div>'+
    '<div style="flex:none;min-width:190px"><div style="'+lab+'">lifetime earnings</div><div id="rankearn" style="font-size:26px;line-height:32px;font-weight:700;color:var(--bone)">$'+le.toLocaleString()+'</div></div>'+
    '<div style="flex:1;min-width:0">'+
      '<div style="display:flex;justify-content:space-between;gap:12px;'+lab+'"><span id="ranknext">'+(N?('next  '+N.n+'  $'+N.need.toLocaleString()):'top rank')+'</span>'+
      (N?('<span>reward  <b id="rankrw" style="color:var(--amber);font-weight:600">'+rankRwTxt(N.rw)+'</b></span>'):'')+'</div>'+
      '<div style="height:10px;margin-top:8px;border:1px solid var(--steel-hi);border-radius:2px;background:rgba(0,0,0,.35)"><div id="rankfill" style="height:100%;width:'+(f*100).toFixed(1)+'%;background:var(--amber)"></div></div>'+
    '</div>';
'@ @'
  // v37.xx (cw-m1rankui), critic on the Mainframe and stats screens (P1): labels were 13px under the 16px floor and lime showed three times. Labels 16px,
  // values 30px in white, the next rank and reward in white; lime is the bar fill only (8px on the line colour).
  lab='font-size:16px;letter-spacing:.04em;color:var(--ash);line-height:20px';
  el.innerHTML=
    '<div style="flex:none;min-width:190px"><div style="'+lab+'">rank</div><div id="rankname" style="font-size:30px;line-height:36px;font-weight:700;letter-spacing:.02em;color:var(--bone)">'+R.n+'</div></div>'+
    '<div style="flex:none;min-width:190px"><div style="'+lab+'">lifetime earnings</div><div id="rankearn" style="font-size:30px;line-height:36px;font-weight:700;color:var(--bone)">$'+le.toLocaleString()+'</div></div>'+
    '<div style="flex:1;min-width:0">'+
      '<div style="display:flex;justify-content:space-between;gap:12px;'+lab+'"><span>next  <b id="ranknext" style="color:var(--bone);font-weight:600">'+(N?(N.n+'  $'+N.need.toLocaleString()):'top rank')+'</b></span>'+
      (N?('<span>reward  <b id="rankrw" style="color:var(--bone);font-weight:600">'+rankRwTxt(N.rw)+'</b></span>'):'')+'</div>'+
      '<div style="height:8px;margin-top:10px;border:1px solid var(--ui-line-hi);border-radius:2px;background:rgba(0,0,0,.35)"><div id="rankfill" style="height:100%;width:'+(f*100).toFixed(1)+'%;background:var(--amber)"></div></div>'+
    '</div>';
'@

SubRx @'
var VER='37.22';
'@ @'
var VER='37.23';
'@

$pat = "(?m)^  now:'v37\.22:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.23: strip labels 13 to 16px, rank name and lifetime earnings 26 to 30px in white, next rank and reward in white, lime on the bar fill only, bar 10 to 8px on the line colour Check 37.23 fails on v37.22',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
