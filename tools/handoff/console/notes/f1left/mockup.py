# Picture question for his "all this shit moves to the left" (10-27): now, reading A, reading B. Mockups cut and pasted from two real 1080p shots of v35.22.
from PIL import Image, ImageDraw, ImageFont
import os
D=os.path.join(os.path.dirname(__file__),'..','shots','f1left-before')
O=os.path.dirname(__file__)
s79=Image.open(os.path.join(D,'79-raid-controls-folded-career-1080.jpg')).convert('RGB')
s80=Image.open(os.path.join(D,'80-raid-controls-career-after-f1-1080.jpg')).convert('RGB')
LIST=(492,588,758,854); CAP=(875,928,1043,952); BELT=(548,950,1558,1065); CHIP=(435,929,537,954); FEED=(10,686,320,804)
def cp(src,box,dst,at): dst.paste(src.crop(box),at)
def outline(d,b,col,w=5): d.rectangle(b,outline=col,width=w)
F=lambda n,b=False: ImageFont.truetype('C:/Windows/Fonts/'+('segoeuib.ttf' if b else 'segoeui.ttf'),n)
AMB=(255,192,74); CY=(80,220,235)

# now: the screen after one f1, with both readings boxed
now=s80.copy(); d=ImageDraw.Draw(now)
outline(d,(LIST[0]-6,LIST[1]-6,LIST[2]+6,LIST[3]+6),AMB)
outline(d,(CHIP[0]-8,CHIP[1]-8,CHIP[2]+8,CHIP[3]+8),AMB,4)
outline(d,(LIST[0]-18,LIST[1]-18,BELT[2]+14,BELT[3]+12),CY)
d.text((LIST[0]-6,LIST[1]-62),'a',font=F(44,True),fill=AMB); d.text((BELT[2]-30,LIST[1]-74),'b',font=F(44,True),fill=CY)
# the folded chip only shows when the list is shut: paste it in faint so the box has something in it
now.paste(Image.blend(now.crop(CHIP),s79.crop(CHIP),0.85),CHIP[:2])

# A: the controls list (and its f1 chip) at the far left edge, its bottom on the log; the log lines step right of it
A=s80.copy()
cp(s79,LIST,A,LIST[:2])                         # the old spot, clean map from the folded shot
feed=s80.crop(FEED)
A.paste(s80.crop((320,FEED[1],360,FEED[3])),(280,FEED[1]))   # map fill where the log lines were
lst=s80.crop(LIST); A.paste(lst,(14,FEED[3]-lst.size[1]))
A.paste(feed.crop((4,0,feed.size[0],feed.size[1])),(14+lst.size[0]+10,FEED[1]))
d=ImageDraw.Draw(A); outline(d,(8,FEED[3]-lst.size[1]-6,14+lst.size[0]+6,FEED[3]+6),AMB)

# B: the whole bottom group slides left together: the belt starts right after the health bars, the list over its left end
B=s79.copy(); dx=BELT[0]-448
B.paste(s79.crop((BELT[2]-dx,BELT[1]-115,BELT[2],BELT[1])),(BELT[2]-dx,BELT[1]))   # map fill at the belt's old right end
B.paste(s79.crop((CAP[2]-dx,CAP[1]-24,CAP[2],CAP[1])),(CAP[2]-dx,CAP[1]))
B.paste(s79.crop((CHIP[0]-4,CHIP[1]-30,CHIP[2]+4,CHIP[1]-5)),(CHIP[0]-4,CHIP[1]))   # the folded chip is under the open list in B
B.paste(s80.crop(BELT),(BELT[0]-dx,BELT[1])); B.paste(s80.crop(CAP),(CAP[0]-dx,CAP[1])); B.paste(s80.crop(LIST),(LIST[0]-dx,LIST[1]))
cp(s79,(LIST[2]-dx,LIST[1],LIST[2],LIST[3]),B,(LIST[2]-dx,LIST[1]))
d=ImageDraw.Draw(B); outline(d,(LIST[0]-dx-14,LIST[1]-14,BELT[2]-dx+12,BELT[3]+10),CY)

W2,H2=960,540; band=50
out=Image.new('RGB',(W2,3*(H2+band)),(17,19,21)); d=ImageDraw.Draw(out)
for i,(img,t,c) in enumerate([(now,'now (after f1)',(230,230,230)),(A,'a: f1 list at the far left, log lines step right',AMB),(B,'b: whole bottom group slides left (belt, f1, list)',CY)]):
  y=i*(H2+band); d.text((14,y+9),t,font=F(26,True),fill=c); out.paste(img.resize((W2,H2),Image.LANCZOS),(0,y+band))
out.save(os.path.join(O,'f1left-question.jpg'),quality=90)
for n,img in (('now',now),('a',A),('b',B)): img.save(os.path.join(O,'f1left-'+n+'-1080.jpg'),quality=88)
print('ok',out.size)
