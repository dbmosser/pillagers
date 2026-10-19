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

if ($s.Contains("  {v:'31.82',what:")) { throw "check 31.82 is in the fixture already" }

SubRx @'
  {v:'31.81',what:
'@ @'
  {v:'31.82',what:'the operator card: the X is 40px, the focused lime New party row has no second ring, and the armed confirm reads in the body text colour with the lime focus bar (critic on 62 and 63: 3 of 5)',
   run:function(){
     if(typeof arcadeOpOpen!=='function'||typeof arcadeOpClose!=='function'||typeof arcadeOpPick!=='function'||typeof ARCADE!=='object'||!ARCADE) return 'SKIP: no operator card';
     var was=ARCADE.on, op, x, bs, res=null, p, tx, acc, cs;
     try{
       ARCADE.on=true;
       if(!arcadeOpOpen()) return 'the operator card did not open';
       op=document.getElementById('arcop'); if(!op) return 'no operator card element';
       x=op.querySelector('.arcopx'); if(!x) return 'no close X';
       if(Math.abs(parseFloat(getComputedStyle(x).width)-40)>1.5) res='the X is '+getComputedStyle(x).width+' wide, not 40';
       bs=op.querySelectorAll('button[data-op]');
       if(!res&&getComputedStyle(bs[0]).boxShadow!=='none') res='the focused New party row has a second ring: '+getComputedStyle(bs[0]).boxShadow;
       if(res) return res;
       arcadeOpPick(0);
       op=document.getElementById('arcop'); bs=op.querySelectorAll('button[data-op]');
       p=document.createElement('i'); p.style.color='var(--tx-1)'; document.body.appendChild(p); tx=getComputedStyle(p).color; p.style.color='var(--acc)'; acc=getComputedStyle(p).color; p.remove();
       cs=getComputedStyle(bs[0]);
       if(!/confirm/i.test(bs[0].textContent)) return 'the row did not arm: '+bs[0].textContent;
       if(cs.color!==tx) res='the armed confirm text is '+cs.color+', not the body text colour '+tx;
       else if(cs.borderLeftColor!==acc) res='the armed confirm has no lime focus bar: '+cs.borderLeftColor;
       return res;
     } finally { try{ arcadeOpClose(); }catch(e){} ARCADE.on=was; }
   }},
  {v:'31.81',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
