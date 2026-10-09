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

if ($s.Contains("  {v:'21.02',what:")) { throw "check 21.02 is in the fixture already" }

SubRx @'
  {v:'21.01',what:
'@ @'
  {v:'21.02',what:'a finished contract row is as tall as the rest: the progress line holding CLAIM is the same height as a progress line without it',
   run:function(){
     if(!(window.__hubEnter&&window.__station)||typeof renderHub!=='function') return 'SKIP: this fixture cannot open the Mainframe';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing renders';
     var bad=[], t, cs0=null, i, c, done=-1, open=-1, a, b, ha, hb;
     try{
       __topClear(); __runPrep(); __cleanProfile(); if(window.__wnseen) __wnseen(1);
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       __hubEnter(); __station('mf','KeyE');
       if(!Array.isArray(P.contracts)) return 'SKIP: no contract board';
       cs0=JSON.stringify(P.contracts);
       for(i=0;i<P.contracts.length;i++){ c=P.contracts[i]; if(!c||typeof c.n!=='number'||!(c.n>0)||typeof c.reward!=='number') continue; if(done<0){ c.prog=c.n; done=i; } else if(open<0){ c.prog=0; open=i; } }
       if(done<0||open<0) return 'SKIP: fewer than two contracts on the board';
       renderHub();
       a=document.querySelector('#contracts .crow[data-con="'+done+'"] .cp'); b=document.querySelector('#contracts .crow[data-con="'+open+'"] .cp');
       if(!a||!b) return 'SKIP: the staged contract rows were not drawn';
       if(!a.querySelector('button')) return 'SKIP: the finished contract shows no CLAIM button';
       if(b.querySelector('button')) return 'SKIP: the open contract shows a button';
       ha=a.getBoundingClientRect().height; hb=b.getBoundingClientRect().height;
       if(!(ha>0&&hb>0)) return 'SKIP: the contract list has no layout';
       if(Math.abs(ha-hb)>1.5) bad.push('the progress line with CLAIM is '+ha.toFixed(1)+' px tall and one without it '+hb.toFixed(1)+' px');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(cs0!==null) P.contracts=JSON.parse(cs0); }catch(_c){} try{ [].slice.call(document.querySelectorAll('.modal.on')).forEach(function(x){ x.classList.remove('on'); }); }catch(_m){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'21.01',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
