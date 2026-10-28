$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
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

# RUN OVER MOMENTS READ CLEARLY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
body #attract .arcover .aocrown > div:last-child{color:var(--acc) !important;}
'@ @'
/* v28.xx (cw-cx-overmomentlook): critic round 3, both run-over cards 3/5. One stat grid, couch-size labels and a quiet scrim. */
html body #attract[style*="block"]:has(.arcover[style*="block"]){background:rgba(6,7,8,.80);-webkit-backdrop-filter:blur(6px);backdrop-filter:blur(6px);}
html body #attract[style*="block"]:has(.arcover[style*="block"]) > video{opacity:.12 !important;}
html body #attract[style*="block"]:has(.arcover[style*="block"]) .arcstrip{display:none !important;}
html body #attract .arcover::before{display:none;}
html body #attract .arcover .aoh{font-size:max(32px,calc(var(--fs-title) * var(--attz,1)));}
html body #attract .arcover .aos{margin-top:calc(var(--sp-2) * var(--attz,1));}
html body #attract .arcover .aos .aolb, html body #attract .arcover .aosc i{font-size:max(20px,calc(var(--fs-body) * var(--attz,1))) !important;letter-spacing:.04em;}
html body #attract .arcover .aosr{display:grid;grid-template-columns:calc(48px * var(--attz,1)) repeat(4,minmax(0,1fr));column-gap:calc(16px * var(--attz,1));align-items:start;}
html body #attract .arcover .aost[data-solo="1"] .aosr{grid-template-columns:repeat(3,minmax(0,1fr));}
html body #attract .arcover .aosn{min-width:0;font-size:max(20px,calc(var(--fs-body) * var(--attz,1)));line-height:1.1;padding-top:calc(6px * var(--attz,1));}
html body #attract .arcover .aosn[data-seat="1"], html body #attract .arcover .aowho[data-seat="p1"]{color:#ffb454;}
html body #attract .arcover .aosn[data-seat="2"], html body #attract .arcover .aowho[data-seat="p2"]{color:#53d9e8;}
html body #attract .arcover .aobm{border-top:1px solid var(--ui-line);padding-top:calc(24px * var(--attz,1));gap:calc(24px * var(--attz,1)) !important;}
html body #attract .arcover .aobmt > div:first-child{font-size:max(20px,calc(var(--fs-body) * var(--attz,1))) !important;letter-spacing:.04em !important;}
html body #attract .arcover .aobmt > div:last-child{font-size:max(20px,calc(var(--fs-body) * var(--attz,1))) !important;color:var(--tx-1) !important;}
html body #attract .arcover .aocrown{border-left:3px solid var(--r-gold);padding-left:calc(12px * var(--attz,1));}
'@

SubRx @'
g=document.createElement('div'); g.className='aost';
'@ @'
g=document.createElement('div'); g.className='aost'; g.setAttribute('data-solo',ARCADE.solo?'1':'0');
'@

SubRx @'
    if(rows[i][0]){ cell=document.createElement('span'); cell.className='aosn'; cell.textContent=rows[i][0]; row.appendChild(cell); }
'@ @'
    if(rows[i][0]){ cell=document.createElement('span'); cell.className='aosn'; cell.textContent=rows[i][0]; cell.setAttribute('data-seat',String(i+1)); row.appendChild(cell); }
'@

SubRx @'
      if(hd[j][1]==='d'&&!(r.d>=0)) continue;
'@ @'
      // v28.xx (cw-cx-overmomentlook): every player keeps all four cells, including a dash for an older peer with unknown deaths.
'@

SubRx @'
v.textContent=(hd[j][1]==='s')?arcadeCr(r.s):String(r[hd[j][1]]|0);
'@ @'
v.textContent=(hd[j][1]==='s')?arcadeCr(r.s):((hd[j][1]==='d'&&!(r.d>=0))?'--':String(r[hd[j][1]]|0));
'@

SubRx @'
      s1=document.createElement('div'); s1.style.cssText='font-size:.62em;letter-spacing:.14em;color:#f2e6c8;opacity:.78'; s1.textContent=rows[i][0]+(rows[i][2]?'  \u00b7  '+rows[i][2]:'');
