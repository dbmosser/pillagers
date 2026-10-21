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

if ($s.Contains("  {v:'33.17',what:")) { throw "check 33.17 is in the fixture already" }

SubRx @'
  {v:'33.16',what:
'@ @'
  {v:'33.17',what:'cw-headbody, job 68 (his a01 D head 1.2 and a05 B pauldrons 1.12): only the head, hair, hats, face and the suit head marks draw at the 1.2 head scale; the shoulder caps and the suit body paint draw at body scale and the pauldrons at FIG_VEST, not 1.344',
   run:function(){
     if(typeof drawOp!=='function'||typeof drawPads!=='function'||typeof FIG_HEAD!=='number'||typeof FIG_VEST!=='number') return 'SKIP: no painter here';
     if(typeof TEAMHI!=='object'||!TEAMHI||!TEAMHI.ally) return 'SKIP: no team colours here';
     var bad=[], w0=wc, od=drawPads, painter=(typeof drawOp0==='function')?drawOp0:drawOp, cvs=document.createElement('canvas'), x2, hi, seen={pads:[],caps:[],mouth:[],eye:[],chest:[]}, k;
     cvs.width=240; cvs.height=240; x2=cvs.getContext('2d'); if(!x2||typeof x2.getTransform!=='function') return 'SKIP: no canvas transform here';
     x2.fillStyle=TEAMHI.ally; hi=x2.fillStyle;
     function sc(){ return Math.abs(x2.getTransform().a)/4; }
     function near(list,want,what){ var i; if(!list.length){ bad.push(what+': not drawn'); return; } for(i=0;i<list.length;i++) if(Math.abs(list[i]-want)>0.005){ bad.push(what+' draws at '+list[i].toFixed(3)+', not '+want.toFixed(3)); return; } }
     function paint(st){ var b={hero:0,moving:false,sprint:false,ads:false,hurt:0,rl:0,bulk:0,build:'lean',hat:'none',own:{wep:null}}, q; for(q in st) b[q]=st[q];
       x2.setTransform(1,0,0,1,0,0); x2.clearRect(0,0,240,240); x2.setTransform(4,0,0,4,120,200); wc=x2;
       try{ painter(0,0,0,0,'#242832',0,0,'none',0,b); } finally { wc=w0; x2.setTransform(1,0,0,1,0,0); } }
     x2.fillRect=function(){ var s=String(this.fillStyle).toLowerCase();
       if(s===hi) seen.caps.push(sc()); else if(s==='#8a5c46') seen.mouth.push(sc()); else if(s==='#ff3a3a') seen.eye.push(sc()); else if(s==='#4de3d0') seen.chest.push(sc());
       return CanvasRenderingContext2D.prototype.fillRect.apply(this,arguments); };
     drawPads=function(){ seen.pads.push(sc()); return od.apply(this,arguments); };
     try{
       paint({team:'ally',pads:'padsround'});
       k={caps:seen.caps.slice(),mouth:seen.mouth.slice(),pads:seen.pads.slice()};
       seen.mouth=[]; paint({outfit:'outrobot'});
       near(k.pads,FIG_VEST,'the pauldrons (padsround on a Lean ally)');
       near(k.caps,1,'the team shoulder caps');
       if(k.caps.length&&k.caps.length!==2) bad.push('the team shoulder caps drew '+k.caps.length+' strips, not 2');
       near(k.mouth,FIG_HEAD,'the mouth (a head part)');
       near(seen.eye,FIG_HEAD,'the robot eye bar and antenna (suit head marks)');
       near(seen.chest,1,'the robot chest light (suit body paint)');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ drawPads=od; wc=w0; delete x2.fillRect; }
     return bad.length?bad.join('; '):null; }},
  {v:'33.16',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
