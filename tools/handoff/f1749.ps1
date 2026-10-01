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

if ($s.Contains("  {v:'17.49',what:")) { throw "check 17.49 is in the fixture already" }

SubRx @'
  {v:'17.48',what:
'@ @'
  {v:'17.49',what:'THE OVERSEER is drawn to its size: a warden with the boss radius is drawn about half again as big as a plain warden, around where it stands, and a plain warden is drawn as before',
   run:function(){
     if(typeof drawWardenAt!=='function'||typeof wardenDrawScale!=='function') return 'this build draws the boss at a plain warden size';
     if(typeof wc==='undefined'||!wc||typeof wc.getTransform!=='function'||!window.__deploy) return 'SKIP: no world canvas in this fixture';
     var bad=[], o=drawWardenS, seen=[], a, b;
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over) return 'SKIP: staging: no raid';
       drawWardenS=function(e){ var t=wc.getTransform(); seen.push({a:t.a,x:t.a*e.x+t.e,y:t.d*e.y+t.f}); };
       wc.save(); wc.setTransform(1,0,0,1,0,0);
       drawWardenAt({kind:'warden',x:500,y:400,r:30,face:0});
       drawWardenAt({kind:'warden',x:500,y:400,r:44,face:0,name:'THE OVERSEER',boss:1});
       wc.restore();
       a=seen[0]; b=seen[1];
       if(!a||!b) bad.push('a warden was not drawn');
       else{
         if(Math.abs(a.a-1)>0.001) bad.push('a plain warden was drawn at scale '+a.a);
         if(!(b.a>1.4&&b.a<1.55)) bad.push('the boss was drawn at scale '+b.a.toFixed(2)+', not about 1.47');
         if(Math.abs(b.x-500)>0.5||Math.abs(b.y-400)>0.5) bad.push('the bigger boss is not drawn where it stands ('+b.x.toFixed(1)+','+b.y.toFixed(1)+')');
       }
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{
       drawWardenS=o;
       try{ __endRaid('abandon'); __topClear(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.48',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
