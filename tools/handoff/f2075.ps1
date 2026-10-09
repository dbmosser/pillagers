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

if ($s.Contains("  {v:'20.75',what:")) { throw "check 20.75 is in the fixture already" }

SubRx @'
  {v:'20.74',what:
'@ @'
  {v:'20.75',what:'at 4K the Peddler panel, YOU DIED and the NOTORIETY stamp are drawn twice their 1080p size, as the world and the backpack are',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__forceSize||!window.__textTrace||typeof drawTrade!=='function'||typeof drawHUD!=='function'||typeof hudRes!=='function') return 'SKIP: this build cannot size the screen or trace the HUD';
     var bad=[], g=null, ik=null, k, a=null, b=null, keep=null;
     function find(tr,f){ for(var i=0;i<tr.length;i++) if(f(tr[i].t)) return tr[i].px; return 0; }
     function at(w,h){
       var o={}, tr;
       __forceSize(w,h);
       if(Math.abs(W-w)>2||Math.abs(H-h)>2) return null;
       g.trade={stock:[{k:ik,price:98765,sold:false}],hp:1}; g.pedSel=0;
       try{ tr=__textTrace(function(){ drawTrade(); }); } finally { g.trade=null; }
       o.ped=find(tr,function(t){ return t==='THE PEDDLER'; });
       g.deathBeat=0.5; g.notoAt=(g.t||0)-1; g.notoN=2; g.notoWhy='staged for a size test';
       try{ tr=__textTrace(function(){ drawHUD(); }); } finally { g.deathBeat=keep.db; g.notoAt=keep.na; g.notoN=keep.nn; g.notoWhy=keep.nw; }
       o.died=find(tr,function(t){ return t==='YOU DIED'; });
       o.noto=find(tr,function(t){ return /^NOTORIETY \d/.test(t); });
       o.r=hudRes();
       return o;
     }
     for(k in ITEMS) if(ITEMS[k]&&!ITEMS[k].use&&!/^gun_/.test(k)){ ik=k; break; }
     if(!ik) return 'SKIP: no plain item here';
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       keep={db:g.deathBeat,na:g.notoAt,nn:g.notoN,nw:g.notoWhy,tr:g.trade,ps:g.pedSel};
       a=at(1920,1080); b=at(3840,2160);
       if(!a||!b) return 'SKIP: the screen could not be sized to 1080p and 4K here';
       if(!(a.r<1.01&&b.r>1.9)) return 'SKIP: the screen factor reads '+a.r+' and '+b.r;
       [['the Peddler panel','ped'],['YOU DIED','died'],['the NOTORIETY stamp','noto']].forEach(function(q){
         var x=a[q[1]], y=b[q[1]];
         if(!(x>0)||!(y>0)) bad.push(q[0]+' was not drawn ('+x+' px at 1080p, '+y+' px at 4K)');
         else if(y/x<1.8) bad.push(q[0]+' is '+x.toFixed(1)+' px at 1080p and '+y.toFixed(1)+' px at 4K, '+(y/x).toFixed(2)+' times, not about 2');
       });
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ __forceSize(1920,1080); }catch(_f){}
       try{ var g2=__state(); if(g2&&keep){ g2.trade=keep.tr||null; g2.pedSel=keep.ps; g2.deathBeat=keep.db; g2.notoAt=keep.na; g2.notoN=keep.nn; g2.notoWhy=keep.nw; } if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.74',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
