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

if ($s.Contains("  {v:'33.07',what:")) { throw "check 33.07 is in the fixture already" }

SubRx @'
  {v:'33.06',what:
'@ @'
  {v:'33.07',what:'golden kills name all six kinds, including sentry and pillager bot, with the same callout in the linked window (his 3.84 b)',
   run:function(){
     if(typeof goldDownName!=='function') return 'no specific golden death name helper';
     var g=null, oSay=say, oPeer=flowPeer, goldOwn=Object.prototype.hasOwnProperty.call(XF,'xfGold'), gold0=XF.xfGold,
         kinds=['sentry','raider','crawler','bulwark','howler','listener'], names=['sentry','pillager bot','crawler','bulwark','howler','listener'], lines=[], i, want, e, n, w;
     function heard(want){ return lines.length===1&&lines[0].m===want&&lines[0].k==='obj'&&lines[0].sub==='SEARCH THE HOARD'; }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'staging: no raid';
       flowPeer=function(){ return false; }; XF.xfGold=1;
       say=function(m,k,o){ lines.push({m:m,k:k,sub:o&&o.sub}); };
       for(i=0;i<kinds.length;i++){
         want='golden '+names[i]+' down';
         if(goldDownName(kinds[i])!==want) return kinds[i]+' name is '+goldDownName(kinds[i]);
         e={kind:kinds[i],hp:0,x:g.player.x+100,y:g.player.y};
         g.flow=g.flow||{}; g.flow.gold={ref:e,dead:0}; lines.length=0; n=g.containers.length;
         goldTick(0.01);
         if(!heard(want)) return 'host '+kinds[i]+': '+JSON.stringify(lines);
         if(g.containers.length!==n+1) return 'host hoard count for '+kinds[i];
         goldTick(0.01); if(lines.length!==1||g.containers.length!==n+1) return 'host repeats death for '+kinds[i];
         w=JSON.parse(JSON.stringify(goldNetOut()));
         if(w[4]!==kinds[i]) return 'death word lost '+kinds[i];
         g.flow.gold={ref:null,dead:0}; lines.length=0; n=g.containers.length;
         goldNetTake(w);
         if(!heard(want)) return 'linked window without a body '+kinds[i]+': '+JSON.stringify(lines);
         goldNetTake(w);
         if(lines.length!==1||g.containers.length!==n) return 'linked window repeats death or creates a hoard';
       }
       g.flow.gold={ref:{kind:'raider'},dead:0}; lines.length=0;
       goldNetTake([0,1,100,200]);
       if(!heard('golden pillager bot down')) return 'older word lost the mirrored kind';
       return null;
     } finally {
       say=oSay; flowPeer=oPeer; if(goldOwn) XF.xfGold=gold0; else delete XF.xfGold;
       try{ __endRaid('abandon'); }catch(_e){} __topClear();
     } }},
  {v:'33.06',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
