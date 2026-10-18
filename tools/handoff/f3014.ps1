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

if ($s.Contains("  {v:'30.14',what:")) { throw "check 30.14 is in the fixture already" }

SubRx @'
  {v:'30.13',what:
'@ @'
  {v:'30.14',what:'the operator card has two rows (New party, Exit demo): Back is gone and the X and Esc close it, and the focused row is a raised fill with a 3px accent bar, not an accent slab (critic on 62 and 63: 3 and 2 of 5)',
   run:function(){
     if(typeof arcadeOpOpen!=='function'||typeof arcadeOpClose!=='function'||typeof ARCADE!=='object'||!ARCADE) return 'SKIP: no operator card';
     var was=ARCADE.on, op, bs, cs, res=null, p, acc;
     try{
       ARCADE.on=true;
       if(!arcadeOpOpen()) return 'the operator card did not open';
       op=document.getElementById('arcop'); if(!op) return 'no operator card element';
       bs=op.querySelectorAll('button[data-op]');
       if(op.querySelector('[data-op="back"]')) res='the Back row is still on the operator card';
       else if(bs.length!==2) res=bs.length+' rows, not 2 (New party, Exit demo)';
       if(res) return res;
       p=document.createElement('i'); p.style.color='var(--acc)'; document.body.appendChild(p); acc=getComputedStyle(p).color; p.remove();
       cs=getComputedStyle(bs[0]);
       if(cs.backgroundColor===acc) res='the focused row is an accent slab: '+cs.backgroundColor;
       else if(parseFloat(cs.borderLeftWidth)<parseFloat(cs.borderTopWidth)*1.8||cs.borderLeftColor!==acc) res='the focused row has no 3px accent bar: '+cs.borderLeftWidth+' '+cs.borderLeftColor;
       return res;
     } finally { try{ arcadeOpClose(); }catch(e){} ARCADE.on=was; }
   }},
  {v:'30.13',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
