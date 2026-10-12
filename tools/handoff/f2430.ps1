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

if ($s.Contains("  {v:'24.30',what:")) { throw "check 24.30 is in the fixture already" }

SubRx @'
  {v:'24.29',what:
'@ @'
  {v:'24.30',what:'his answer 20: the RUN OVER score counts up from $0 to the final score over about a second and a half, and a rebuild of the card carries on the count',
   run:function(){
     var bad=[], sv=null, src0, tried0, c, s, n, over0=null;
     function q(cl){ return ATT.el?ATT.el.querySelector('.'+cl):null; }
     function num(){ var e=q('aos'), m=e?/\$([\d,]+)/.exec(e.textContent):null; return m?+m[1].replace(/,/g,''):NaN; }
     try{
       __topClear(); __runPrep();
       if(typeof arcadeOverSync!=='function'||typeof ARCADE!=='object'||typeof arcadeEnter!=='function') return 'SKIP: no RUN OVER card in this build';
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(__state()&&!__state().over) __endRaid('abandon');
       if(NET.on) return 'SKIP: a party link is up in the fixture';
       sv={bc:NET.bc,same:NET.same,pair:NET.pair};
       NET.bc={postMessage:function(){},close:function(){}}; NET.same='host'; NET.pair='tp';
       src0=ATT.src; tried0=ATT.tried; ATT.src=null; ATT.tried=true;
       if(!arcadeEnter('host')) return 'SKIP: arcadeEnter(host) failed';
       arcadeAttStart();
       ARCADE.over={at:Date.now()-350,why:'t',team:43210,p1:{s:43210,k:3,x:1,d:0},p2:null};
       arcadeAttShow(); c=q('arcover');
       if(!c||c.style.display==='none') return 'SKIP: the RUN OVER card did not come up';
       n=num();
       if(!(n>0&&n<43210)) bad.push('a third of a second after the run end the score reads '+(q('aos')||{}).textContent+', not part way up to $43,210');
       s=n;
       ARCADE.over.at=Date.now()-900; arcadeAttShow(); n=num();
       if(!(n>s&&n<43210)) bad.push('the count does not climb ('+s+' then '+n+')');
       ARCADE.over.at=Date.now()-2500; arcadeAttShow(); n=num();
       if(n!==43210) bad.push('after the count the score reads '+(q('aos')||{}).textContent+', not $43,210');
       if(!/SCORE/.test((q('aos')||{}).textContent||'')) bad.push('the score line lost its label ('+(q('aos')||{}).textContent+')');
       ARCADE.over.at=Date.now()-5000; ARCADE.over.team=0; ARCADE.over.p1.s=0; arcadeAttShow(); n=num();
       if(n!==0) bad.push('a run that scored nothing reads '+(q('aos')||{}).textContent);
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ ARCADE.over=null; }catch(_o){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(sv){ NET.bc=sv.bc; NET.same=sv.same; NET.pair=sv.pair; } }catch(_n){}
       try{ if(sv){ ATT.src=src0; ATT.tried=tried0; } }catch(_a){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'24.29',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
