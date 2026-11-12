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

# KEYBOARD CHIP CLEARS THE RAID SCORE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  // v32.xx (cw-bagpadcards): in the Undercroft the chip sits top centre, clear of the location title at the top left.
  try{ var _kh=(typeof state!=='undefined'&&state==='hub'); e.style.left=_kh?'50%':'10px'; e.style.transform=_kh?'translateX(-50%)':'none'; }catch(_kp){}
'@ @'
  // v28.xx (cw-cx-kbscoreclear): his 3.5 c keyboard marker stays; in a raid it follows the score rail scale and sits below its drawn box.
  try{
    var _kh=(typeof state!=='undefined'&&state==='hub'), _kr=(typeof G!=='undefined'&&G&&!G.over&&!G.hubFloor&&state==='raid');
    e.style.left=_kh?'50%':'10px'; e.style.top='6px'; e.style.transform=_kh?'translateX(-50%)':'none';
    e.style.fontSize='16px'; e.style.padding='4px 8px'; e.style.letterSpacing='1px'; e.style.borderWidth='1px'; e.style.borderRadius='4px';
    if(_kr){
      var _kz=railZ(), _kc=hcv.getBoundingClientRect(), _kx=_kc.width/W, _ky=_kc.height/H;
      var _kb=(SCOREBOX.g===G&&SCOREBOX.w>0)?SCOREBOX:null, _kl=_kb?_kb.x:Math.round(24*_kz);
      var _kt=Math.max(_kb?_kb.y+_kb.h:railH(),RAIL.g===G?RAIL.b:0)+8*_kz;
      e.style.left=(_kc.left+_kl*_kx)+'px'; e.style.top=(_kc.top+_kt*_ky)+'px';
      e.style.fontSize=(msgPx(railF(TYPE.title,1.23))*0.8*_ky)+'px';
      e.style.padding=(4*_kz*_ky)+'px '+(8*_kz*_kx)+'px'; e.style.letterSpacing=(_kz*_kx)+'px';
      e.style.borderWidth=(Math.max(1,_kz*_ky))+'px'; e.style.borderRadius=(4*_kz*_ky)+'px';
    }
  }catch(_kp){}
'@

SubRx @'
var VER='37.72';
'@ @'
var VER='37.73';
'@

$pat = "(?m)^  now:'v37\.72:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.73: The raid keyboard chip sits below the drawn score, aligned at its left edge, with text at 80 percent of the score size and padding that follows the rail scale. The Undercroft keeps its top-centre chip. Check 37.73 fails on v37.72',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
