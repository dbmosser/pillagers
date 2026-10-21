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

if ($s.Contains("  {v:'33.37',what:")) { throw "check 33.37 is in the fixture already" }

SubRx @'
  {v:'33.36',what:
'@ @'
  {v:'33.37',what:'cw-expchip: on the experimental page an on chip is lime and an off chip is dim (different computed colours), and the focused row carries exactly one focus mark (the row bar, no chevrons or frame)',
   run:function(){
     var bad=[], modal=document.getElementById('settingsmodal'), list=document.getElementById('setlist'), oldCls, oldSub=SETSUB, rows, r0, r1, cOn, cOff, b, n=0, rs, bs, ps;
     if(!modal||!list||typeof renderSettings!=='function') return 'SKIP: no settings page';
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       oldCls=modal.className; modal.classList.add('on'); SETSUB='exp'; renderSettings();
       rows=list.querySelectorAll('.exprow'); if(rows.length<2) return 'expected experimental rows, found '+rows.length;
       r0=rows[0]; r1=rows[1]; r1.classList.add('expoff');
       cOn=getComputedStyle(r0.querySelector('.expvalue')); cOff=getComputedStyle(r1.querySelector('.expvalue'));
       var m=/rgba?\((\d+), *(\d+), *(\d+)/.exec(cOn.backgroundColor);
       if(!m||!(+m[2]>=+m[1]&&+m[2]>+m[3]+100)) bad.push('the on chip is not lime ('+cOn.backgroundColor+')');
       if(cOn.backgroundColor===cOff.backgroundColor||cOn.color===cOff.color) bad.push('on and off chips share a colour');
       r0.classList.add('dshow'); b=r0.querySelector('button'); b.classList.add('padfocus');
       rs=getComputedStyle(r0); if(rs.boxShadow&&rs.boxShadow!=='none') n++; else bad.push('focused row has no row bar');
       ['::before','::after'].forEach(function(p){ ps=getComputedStyle(b,p); if(ps.display!=='none'&&ps.visibility!=='hidden'&&ps.content!=='none'&&ps.content!=='normal') bad.push('a chevron '+p+' is drawn on the focused row'); });
       bs=getComputedStyle(b);
       if(bs.outlineStyle!=='none'&&parseFloat(bs.outlineWidth)>0) bad.push('the focused button has an outline');
       if(parseFloat(bs.borderTopWidth)>0&&bs.borderTopStyle!=='none') bad.push('the focused button has a frame');
       if(bs.boxShadow&&bs.boxShadow!=='none') bad.push('the focused button has a shadow mark');
       return bad.length?bad.join('; '):null;
     } finally { SETSUB=oldSub; try{ renderSettings(); }catch(_e){} modal.className=oldCls; }
   }},
  {v:'33.36',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
