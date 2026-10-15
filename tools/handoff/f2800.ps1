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

if ($s.Contains("  {v:'28.00',what:")) { throw "check 28.00 is in the fixture already" }

SubRx @'
  {v:'27.99',what:
'@ @'
  {v:'28.00',what:'his answer 15: DEMO players get a random character each run: six runs give at least three different looks, every piece is a real piece of its kind, and his own look is back after the arcade',
   run:function(){
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object'||typeof COSKEY!=='object') return 'SKIP: no arcade here';
     if(typeof arcadeLook!=='function') return 'there is no random character in this build (arcadeLook)';
     var bad=[], cos0='', all0, seen={}, n=0, i, k, g, look, id, c, cn;
     function snap(){ var s=[], q; for(q in COSKEY) if(Object.prototype.hasOwnProperty.call(COSKEY,q)) s.push(q+'='+P[COSKEY[q]]); return s.join(','); }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       cos0=snap(); all0=P.cosAll;
       for(i=0;i<6;i++){
         if(!arcadeDeploy({mapIx:0,seed:4242})){ bad.push('no raid was built for run '+(i+1)); break; }
         look=snap(); if(!seen[look]){ seen[look]=1; n++; }
         for(k in COSKEY){
           if(!Object.prototype.hasOwnProperty.call(COSKEY,k)) continue;
           id=P[COSKEY[k]]; c=cosFind(id);
           if(!c||c.kind!==k){ bad.push('run '+(i+1)+': '+k+' is "'+id+'", not a piece of that kind'); break; }
         }
         if(cosWorn('build')!==P.cosBuild) bad.push('run '+(i+1)+': the body build in hand is not the one picked ('+cosWorn('build')+' not '+P.cosBuild+')');
       }
       if(n<3) bad.push('six runs gave only '+n+' different looks, not 3 or more');
       if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave();
       cn=snap();
       if(cn!==cos0) bad.push('his own look is not back after the arcade ('+cos0+' then '+cn+')');
       if(!!P.cosAll!==!!all0) bad.push('the open rack stayed open after the arcade (cosAll '+P.cosAll+')');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear();
     }
     return bad.length?bad.slice(0,6).join('; '):null; }},
  {v:'27.99',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