'@ @'
      s1=document.createElement('div'); s1.style.cssText='letter-spacing:.04em;color:var(--tx-2)'; s1.textContent=rows[i][0];
      if(rows[i][2]){ var who=document.createElement('span'); who.className='aowho'; who.setAttribute('data-seat',String(rows[i][2]).toLowerCase()); who.textContent=' \u00b7 '+rows[i][2]; s1.appendChild(who); }
'@

SubRx @'
  var m={t:'arcsc',pair:NET.pair,run:ARCADE.run.id,s:Math.max(0,ARCADE.mine|0),k:Math.max(0,ARCADE.kills|0),x:Math.max(0,ARCADE.ext|0)};
'@ @'
  var m={t:'arcsc',pair:NET.pair,run:ARCADE.run.id,s:Math.max(0,ARCADE.mine|0),k:Math.max(0,ARCADE.kills|0),x:Math.max(0,ARCADE.ext|0),d:Math.max(0,ARCADE.deaths|0)};
'@

SubRx @'
  ARCADE.scSeen=Date.now(); ARCADE.mate=Math.max(0,Math.round(+m.s||0)); ARCADE.mateK=Math.max(0,m.k|0); ARCADE.mateX=Math.max(0,m.x|0);
'@ @'
  ARCADE.scSeen=Date.now(); ARCADE.mate=Math.max(0,Math.round(+m.s||0)); ARCADE.mateK=Math.max(0,m.k|0); ARCADE.mateX=Math.max(0,m.x|0);
  ARCADE.mateD=(typeof m.d==='number'&&isFinite(m.d)&&m.d>=0)?Math.floor(m.d):-1; // v28.xx (cw-cx-overmomentlook): both cards show the same actual deaths.
'@

SubRx @'
  ARCADE.kills=0; ARCADE.mateK=0; ARCADE.mateX=0; ARCADE.scEv=''; ARCADE.scN=0; ARCADE.scAt=0; ARCADE.scDirty=(ARCADE.role!=='p2')?1:0;   // v23.29 (arcade8)
'@ @'
  ARCADE.kills=0; ARCADE.mateK=0; ARCADE.mateX=0; ARCADE.mateD=-1; ARCADE.scEv=''; ARCADE.scN=0; ARCADE.scAt=0; ARCADE.scDirty=(ARCADE.role!=='p2')?1:0;   // v23.29 (arcade8)
'@

SubRx @'

      mt=((ARCADE.mate|0)>0||(ARCADE.mateK|0)>0||!!ARCADE.mateBm)?{s:Math.max(0,ARCADE.mate|0),k:ARCADE.mateK|0,x:ARCADE.mateX|0,d:-1}:null;
'@ @'

      mt=((ARCADE.mate|0)>0||(ARCADE.mateK|0)>0||!!ARCADE.mateBm)?{s:Math.max(0,ARCADE.mate|0),k:ARCADE.mateK|0,x:ARCADE.mateX|0,d:(typeof ARCADE.mateD==='number'?ARCADE.mateD:-1)}:null;
'@

SubRx @'

  mt=((ARCADE.mate|0)>0||(ARCADE.mateK|0)>0||!!ARCADE.mateBm)?{s:Math.max(0,ARCADE.mate|0),k:ARCADE.mateK|0,x:ARCADE.mateX|0,d:-1}:null;
'@ @'

  mt=((ARCADE.mate|0)>0||(ARCADE.mateK|0)>0||!!ARCADE.mateBm)?{s:Math.max(0,ARCADE.mate|0),k:ARCADE.mateK|0,x:ARCADE.mateX|0,d:(typeof ARCADE.mateD==='number'?ARCADE.mateD:-1)}:null;
'@

SubRx @'
var VER='35.98';
'@ @'
var VER='35.99';
'@

$pat = "(?m)^  now:'v35\.98:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.99: Run over stats align in both windows, with larger moment captions and a quieter backdrop. Check 35.99 fails on v35.98',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
