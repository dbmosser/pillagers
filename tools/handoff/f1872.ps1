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

if ($s.Contains("  {v:'18.72',what:")) { throw "check 18.72 is in the fixture already" }

SubRx @'
  {v:'18.71',what:
'@ @'
  {v:'18.72',what:'a contract count never sits alone on a line in the raid panel: every wrapped CONTRACTS line has words, not just a count like 0/1',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     var bad=[], g, oFT=ctx.fillText, rec=[], i, on=false, n=0, oC=P.contracts;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); g.bagOpen=false; g.mapOpen=false;
       ctx.fillText=function(s){ rec.push(String(s)); return oFT.apply(this,arguments); };
       try{ __frame(0.016); } finally { delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; }
       for(i=0;i<rec.length;i++){
         if(rec[i]==='CONTRACTS'){ on=true; continue; }
         if(!on) continue;
         if(/^[A-Z ]{6,}$/.test(rec[i])) break;
         n++;
         if(/^\s*\d+\/\d+\s*$/.test(rec[i])) bad.push('a count sits alone on a line ('+rec[i]+')');
       }
       if(!n) return 'SKIP: no contract lines were drawn';
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; P.contracts=oC; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.slice(0,3).join('; '):null; }},
  {v:'18.71',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
