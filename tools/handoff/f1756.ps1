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

if ($s.Contains("  {v:'17.56',what:")) { throw "check 17.56 is in the fixture already" }

SubRx @'
  {v:'17.55',what:
'@ @'
  {v:'17.56',what:'THE OVERSEER by name in a party: the kill feed names it, not WARDEN, and a linked window that sees it go down is told its hoard is open',
   run:function(){
     if(typeof netFeedKill!=='function'||typeof netEntDeathFx!=='function'||typeof BOSS_NAME==='undefined') return 'SKIP: this build has no kill feed or no boss';
     if(!window.__deploy||!window.__endRaid) return 'SKIP: no raid in this fixture';
     var bad=[], oB=netBroadcast, oP=netFeedPush, oSay=say, lines=[], w;
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over||!G.player) return 'SKIP: staging: no raid';
       netBroadcast=function(){ return 0; }; netFeedPush=function(){ return 0; };
       say=function(t){ lines.push(String(t)); };
       w=netFeedKill(1,{kind:'warden',boss:1,name:BOSS_NAME,hp:0});
       if(w!==BOSS_NAME) bad.push('the kill feed names the boss '+JSON.stringify(w));
       w=netFeedKill(1,{kind:'warden',name:'',hp:0});
       if(w!=='WARDEN') bad.push('the kill feed names a plain warden '+JSON.stringify(w));
       netEntDeathFx({kind:'warden',name:BOSS_NAME,x:G.player.x+300,y:G.player.y,r:44,face:0,hp:0,maxhp:4000});
       if(!lines.some(function(t){ return t.indexOf(BOSS_NAME+' is down')===0; })) bad.push('a linked window that saw the boss go down said '+JSON.stringify(lines).slice(0,160));
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       netBroadcast=oB; netFeedPush=oP; say=oSay;
       try{ if(G) G.deathAnims=[]; __endRaid('abandon'); __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.55',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
