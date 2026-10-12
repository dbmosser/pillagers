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

if ($s.Contains("  {v:'23.95',what:")) { throw "check 23.95 is in the fixture already" }

SubRx @'
  {v:'23.94',what:
'@ @'
  {v:'23.95',what:'his answer 32: the Tripwire Mine keeps a belt cell the pad can reach while an armour plate is carried, and the key holds when the plate is spent',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof hotbarSlots!=='function'||typeof beltStep!=='function') return 'SKIP: no raid here';
     if(!ITEMS.trip||THROWKEYS.indexOf('trip')<0) return 'SKIP: no Tripwire Mine in this build';
     var bad=[], g, p, s0, s1, s3, i, ti=-1, n, reached=false, gk=0;
     function tripAt(s){ var r=[]; for(var j=0;j<s.length;j++) if(s[j]&&(s[j].k==='throw:trip'||s[j].itemKey==='trip')) r.push(j); return r; }
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       p=g.player; p.cooking=0; p.roll=0; p.downed=false;
       if(countArmor()<=0) g.bag.push('plate');
       g.pouch.trip=0;
       s0=hotbarSlots();
       for(i=0;i<s0.length;i++) if(s0[i]&&s0[i].k==='gunkey:'+i) gk++;
       if(!gk) return 'SKIP: staging: no vacant gun key on this belt';
       g.pouch.trip=1;
       s1=hotbarSlots();
       n=tripAt(s1);
       if(n.length!==1) bad.push('with a plate carried the belt shows '+n.length+' Tripwire Mine cells, not 1');
       else ti=n[0];
       if(!s1.some(function(c){ return c&&c.k==='plate'; })) bad.push('the plate lost its cell to the mine');
       if(ti>=0){
         g.hot=gunCell();
         for(i=0;i<12&&!reached;i++){ beltStep(1); if(g.hot===ti&&THROWKEYS[g.tsel]==='trip') reached=true; }
         if(!reached) bad.push('the pad walk (RB) never selected the mine on key '+(ti+1));
         g.pouch.smoke=0; g.pouch.decoy=0; g.pouch.frag=0; g.tsel=0;
         cycleThrow();
         if(THROWKEYS[g.tsel]!=='trip') bad.push('Q never reaches the mine with a plate carried');
         for(i=g.bag.length-1;i>=0;i--) if(ITEMS[g.bag[i]]&&ITEMS[g.bag[i]].use==='armor') g.bag.splice(i,1);
         s3=hotbarSlots(); n=tripAt(s3);
         if(n.length!==1||n[0]!==ti) bad.push('spending the plate moved the mine from key '+(ti+1)+' to '+n.map(function(x){ return x+1; }).join(','));
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var g2=__state(); if(g2&&!g2.over){ g2.player.cooking=0; __endRaid('abandon'); } }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'23.94',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
