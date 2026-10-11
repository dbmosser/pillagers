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

if ($s.Contains("  {v:'23.10',what:")) { throw "check 23.10 is in the fixture already" }

SubRx @'
  {v:'23.09',what:
'@ @'
  {v:'23.10',what:'two contracts that finish on one container both show: one crate that finishes an open contract and a district contract in the same frame leaves two CONTRACT DONE rows, each with its own words as the detail, rather than the second writing over the first',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)||typeof contractOpen!=='function'||typeof contractDesc!=='function'||typeof feedRows!=='function') return 'SKIP: no contracts or feed rows here';
     var bad=[], P2=__P(), con0=P2.contracts, g=null, i, ct=null, c1, c2, H1, H2, got=[], all;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); keys={};
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player||!g.containers) return 'SKIP: staging: no raid';
       for(i=0;i<g.containers.length;i++){ var k0=g.containers[i]; if(k0&&!k0.dropped&&k0.type&&k0.d!==undefined){ ct=k0; break; } }
       if(!ct) return 'SKIP: staging: no container with a district here';
       c1={type:'open',ct:ct.type,n:2,prog:1,desc:'Open 2 zqx9k boxes',reward:100};
       c2={type:'district',d:ct.d,n:2,prog:1,desc:'zqx9k district',reward:100};
       P2.contracts=[c1,c2];
       H1=contractDesc(c1)+'. Complete contract at mainframe.'; H2=contractDesc(c2)+'. Complete contract at mainframe.';
       if(H1===H2) return 'SKIP: staging: the two contracts read the same';
       g.paused=false; g.msg=''; g.msgT=0; g.msgSub=''; g.msgKey=''; g.feed=[]; g.msgQ=[]; g.msgQM=[];
       contractOpen(ct);
       if(c1.prog<c1.n||c2.prog<c2.n) return 'SKIP: staging: the crate did not finish both contracts';
       all=feedRows();
       for(i=0;i<all.length;i++) got.push(String(all[i].m)+' | '+String(all[i].sub||''));
       for(i=0;i<(g.msgQ||[]).length;i++) got.push(String(g.msgQ[i])+' | '+String((g.msgQM[i]&&g.msgQM[i].o&&g.msgQM[i].o.sub)||''));
       if(got.indexOf('CONTRACT DONE | '+H1)<0) bad.push('the open contract line is not showing or waiting (rows and queue: '+JSON.stringify(got)+')');
       if(got.indexOf('CONTRACT DONE | '+H2)<0) bad.push('the district contract line is not showing or waiting (rows and queue: '+JSON.stringify(got)+')');
       g.msg=''; g.msgT=0; g.feed=[]; g.msgQ=[]; g.msgQM=[];
       say('ZQX9K SAME','info',{sub:'one'}); say('ZQX9K SAME','info',{sub:'two'});
       all=feedRows();
       if(all.length!==1||all[0].sub!=='two') bad.push('a line with no key said twice no longer refreshes in place: '+JSON.stringify(all.map(function(r){ return r.m+' | '+r.sub; })));
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       P2.contracts=con0; keys={};
       try{ var g2=__state(); if(g2){ g2.feed=[]; g2.msgQ=[]; g2.msgQM=[]; g2.msgT=0; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.09',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
