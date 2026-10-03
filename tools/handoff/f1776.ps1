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

if ($s.Contains("  {v:'17.76',what:")) { throw "check 17.76 is in the fixture already" }

SubRx @'
  {v:'17.75',what:
'@ @'
  {v:'17.76',what:'the raid controls legend: its two columns no longer collide (the label column is wide enough for TACTICAL BELT) and after three raids it starts collapsed, H still opens it',
   run:function(){
     if(!window.__deploy||!window.__endRaid) return 'SKIP: no raid in this fixture';
     var bad=[], r0=P.runs, oSay=say, seen=[], oFT=ctx.fillText, i, kx=null, lx=null, nx=null;
     try{
       say=function(){};
       P.runs=0; __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over) return 'SKIP: staging: no raid';
       if(G.legendOn!==1) bad.push('a new player does not get the legend open ('+G.legendOn+')');
       ctx.fillText=function(s,x,y){ seen.push({s:String(s),x:x,y:y,f:ctx.font}); return oFT.apply(this,arguments); };
       try{ drawHUD(); }catch(_h){}
       ctx.fillText=oFT;
       for(i=0;i<seen.length;i++){ if(seen[i].s==='1-9') kx=seen[i]; if(seen[i].s==='tactical belt') lx=seen[i]; if(seen[i].s==='B / I'||seen[i].s==='B/I') nx=seen[i]; }
       if(!kx||!lx||!nx) bad.push('the legend did not draw its belt row ('+(kx?'':'no key ')+(lx?'':'no label ')+(nx?'':'no next key')+')');
       else{ ctx.font=lx.f; var w=ctx.measureText('tactical belt').width; if(lx.x+w>nx.x-4) bad.push('TACTICAL BELT runs into the next column ('+Math.round(lx.x+w)+' past '+Math.round(nx.x)+')'); }
       __endRaid('abandon'); __topClear();
       P.runs=3; __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over) return 'SKIP: staging: no second raid';
       if(G.legendOn!==0) bad.push('after three raids the legend still starts open ('+G.legendOn+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ ctx.fillText=oFT; say=oSay; P.runs=r0; try{ if(G) __endRaid('abandon'); __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'17.75',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
