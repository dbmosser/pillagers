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

if ($s.Contains("  {v:'17.55',what:")) { throw "check 17.55 is in the fixture already" }

SubRx @'
  {v:'17.54',what:
'@ @'
  {v:'17.55',what:'in a party raid the backpack says how to offer an item: Y offer on a controller, T offer on keys; solo it says nothing about offering',
   run:function(){
     if(typeof drawBag!=='function'||typeof NET!=='object'||!NET) return 'SKIP: no backpack or party in this fixture';
     if(!window.__deploy||!window.__endRaid) return 'SKIP: no raid in this fixture';
     var bad=[], seen=[], oFT=ctx.fillText, NK={on:NET.on,role:NET.role}, pOn=PAD.on, txt;
     function draw(){ seen.length=0; try{ drawBag(); }catch(_d){ seen.push('THREW '+_d.message); } return seen.join(' | '); }
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over||!G.player) return 'SKIP: staging: no raid';
       G.bagOpen=true; state='raid';
       ctx.fillText=function(s){ seen.push(String(s)); return oFT.apply(this,arguments); };
       NET.on=true; NET.role='join';
       PAD.on=true; txt=draw();
       if(!/Y offer/.test(txt)) bad.push('with a controller in a party raid the backpack does not say Y offers ('+txt.slice(0,160)+')');
       PAD.on=false; txt=draw();
       if(!/T offer/.test(txt)) bad.push('on keys in a party raid the backpack does not say T offers');
       NET.on=false; txt=draw();
       if(/offer/.test(txt)) bad.push('solo the backpack still talks about offering');
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       try{ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; }catch(_f){}
       NET.on=NK.on; NET.role=NK.role; PAD.on=pOn;
       try{ if(G) G.bagOpen=false; __endRaid('abandon'); __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.54',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
