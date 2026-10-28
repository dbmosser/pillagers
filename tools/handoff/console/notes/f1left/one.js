(function(){ var want=['34.89'], o={}, n=0;
  __REGRESS.forEach(function(t,i){ if(want.indexOf(String(t.v))<0) return; var r; try{ __runPrep(); __topClear(); r=t.run(); }catch(x){ r='threw '+x; } n++; o[t.v]=r?String(r).slice(0,4000):'PASS'; });
  o._ran=n; return JSON.stringify(o); })()
