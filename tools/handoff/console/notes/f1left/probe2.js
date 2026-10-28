(function(){
  var out=[], g, i;
  try{
    var oSay=say; say=function(){};
    P.runs=0; __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
    __deploy({kit:[],safe:null,mapIx:0,seed:4242});
    g=__state(); g.career=1; g.arcade=0; g.legendAutoDone=true; g.bagOpen=false; g.mapOpen=false;
    say=oSay; for(i=0;i<4;i++) say('FEED LINE '+i,'info'); say=function(){};
    __forceSize(1920,1080); g.legendOn=1;
    var fd=feedDraw, seen=[]; feedDraw=function(){ seen.push('feed LEGSIDE='+JSON.stringify(LEGSIDE)); return fd.apply(this,arguments); };
    for(i=0;i<4;i++){ __frame(0.016); seen.push('after frame LEGSIDE='+JSON.stringify(LEGSIDE)+' legend='+JSON.stringify(HUDBOX.legend&&{x:HUDBOX.legend.x,y:HUDBOX.legend.y})); }
    feedDraw=fd;
    out.push(seen.join('\n')); out.push('rows '+JSON.stringify((FEEDBOX.rows||[]).map(function(r){return [r.t,Math.round(r.x),Math.round(r.y)]})));
    say=oSay;
  }catch(e){ out.push('threw '+e.message+' '+e.stack); }
  return out.join('\n');
})()
