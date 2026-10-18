// usage: node mkmock.mjs qid key screen cx cy   (cx,cy = top-left of the 213x133 source region, in 1920x1080 shot pixels)
import fs from 'fs';
import path from 'path';
const [qid,key,screen,cx,cy]=process.argv.slice(2);
const K=key.toUpperCase(), k=key.toLowerCase();
const root='C:/claudecode/dark raiders/tools/handoff/art-survey';
const pic='../shots/'+qid+'-'+k+'/'+screen+'-1080.jpg';
const x=-Math.round(+cx*3), y=-Math.round(+cy*3);
const html='<!doctype html>\n<html><head><meta charset="utf-8"><title>'+qid+'-'+K+'</title>\n<style>\n'+
'html,body{margin:0;padding:0;width:1920px;height:1080px;overflow:hidden;background:#101410}\n'+
'.f{position:absolute;left:0;top:0;width:1920px;height:1080px;background:url('+pic+') 0 0/1920px 1080px no-repeat}\n'+
'.i{position:absolute;right:20px;top:20px;width:640px;height:400px;box-sizing:border-box;border:2px solid rgba(255,255,255,.82);outline:1px solid rgba(0,0,0,.55);background:url('+pic+') '+x+'px '+y+'px/5760px 3240px no-repeat;image-rendering:auto}\n'+
'.t{position:absolute;right:6px;bottom:6px;font:700 16px/1 Arial,Helvetica,sans-serif;color:#fff;background:rgba(0,0,0,.6);padding:4px 7px;border-radius:3px}\n'+
'</style></head><body><div class="f"></div><div class="i"><span class="t">3x</span></div></body></html>\n';
fs.writeFileSync(path.join(root,'mock',qid+'-'+K+'.html'),html);
console.log('wrote',qid+'-'+K);
