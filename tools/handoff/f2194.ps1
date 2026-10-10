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

if ($s.Contains("  {v:'21.94',what:")) { throw "check 21.94 is in the fixture already" }

SubRx @'
  {v:'21.93',what:
'@ @'
  {v:'21.94',what:'a raid line with a detail shows it on its row as HEADLINE, a middle dot, then the detail, and a line with no detail is drawn as before',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     var bad=[], ev=[], g, realSay=say, H1=['ZQ','HEAD'].join(' '), D1=['zq','detail'].join(' '), PL=['zq','plain'].join(' '), want=H1+'  \u00b7  '+D1, oFT=ctx.fillText, j, got=false, gotPl=false, gotBare=false;
     function unspy(){ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; }
     function spy(){ ev=[]; ctx.fillText=function(t){ ev.push(String(t)); return oFT.apply(this,arguments); }; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       keys={}; g.mapOpen=false; g.bagOpen=false; g.msgT=0; g.msg=''; g.msgQ=[]; g.msgQM=[]; g.feed=[];
       realSay(PL); realSay(H1,'info',{sub:D1});
       if(g.msg!==H1) bad.push('G.msg is '+JSON.stringify(g.msg)+', not the headline alone');
       say=function(){};
       spy();
       try{ __frame(0.016); } finally { unspy(); }
       for(j=0;j<ev.length;j++){ if(ev[j]===want) got=true; if(ev[j]===H1) gotBare=true; if(ev[j]===PL) gotPl=true; }
       if(!got) bad.push('the line with a detail was not drawn as '+JSON.stringify(want)+(gotBare?' (only the headline was drawn)':''));
       if(!gotPl) bad.push('the line with no detail was not drawn exactly as said');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ unspy(); say=realSay; keys={}; try{ var g2=__state(); if(g2){ g2.msgT=0; g2.msg=''; g2.feed=[]; g2.msgQ=[]; g2.msgQM=[]; } if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'21.93',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
