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

if ($s.Contains("  {v:'29.91',what:")) { throw "check 29.91 is in the fixture already" }

SubRx @'
  {v:'29.90',what:
'@ @'
  {v:'29.91',what:'the operator card has a close X that closes it and a key strip, and the player 2 line is one short label (critic 58 62 63)',
   run:function(){
     if(typeof arcadeOpOpen!=='function'||typeof arcadeOpClose!=='function'||typeof ARCADE!=='object'||!ARCADE) return 'SKIP: no operator card';
     var was=ARCADE.on, x, h, el, r, c;
     try{
       ARCADE.on=true;
       if(!arcadeOpOpen()) return 'the operator card did not open';
       el=document.getElementById('arcop'); if(!el) return 'no operator card element';
       x=el.querySelector('.arcopx'); if(!x) return 'the operator card has no close X';
       h=el.querySelector('.arcophint'); if(!h) return 'the operator card has no key strip';
       if(!/Esc/.test(h.textContent)||!/Enter/.test(h.textContent)) return 'the key strip lacks Enter and Esc';
       r=x.getBoundingClientRect(); c=el.getBoundingClientRect();
       if(r.right>c.right+1||r.top<c.top-1||r.width<30) return 'the X is not top right and large enough: '+Math.round(r.width)+'px';
       x.click();
       if(document.getElementById('arcop')) return 'the X did not close the card';
       if(/Drag it to your second screen/.test(String(netTitleInit))) return 'the player 2 line is still the long paragraph';
     }finally{ try{ arcadeOpClose(); }catch(e){} ARCADE.on=was; }
     return null; }},
  {v:'29.90',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
