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

if ($s.Contains("  {v:'19.39',what:")) { throw "check 19.39 is in the fixture already" }

SubRx @'
  {v:'19.38',what:
'@ @'
  {v:'19.39',what:'a lifetime loss reads with the minus first: with net earnings of minus 9750 the YOUR STATS card says -$9,750, never $-9,750',
   run:function(){
     if(!window.__station||!window.__hubEnter) return 'SKIP: this fixture cannot open the Mainframe';
     var bad=[], t, tab, sg, n0=P.netEarn, txt;
     try{
       __topClear(); __runPrep(); __cleanProfile();
       P.netEarn=-9750;
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       __hubEnter(); __station('mf','KeyE');
       tab=document.querySelector('[data-optab="rec"]'); if(!tab) return 'SKIP: no YOUR STATS tab';
       tab.click();
       sg=document.getElementById('statgrid'); if(!sg) return 'SKIP: no stat grid';
       txt=String(sg.textContent||'');
       if(txt.indexOf('$-')>=0) bad.push('the card reads $- before the number');
       if(txt.indexOf('-$9,750')<0) bad.push('the card does not read -$9,750');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ if(n0===undefined) delete P.netEarn; else P.netEarn=n0; try{ saveProfile(); }catch(_s){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.38',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
