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

if ($s.Contains("  {v:'32.40',what:")) { throw "check 32.40 is in the fixture already" }

SubRx @'
  {v:'32.39',what:
'@ @'
  {v:'32.40',what:'forge action and dollar price draw at full HUD font sizes; upgrade card labels the cost and stash spending leaves score whole',
   run:function(){
     if(typeof drawForgePrompt!=='function') return 'forge still has the shrunken prompt';
     var keep=JSON.stringify(P), oldMine=ARCADE.mine, g, PR=CanvasRenderingContext2D.prototype, realFill=PR.fillText, realPrompt=hudPrompt, hits=[], shrunk=false;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||g.over||!g.player||!g.forge) return 'no live forge';
       g.ents=[]; g.player.wep=Object.assign({},WEAPONS.rifle); g.player.downed=false;
       P.credits=10000; g.cs={s:0,k:0,b:{}}; ARCADE.mine=0;
       hudPrompt=function(s){ if(/upgrade/i.test(String(s))) shrunk=true; return realPrompt.apply(this,arguments); };
       PR.fillText=function(t){ if(this===ctx) hits.push({t:String(t).toLowerCase(),font:this.font,col:this.fillStyle}); return realFill.apply(this,arguments); };
       ctx.save(); try{ drawForgePrompt(400,300); }finally{ ctx.restore(); }
       var action=hits.filter(function(h){return /upgrade/.test(h.t);})[0], price=hits.filter(function(h){return h.t==='$2,500';})[0];
       if(shrunk||!action||!price) return 'full forge action or dollar price did not draw';
       if(Math.abs(msgPx(action.font)-msgPx(FS(TYPE.head)))>0.1||Math.abs(msgPx(price.font)-msgPx(FS(TYPE.label)))>0.1) return 'forge fonts differ from full HUD head and label';
       var probe=document.createElement('canvas').getContext('2d'); probe.fillStyle=UIC.tx_1;
       if(price.col!==probe.fillStyle) return 'affordable forge price is not primary text';
       PR.fillText=realFill; hudPrompt=realPrompt;
       if(!forgeOpen()||g.forgeUI||g.player.wep.fk!==1||P.credits!==7500) return 'instant stash purchase changed';
       if(!g.gunCard||g.gunCard.route!=='cost $2,500') return 'gun card does not clearly label the dollar cost';
       if(g.cs.s!==0||ARCADE.mine!==0) return 'forge changed raid score';
       return null;
     } finally {
       PR.fillText=realFill; hudPrompt=realPrompt;
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       ARCADE.mine=oldMine; __topClear(); __applyLoaded(JSON.parse(keep)); saveProfile();
     } }},
  {v:'32.39',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
