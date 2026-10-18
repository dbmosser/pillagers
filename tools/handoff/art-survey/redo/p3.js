var r=await window.__art.scene('duo',{}); var A=window.__art, gx=window.__gx; window.__cfg({ambient:gx('DEF.ambient'),viewFar:gx('DEF.viewFar'),coneDeg:gx('DEF.coneDeg')}); var b=A.base(); A.cam(b.x,b.y-10,2.8); A.draw(2);
var p=gx('G.player');
return {VF:gx('VF()'),AMBR:gx('AMBR()'),face:p.face,cone:gx('CFG.coneDeg'),viewFar:gx('CFG.viewFar'),amb:gx('CFG.ambient'),wxview:gx('wx().view'),Z:gx('Z'),isDay:gx('isDay()'),SOFTR:gx('SOFTR'),px:p.x,py:p.y,mate:gx('NET.on'),fogLift:gx('CFG.fogLift')};
