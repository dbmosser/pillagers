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

if ($s.Contains("  {v:'25.21',what:")) { throw "check 25.21 is in the fixture already" }

SubRx @'
  {v:'25.20',what:
'@ @'
  {v:'25.21',what:'his answer 36: the music volume starts at 60%, and a pick saved on the old five steps keeps its level',
   run:function(){
     if(typeof GAMEOPTS==='undefined'||typeof applyGameOpts!=='function'||typeof gameOptIx!=='function') return 'SKIP: no settings rows here';
     var bad=[], row=null, i, go0=P.gameOpts?JSON.parse(JSON.stringify(P.gameOpts)):null, mv0=P.volMus6, vm0=CFG.volMusic, tk=null, tkv;
     try{
       for(i=0;i<GAMEOPTS.length;i++) if(GAMEOPTS[i].k==='volMusic') row=GAMEOPTS[i];
       if(!row) return 'SKIP: no Music volume row';
       tk=tunedKeys(); tkv=tk.volMusic; delete tk.volMusic;
       var names=row.opts.map(function(o){ return o.n; }).join(',');
       if(names.indexOf('60%')<0) bad.push('the Music volume row has no 60% step ('+names+')');
       if(!(row.opts[row.def]&&row.opts[row.def].cfg.volMusic===0.6)) bad.push('the Music volume starts at '+(row.opts[row.def]&&row.opts[row.def].n)+', not 60%');
       P.gameOpts=P.gameOpts||{}; delete P.gameOpts.volMusic; P.volMus6=1;
       applyGameOpts();
       if(CFG.volMusic!==0.6) bad.push('a fresh profile plays music at '+CFG.volMusic+', not 0.6');
       P.gameOpts.volMusic=4; delete P.volMus6; applyGameOpts();
       if(CFG.volMusic!==1) bad.push('a profile saved with Full on the old steps now plays music at '+CFG.volMusic);
       applyGameOpts();
       if(CFG.volMusic!==1) bad.push('applying the settings twice moved a saved Full to '+CFG.volMusic);
       P.gameOpts.volMusic=3; delete P.volMus6; applyGameOpts();
       if(CFG.volMusic!==0.75) bad.push('a profile saved with 75% on the old steps now plays music at '+CFG.volMusic);
       P.gameOpts.volMusic=1; delete P.volMus6; applyGameOpts();
       if(CFG.volMusic!==0.25) bad.push('a profile saved with 25% now plays music at '+CFG.volMusic);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(go0) P.gameOpts=go0; else delete P.gameOpts; if(mv0===undefined) delete P.volMus6; else P.volMus6=mv0; if(tk&&tkv!==undefined) tk.volMusic=tkv; P.volMus6=1; applyGameOpts(); if(mv0===undefined) delete P.volMus6; else P.volMus6=mv0; CFG.volMusic=vm0; VOL_LAST=''; volApply(); }catch(_r){} }
     return bad.length?bad.join('; '):null; }},
  {v:'25.20',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
