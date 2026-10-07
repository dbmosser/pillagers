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

if ($s.Contains("  {v:'18.62',what:")) { throw "check 18.62 is in the fixture already" }

SubRx @'
  {v:'18.61',what:
'@ @'
  {v:'18.62',what:'the Undercroft HUD reads on any wall and its footer clears the belt: the title and stats line are drawn with a dark halo, the corner readout has a text shadow, and the WASD WALK footer sits above the belt cells',
   run:function(){
     if(typeof drawHubHUD!=='function'||typeof __hubEnter!=='function'||typeof __loop!=='function') return 'SKIP: no Undercroft floor here';
     var bad=[], oFT=ctx.fillText, rec=[], t, i, top=1e9, foot=null, tl=null, st=null, tr;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       t=document.getElementById('title'); if(t) t.classList.remove('on');
       __hubEnter(); __loop(performance.now()); __loop(performance.now()+17);
       ctx.fillText=function(s,x,y){ rec.push({s:String(s),y:y,b:ctx.shadowBlur,c:String(ctx.shadowColor)}); return oFT.apply(this,arguments); };
       try{ __loop(performance.now()+34); } finally { delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; }
       for(i=0;i<rec.length;i++){ if(rec[i].s==='THE UNDERCROFT') tl=rec[i]; if(rec[i].s.indexOf(' in stash')>=0) st=rec[i]; if(rec[i].s.indexOf('USE STATION')>=0) foot=rec[i]; }
       if(!tl||!st) return 'SKIP: the floor HUD was not drawn';
       if(!(tl.b>0)) bad.push('the Undercroft title has no halo over the light wall');
       if(!(st.b>0)) bad.push('the stats line (items in stash) has no halo over the light wall');
       tr=document.getElementById('topright');
       if(tr&&getComputedStyle(tr).textShadow==='none') bad.push('the corner readout (CREDITS, XP) has no text shadow');
       (HUBBELT.cells||[]).forEach(function(c){ if(c&&typeof c.y==='number') top=Math.min(top,c.y); });
       if(foot&&top<1e9&&foot.y>top) bad.push('the footer (y '+Math.round(foot.y)+') sits behind the belt (top '+Math.round(top)+')');
       if(!foot) bad.push('control: no footer was drawn');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; try{ ctx.shadowColor='transparent'; ctx.shadowBlur=0; }catch(_s){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.61',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
