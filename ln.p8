pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- little necromancer
-- by fred osterero

actor = {} 
particle = {} 
explosion = {} 
fx = {} 
attack = {} 
clouds = {} 
aparticle = {} 
item = {} 

-- make an actor
function make_actor(x, y)
return add(actor,{
x = x,
y = y,
still = false,
state = "idle",
life = 1,
dx = 0,
dy = 0,
targ = 1,
flp = false,
spd = 0.07,
inertia = 0.6,
bounce = 0.4,
chest = false,
w = 0.4,
h = 0.4
})
end

function _init()

is_death=false
--player : little mortimer
pl = make_actor (0,0)
pl.role = "player"
pl.acc = 0.08
pl.cooldown = 0
pl.take_cooldown=0
pl.retry_cooldown=0
pl.potion_nb = 3
--pl animations
pl.idle={f=28,n=4,spd=2}
pl.idlet={f=24,n=1,spd=0}
pl.idled={f=20,n=1,spd=0}
pl.walk={f=16,n=4,spd=6}
pl.walkt={f=24,n=4,spd=7}
pl.walkd={f=20,n=4,spd=7}
pl.invoc={f=2,n=3,spd=6}
pl.invoct={f=8,n=3,spd=6}
pl.invocd={f=5,n=3,spd=6}
pl.fail={f=2,n=1,spd=2}
pl.faild={f=5,n=1,spd=2}
pl.failt={f=8,n=1,spd=2}
pl.death={f=11,n=4,spd=6}
pl.victory={f=16,n=8,spd=8}

--screen control
	scr = {}
	scr.x=0
	scr.y=0
	scr.shake=0
	scr.intensity = 2
	
--cloud factory
	cloud_nb= 24
	
--air particules max
 maxapart = 10
 
--particles timer
	particles_timer = 20
	scene_num = 1
	
--block road counter
	block_road = 10	
--first scene
	load_scene (0)
end

function animation (a)
--actor animation manager
return a.state
end

function anim_actor(a)
	return animator(a[a.state])
end

function animator(a)
-- all things animator
frame=a.f+(time()*a.spd)%a.n
return frame
end

function reinit_position (a)
--reinit position
	a.dx = 0
	a.dy = 0
	a.y = flr(a.y)+0.5
	a.x = flr(a.x)+0.5
end

function controls()

--player cooldown
if pl.cooldown>0
then pl.cooldown -= 1
end
if pl.take_cooldown>0 then
	pl.take_cooldown -= 1
end

-- btn detection
if btn(0) 
then 
	if pl.targ !=0 then	
	reinit_position (pl)
	end
	pl.targ=0 
	pl.dx -= pl.acc
	pl.flp = true
	if (pl.take_cooldown ==0) then
	pl.state="walk"
	end
	make_iexplosion (pl.x,pl.y,1,13,1.6,true)
elseif btn(1) 
then 
	if pl.targ !=1 then
	reinit_position (pl)
	end
	pl.targ=1
	pl.dx += pl.acc 
	pl.flp = false 
	if (pl.take_cooldown ==0) then
	pl.state="walk"
	end
	make_iexplosion (pl.x,pl.y,1,13,1.6,true)
elseif btn(2) 
then 
	if pl.targ !=2 then
	reinit_position (pl)
	end
	pl.targ=2
	pl.dy -= pl.acc
	if pl.take_cooldown ==0 then
	pl.state="walkt"
	end
	make_iexplosion (pl.x,pl.y,1,13,1.6,true)
elseif btn(3) 
then 
	if pl.targ !=3 then
	reinit_position (pl)
	end
	pl.targ=3
	pl.dy += pl.acc	
	if (pl.take_cooldown ==0) then
	pl.state="walkd"
	end
	make_iexplosion (pl.x,pl.y,1,13,1.6,true)
elseif (btnp(1) and btn(2))
or (btnp(1) and btn(3))
or (btnp(3) and btn(0))
or (btnp(0) and btn(2))
then
pl.retry_cooldown =0
reinit_position (pl)
elseif (btnp(5) and not btn(4)
and pl.cooldown==0) 
then 
	reinit_position (pl)
	wakeup_zombi ()
elseif (btn(4) ) 
then 
	pl.state="invocd"
	pl.retry_cooldown += 1

else
	pl.retry_cooldown =0
 reinit_position (pl)

--iddle animation set
if (pl.cooldown==0 and pl.take_cooldown==0) then

if (pl.targ==0 or pl.targ==1)
then pl.state="idle"
elseif (pl.targ==2)
then pl.state="idlet"
elseif (pl.targ==3)
then pl.state="idled"
end 
end 
end
end

function pl_death ()
if pl.life <=0
 then
 paralisis = true
 pl.state="death"
 gameover_timer -=1
end
	
if gameover_timer <=0 then
 for a in all(actor) do
 if (a.role!="player") then
 a.life=0
 end
 end
 zombi_nb = 0
 if gameover==false then
 screenshake (9,5)
 end
 gameover=true    
end
end

function end_level ()
if (flr(pl.x)==flr(endx) 
and flr(pl.y)==flr(endy))
 then
 is_death=false
 paralisis = true
 pl.state="victory"
 end_timer -=1
end
	
if end_timer <=0 
 then
 for a in all(actor) do
 if (a.role!="player") then
 del (actor,a)
 sfx (63,3,4,10) 
 end
 for b in all(item) do
 del (item,b)
 end
 zombi_nb = 0
 end_scene=true
 end 
end
end

function load_scene (num)
if num!=0 then
sfx (61,3,0,11) 
end
screenshake (3,0)
scene_num = num
end_scene = false
--pl inventory
pl.zombi_nb = 0
pl.life = 1
pl.orb_nb = 0
pl.orb_max = 0
pl.zombi_max = 3
pl.state="idle"
pl.targ=1
pl.flp = false 
	
--scene state
is_portal=false
is_open=false
particles_timer=20
gameover_timer =15		
end_timer =30
main_timer =30
endtitle_dw=128
paralisis = false
gameover=false

if (num<5 or num>16) then
scene="menu" else scene="game"
end
		
if num == 0 then
cls (0)
screenshake (0,0)
pal ()
t="/a9h.8/ara.h8h8/aqa.8x6h8.6/ah..hb/ada.h8p6x.p/ah..6h/ada.6hbpd..h..6...b.8...6/aaa.8h....8h.h8.6hbhb..hb/a.a.h8....a8.6x..8a6h..8hb/a?..6hb....hb.8..hb.8..x6hb/a?..8h....6h.hb.6h.hb.8.8a/a?..h8.....8.6h..8.6h.hbx/a.a.6hb....hb.8..hb.8.6h8/aaa.8h....6h.hb.6h.hb.8x/aaa.h8...b.8.6h..8.6h.a8/a[..b/ak..6hb.8h.hb.8..hb.8..h8/a-..8h6hb/ak..8h6h8.6h.h8.6hbhb.dh8/a~..h8h8hb/aj..h8h8hb.8.6hb.8h6h..6x/a~..6h8h8h/aj..dqdqda.q.pda.qdpd..pd/a-..8xdh8h..6...6/ag..6.....6/af..hb....h...h...h/a!..h8.6h8..hb..hb.6h6h.h8..hbh8.8...8hb.8.8h..8...8..hbhb/a5..6hbp6hb.8hb.8h8.8h8.8hb.6h8h8h8.6h8hbh8h8.6h8h6h8.6h8h/a6..8h..8h.x6hbx6x.h8hbx6hb.8x6x6hbpda8h6hfhb.fhf.fh8.8h8/a6..h8..h8.8.8a6pd.6xda8p6h.h8.8.8h..8h8.8h6h.hda6h6x.hfq/a6..6hb.6hbhbx.hb...8..hb.8.6hbhbh8.6x6hbh8.8.8...8.f.6h/a8..8h..8h6h8.6h...hb.6h.ab.8h6h6hb.8.8h6hbhbhb..h8h..8/a8..h8..hf.8x..8h..6h..8h.h.h8.8.8h6hbh8.8h6h6hb.6hf..hb/a7..6hb.6h.a8..a8...8..a8.6.6hbhbh8.8h6hbh8.8p6h.p6h..6h/a8..8h..f..h8..h8..hb..h8hb.8h6h6hbh8h8h6hbhb.8h..8h..8/a8..h8.6h8.dh8.dh8h6h..dh8a.h8.8.8hdh8h8.8h6h.a8hba8h.hb/a7..6hb.8hb.6x..6hf.8...6x..6hbhbh8.dxdx.h8.8..h8a.hf.6h/a7..pda.qda.pd..p6a.q...pd..pdadadq..d.d.dq.q..dx..da.pd/a)..p/a4..d/abv.d</a#..6hb/a%..p+?/a!..6h8/a^..dq?c/as..=/bf.l=l...h8hb/a%..pd<o.../bf.@y...~/an..lc.8$hh/a%..dq??..6/be.y@yq...lx/bf.@y@a.9hj86/a@..dqdqd<?c..31@y@y@y@eqda..~pd/bf.@y@al88hbb...hh/a5..dqdqd<??...+3{3g/bd.qd...cqdqd7/bd.y@[m~$h8hh...b8/a4..dqdq?????c..p{3{3/bd.dq...l/bd.dq{3{3{3{.k8hb8..66h.....b/ax..qdq+?????o...p{3/be.dq...ldqdqdqd3{3{3{3c*h86b8..b8....66h/aw..dq+/ag.?o...3{/be.qda..~pdqdqdq+3{3{3{.k8h$hbb.hh8~3..66h/av..qdqdq/af.?o..+3/be.dqd...cqdqdqdq{3{3{3c*h868hhbfhh2{3g.b8/av..dqdqdqd<????....qd..pdqdq.....ldqdqdqd3{3{3{.kb..h8h8yf.{3{a86h/av..q+???oqd<????..{a.2{3....~3g..~pdqdqdq+3{3{3cl.....8x@y{3{3ghh8/av..d<?????sd<??oa.x]ag2~3~3{3@y...cpdqdqdq{3{m..~.....h8y@y{3{366h/av..pd</ah.?o.6y..fx{3#a@y@a..@alhb/ai..h8.c.....x@yh4{3{3/ax..dqd.....???c@y3gq..x6y....pdqdl=6h8h8h86h8h8hblc....6yf8h8{3{3#a/af..h/an..qda/af..??o+3{3{3da...qdqdqdlc..8h8h8hb8h8h8...=l...@7h8{7h4{yf/af..8/an..dqd/ag..??o.3{3g/be.qdac.+3.6h8h8hh8h8.+(y..l..xf8$2g8}y@yf....6hb/an..dq/ah..?sda.+/be.qdq~p{3dqd/ai..+3{31@al.6ybj86h8@yf.....h8hb/an..da/ah..dqda....pdqda....c/be.qdq/bd.{3{m~..@ihjh8hz@ah8h8h886h/an..pd/ah..pdqd.8h8.....dq.abcp/bd.dqd/bd.3{m..c..@hh8h8$yf68hbj8hb8/ao..pd/af..d.qda.hh8.qdq...pdhh=p/bd.dqd3{3{3{..l=...x@hh8$x@y.j8hbj8hhb/ao..pd.....q.dqd.66hbdqo.wadq.hh=/ag..dq+3{m..da~.c...x@h8h@y@y.h8h$h86h/ap..pd.qdqdapd<?c86.q+?~udpda?chcqdapdqd.....daqd.$.c...x@y@y@yf...868hb8/aq..pd.qdqd.q+??c8.d<??gq?sd,o6ld.....pdqda..d.p.l~/af..@y@y/af..$h8hhb/ap..dqd.qdapdq??oh.q/af.?oq??._.pd.{ufpdqpy{q.qp.l=/ap..8h86h/ap..qdqd...dqdq??6./ah.?dqoald~s.3wagqd3e2ga+ca~l~/ap..8hbb/ao..q/bf.dq?c~/ah.?sd..~p.oad3u3dq+u[<jpjd.cj~/ao..h86h/am..dqdqdqo/bd.qd<o.~?o.????da.hbcq.dqdqd<?????&`^p.lcl/ao..6hhb/am..qd.dq+?oqdqdqdq+?6.~?????oq.h8hldq..qd</af.?`b.d.cl=/ap..hb/an..da..+???/bd.dq?c8..,???s.h8h8.ldqd.q/ag.?&pdq.6b.c/ao..6/ao..p....???sdqdqdqd<ohb/ai..8h..l....q?c..?&j....cj$.c/a5..a.tf,??oqdq+?dq+?6.@ye2{auy@a8...lhbb.p????j.66j~6^.~/a6..dt@yf,??dqdq??dq+?.xva.2...xfh....lhb8/af..66$bl.^^.c....p@y@i/aw..!y@y~??sdqd<?sdq+?6ap{~a3{mx/af..lhh8.qdqdhb^.c^^#^.c...0y@y@y@/au..t@a6a??oqdq+??sdq+?p{3cg+q+m/af..=...6....e....$'3^^.c../bd.y@i/as..pyf..,??dqdq??oqdq+c3{3c3ga+q.....lh8hb.qda.8h^b6^{%j~..p/bd.@y@i/ar..ppy..~???dqdq??oqdqd+3{pb3dp{q....~6h86hb..h8h8j~6^^^.c..^@y@y@y8x@....j/an..a!y..???sdqd<??oqdqpc3ci+3.3ga...lh8hh8hb.8h8h8j....~..6^^@y@y@h4w@..6^j/an..a.p~??cdq+sd<??oqdam+3c3{a.3g...c8h86hbh.h6h8h86blclc..^^j8x@yjb4xb..6b/ao..qdq??o.dq?s+???oqp{p{m+3ga+3d.~6h8hh86b..j6h8h,`b6bl.6^^8h4w@%hb8i/av..q+?..d<oq+????c..3c.+3gp{3..c8hb8h86^^bh8h8.<`^.~..^^j8h4x@8hh@/aw..q+c.p+?dq+???oxp{pda+3...6a.c86h8h8...8h8hbd<o.l..$^^8hh8x@86i/a2..q??dq+??c..mdqda+a.@yf~p..6h8hbq.h8h8.....c..6^^j8h8hy@y@/a2..d<??.q+?o,d+....pga....cpdm6h8pdq.h8h.qda~....^^^h8h80y@y@/a1..pd<?cdq+?~s.d3{3c...,oa.aq+/ak..c..l....$^^^h8hy@yby@/a1..q+?o.dq+?..q{m+3dq.~c.coa.h8p.auuuuual=lc.....$^^^^^@y@..yb/a1..q??..dq+cf+3{p{3da..~~??s....dtuuuue~/aj../af.^y@/a6..?c.....xp{m.p{3d6yf~..~c8hbp/ag..c....6b/ag..$^@y@/a@..@a3{a.3{q.@y.~l=.c...d3{3{3cl....$^b/ag..$^@yb/a!..xf+3d6a3gax@y...~ldqdq+3{3{m~.....$/ai..$z@/a!..x@yp{q.f+3gax@a...~pdqd3{3{3{.c/av..j/a5..6y@a...x....6yf....cqdqd3{3{3cl/au..6^j/a5..@yftud6ypuq.@yf..~pdqdqd3{3{m~/av..6b/a6..@ypuq.@aueq.@yf..c/be.qda~/ai1."
bit6to8(t,24576) 
scenex = 0
sceney = 0	
music (3)
end
	
if num == 1 then
--main menu init
tiles = {"start game ","controls","credits"}
numberoftiles = 3
selectedtile = 1
clcol1 = 14
clcol2 = 2
scenex = 16
sceney = 0	
end
	
if num == 2 then
scenex = 16
sceney = 0	
end
	
if num == 3 then
scenex = 16
sceney = 0	
end
	
if num == 4 then
scenex = 16
sceney = 0	
music (-1,18000)
end

if num == 5 then
scenex = 48    
sceney = 0	
track=12
end
	
if num == 6 then
scenex = 64
sceney = 0
end
	
if num == 7 then
scenex = 80
sceney = 0
end
	
if num == 8 then
clcol1 = 12
clcol2 = 1
scenex = 96
sceney = 0
track=0
end
	
if num == 9 then
scenex = 112
sceney = 0
end
	
if num == 10 then
scenex = 0
sceney = 16
end
	
if num == 11 then
clcol1 = 8
clcol2 = 2
scenex = 16
sceney = 16
track=7
end
	
if num == 12 then
scenex = 32
sceney = 16
end
	
if num == 13 then
scenex = 48
sceney = 16
end
	
if num == 14 then
clcol1 = 15
clcol2 = 12
scenex = 64
sceney = 16
track=3
end
	
if num == 15 then
scenex = 80
sceney = 16
end
	
if num == 16 then
scenex = 96
sceney = 16
end
	
if num == 17 then
scenex = 32
sceney = 0
end
	
level_objects (scenex,sceney)	
if num>4 then
music (track,3000)
end
end


-->8
-- collisions and level settings
-- some original code by zep 

-- is tile taken ?
function is_taken (x,y)
for a in all(actor) do
if (flr(a.x)==flr(x) 
and flr(a.y)==flr(y))
then return true
end
end
end

-- is tile with comrade ?
function is_same (a,x,y)
for b in all(actor) do
if (b.role==a.role 
or b.role=="portal" 
or b.role=="obstacle") then
if (flr(b.x)==flr(x) 
and flr(b.y)==flr(y))
then return true
end
end
end
end

-- is tile with enemy ?
function is_enemy (x,y)
for a in all(actor) do
if (a.role=="enemy") then
if (flr(a.x)==flr(x) 
and flr(a.y)==flr(y))
then return true
end
end
end
end

function solid(x, y)
-- grab the cell value
val=mget(x+scenex, y+sceney) 
-- check if flag 1 is set 
return fget(val, 1)
end

-- solid_area
function solid_area(x,y,w,h)
return 
solid(x-w,y-h) or
solid(x+w,y-h) or
solid(x-w,y+h) or
solid(x+w,y+h)
end

function solid_actor(a, dx, dy)
for a2 in all(actor) do
if (a2.subrole!="fireball") 
then	
if a2 != a then
local x=(a.x+dx) - a2.x
local y=(a.y+dy) - a2.y
if ((abs(x) < (a.w+a2.w)) and
(abs(y) < (a.h+a2.h)))
then    
    -- moving together?
if (dx != 0 and abs(x) <
abs(a.x-a2.x)) then
v=a.dx + a2.dy
a.dx = v/2
if (a2.still== false
and a.role=="player") then
a2.dx = v/2
end
return true 
end
    
if (dy != 0 and abs(y) <
abs(a.y-a2.y)) then
v=a.dy + a2.dy
a.dy=v/2
if (a2.still == false
and a.role=="player") then
a2.dy=v/2
end
return true 
end
    
--return true
end
end
end
end
return false
end
 
-- checks both walls and actors
function solid_a(a, dx, dy)
if solid_area(a.x+dx,a.y+dy,
a.w,a.h) then    
return true end
return solid_actor(a, dx, dy)  
end

function move_actor(a)
-- only move actor along x
-- if the resulting position
-- will not overlap with a wall
if not solid_a(a, a.dx, 0) 
then
a.x += a.dx
else 
a.dx *= -a.bounce
end
-- ditto for y
if not solid_a(a, 0, a.dy) 
then
a.y += a.dy
else 
a.dy *= -a.bounce
end   
a.dx *= a.inertia
a.dy *= a.inertia
 
--move the zombis and enemies
move_enemy () 
end

--replace tiles by items/actors
function level_objects (a,b)
for x=0,15 do
for y=0,15 do
 -- player
if mget(x+a, y+b) == 16 then
pl.x = x+0.5
pl.y = y+0.5
mset (x+a,y+b,146)  
end
-- portal 
if mget(x+a, y+b) == 185 then
create_portal (x,y)
mset (x+a,y+b,146)  
end
--end area
if mget(x+a, y+b) == 163 then
endx = x
endy = y
mset (x+a,y+b,146)  
end
-- skull
if mget(x+a, y+b) == 179 then
make_item (a,"skull",179,x+0.5,y+0.5,10)
mset (x+a,y+b,146) 
end
-- potion
if mget(x+a, y+b) == 182 then
if (is_death==false) then
make_item (a,"potion",182,x+0.5,y+0.5,14)
else 
for a in all(item) do
if (a.name=="potion") then
a.y = (flr (a.y))+0.5
end
end
end
mset (x+a,y+b,146) 
end
-- worm
if mget(x+a, y+b) == 112 then
create_worm (x,y)
mset (x+a,y+b,146) 
end
-- sanctuary
if mget(x+a, y+b) == 186 then
create_sanctuary (x,y)
mset (x+a,y+b,146)  
end
-- block
if mget(x+a, y+b) == 164 then
create_block (x,y)
mset (x+a,y+b,146)  
end
-- specter
if mget(x+a, y+b) == 80 then
create_specter (x,y)
mset (x+a,y+b,146) 
end
-- flame
if mget(x+a, y+b) == 166 then
create_flame (x,y)
mset (x+a,y+b,167) 
end
-- fountain
if mget(x+a, y+b) == 86 then
create_fountain (x,y)
mset (x+a,y+b,88) 
end
-- eye
if mget(x+a, y+b) == 67 then
create_eye (x,y)
mset (x+a,y+b,146) 
end
-- gargoyle
if mget(x+a, y+b) == 117 then
create_gargoyle (x,y)
mset (x+a,y+b,246) 
end
end
end
end

	
-->8
--zombis & enemies behaviour

--try a zombi invocation
function wakeup_zombi ()	
--define pl targetted tile
	if (pl.targ == 0) 
	then tx=pl.x-1 ty=pl.y 
 elseif (pl.targ == 1) 
 then tx=pl.x+1 ty=pl.y
 elseif (pl.targ == 2) 
 then tx=pl.x ty=pl.y-1
 elseif (pl.targ == 3) 
 then tx=pl.x ty=pl.y+1
 end
--check if the tile is free
--check is zombi number is fine
if (solid(tx,ty)==false
	and pl.zombi_nb>0 
	and not is_taken (tx,ty)==true)
	then
	
if (pl.targ == 0 or pl.targ == 1) 
 then pl.state="invoc"
 elseif (pl.targ == 2) 
 then pl.state="invoct"
 elseif (pl.targ == 3) 
 then pl.state="invocd"
end
 
--save player position
temp_targ=pl.targ
temp_flp=pl.flp 
pl.cooldown =14
sfx (61,3,0,11) 
--	invocation fx 1
ifx1 = make_actor (tx,ty)
ifx1.role = "fx"
ifx1.subrole = "invocation1"
ifx1.still = true
ifx1.chest = true
ifx1.item = "skull"
ifx1.itcolor = 10
ifx1.itsprite = 179
ifx1.idle={f=39,n=4,spd=8}
	
-- invocation fx 2
ifx2 = make_fx (tx,ty)
ifx2.idle={f=35,n=4,spd=12}	
make_iparticles (tx,ty,8,10,9,26)
	
else	
	if (pl.targ == 0 or pl.targ == 1) 
 then pl.state="fail"
 elseif (pl.targ == 2) 
 then pl.state="failt"
 elseif (pl.targ == 3) 
 then pl.state="faild"
 end
--fail to create a zombi
 sfx (62,3,8,1)
 make_iexplosion (tx,ty,8,6,1.6,true)
	end 	
end
	
function create_zombi () 	
	--create zombi actor
	if (pl.zombi_nb>0) then
	pl.zombi_nb -= 1
	zb ={}
 zb = make_actor (tx,ty) 
 zb.role = "zombi"
 zb.flp= temp_flp
 zb.targ = temp_targ
 zb.orv=0
 zb.head = 32
 zb.headt = 34
 zb.headd = 33
 zb.chest = true
 zb.item = "skull"
 zb.itcolor = 10
 zb.itsprite = 179
 zb.idle={f=50,n=1,spd=0}
 zb.idlet={f=60,n=1,spd=0}
 zb.idled={f=55,n=1,spd=0}
 zb.walk={f=50,n=4,spd=7}
 zb.walkt={f=60,n=4,spd=7}
 zb.walkd={f=55,n=4,spd=7}
 zb.attack={f=49,n=2,spd=8}
 zb.attackt={f=59,n=2,spd=8}
 zb.attackd={f=54,n=2,spd=8}
 end
end 

function move_block ()
for a in all(actor) do
if (a.subrole=="block") then
if (a.x!=flr(a.x)+0.5 
or a.y!=flr(a.y)+0.5) then
if (block_road!=0) then
block_road-=1
else 
block_road = 10 
reinit_position (a)
sfx (62,3,7,1)
end
end
end
end
end

function move_enemy ()
 for a in all(actor) do
	if (a.role=="zombi" 
	or a.subrole=="specter" 
	or a.subrole=="eye"
	or (a.subrole=="gargoyle" and a.still==false)) 
	then
 --define z targetted tile
	if (a.targ == 0) 
	then a.ztx=a.x-0.6 a.zty=a.y 
 elseif (a.targ == 1) 
 then a.ztx=a.x+0.6 a.zty=a.y
 elseif (a.targ == 2) 
 then a.ztx=a.x a.zty=a.y-0.6
 elseif (a.targ == 3) 
 then a.ztx=a.x a.zty=a.y+0.6
 end
 -- move, attack or change direction
	if (not is_taken (a.ztx,a.zty)
	or is_same (a,a.ztx,a.zty))
 then
	deplacement (a)
else

--attack 
reinit_position (a)

for b in all(actor) do
if (flr(b.x)==flr(a.ztx)
	and flr(b.y)==flr(a.zty)
	and b.role!="zombi" 
	and b.role!="obstacle"
	and b.subrole!="invocation1"
	)
 then
if (a.targ == 0) then 
a.flp = true
a.state="attack"
elseif (a.targ==1) 
then 
a.flp = false
a.state="attack" 
elseif (a.targ == 2)
then a.state="attackt"
elseif (a.targ == 3)
then a.state="attackd"
end
if (particles_timer==10) then
sfx (61,3,17,7)
end
anim_attack (a.ztx,a.zty,a.targ,a.flp)
 a.spd = 0
 b.spd = 0
 b.life -= 10
 a.spd = 0.07
end
end
end
end
end
end

function anim_attack (x,y,targ,flp)
--	attack fx
zafx = make_attack (x,y,targ,flp)
zafx.flp = flp
zafx.state="idle"
zafx.idle={f=43,n=3,spd=8}
end

function take_direction (a,x,y,targ)
check_direction (a,x,y)
reinit_position (a)
--zombi choose direction
if (a.targ == 0) then
if (a.tile2==true) then
a.targ=2 
elseif (a.tile3==true) then
a.targ=3 
elseif (a.tile1==true) then
a.targ=1
end

elseif (a.targ == 1) then
if (a.tile3==true) then
a.targ=3 
elseif (a.tile2==true) then
a.targ=2 
elseif (a.tile0==true) then
a.targ=0
end

elseif (a.targ == 2) then
if (a.tile1==true) then
a.targ=1 
elseif (a.tile0==true) then
a.targ=0 
elseif (a.tile3==true) then
a.targ=3
end

elseif (a.targ == 3) then
if (a.tile0==true) then
a.targ=0 
elseif (a.tile1==true) then
a.targ=1 
elseif (a.tile2==true) then
a.targ=2
end

end
end

function check_direction (a,x,y)
--reinit check
a.tile0 = true
a.tile1 = true
a.tile2 = true
a.tile3 = true
--zombi check empty tiles
if (solid_a(a,-1, 0) 
and not is_taken (x-1,y) or is_same (a,x-1,y))
then a.tile0=false
end
if (solid_a(a,1, 0) 
and not is_taken (x+1,y) or is_same (a,x+1,y)) 
then a.tile1=false
end
if (solid_a(a,0, -1) 
and not is_taken (x,y-1) or is_same (a,x,y-1))
then a.tile2=false
end
if (solid_a(a,0, 1) 
and not is_taken (x,y+1) or is_same (a,x,y+1))
then a.tile3=false
end
end

--demon worm 
function move_worm ()
for a in all(actor) do
	if (a.subrole=="worm") 
	then
	--fireball cooldown
	if (a.fireball_cooldown>0)
	then a.fireball_cooldown -= 1
	end
	if (pl.x>=a.x) then
	a.flp=true
	a.firestarter=-1
	a.fireballx = 0.2
	else 
	a.flp=false
	a.firestarter=1
	a.fireballx = -1.2
	end
	for b in all(actor) do
	if (b.role == "zombi"
	or b.role == "player" 
	or b.subrole=="invocation1") then
	if (flr(b.y)==flr(a.y) 
	and (a.x-b.x)*a.firestarter>0
	and a.fireball_cooldown<=0) then
	a.state="attack"
	a.fireball_cooldown=30
	create_fireball 
	(a.x+a.fireballx,a.y-0.8,a.flp)
	end
	if (a.fireball_cooldown<20) then
	a.state="idle"
	end
	end
	end
	end
end
end

function move_fireball ()
for a in all(actor) do
if (a.subrole=="fireball") 
then	
if (a.flp==true) then
if not solid_a(a,0.4,0.4) 
then
a.x += 0.2  
else  
fireball_attack (a.x+0.8,a.y)  
a.life=0
end
else 
if not solid_a(a,-0.4,0.4) 
then
a.x -= 0.2  
else 
fireball_attack (a.x-0.8,a.y)
a.life=0
end
end
end
end
end

function fireball_attack (x,y)
anim_attack (x,y,0,true)
for b in all(actor) do
if (b.role != "enemy"
and b.role!="obstacle") 
then
if ((flr(b.x)==flr(x)
and (flr(b.y-0.5)==flr(y)
or (flr(b.y+0.2)==flr(y))
)))
then
b.life -= 130
end
end
end
end

--deplacement
function deplacement (a)
if (a.targ == 0) then
if not solid_a(a, a.dx, 0) 
then
a.state="walk"
a.flp = true
a.dx = -(a.spd)
else
take_direction (a,a.x,a.y,a.targ) 
end
	
elseif (a.targ == 1) then
if not solid_a(a, a.dx, 0) 
then
a.state="walk"
a.flp = false
a.dx = a.spd
else 
take_direction (a,a.x,a.y,a.targ) 
end
elseif (a.targ == 2) then
if not solid_a(a, 0, a.dy) 
then
a.state="walkt"
a.dy = -(a.spd)
else
take_direction (a,a.x,a.y,a.targ)  
end
	
elseif (a.targ == 3) then
if not solid_a(a, 0, a.dy)  
then
a.state="walkd"
a.dy = a.spd
else 
take_direction (a,a.x,a.y,a.targ) 
end	
end
--eye behaviour
for b in all(actor) do
if (b.subrole == "eye") then
if (flr(b.x)==flr(pl.x)) 
or (flr(b.y)==flr(pl.y)) then		
if (flr(b.x)==flr(pl.x) 
and (flr(b.y)<=flr(pl.y))) then
b.targ=3
elseif
(flr(b.x)==flr(pl.x) 
and (flr(b.y)>=flr(pl.y))) then
b.targ=2
elseif (flr(b.x)<=flr(pl.x) 
and (flr(b.y)==flr(pl.y))) then
b.targ=1
elseif (flr(b.x)>=flr(pl.x) 
and (flr(b.y)==flr(pl.y))) then
b.targ=0
end
if (targetlock==false) then
reinit_position (b)
end
b.spd=0.13
targetlock=true
else
b.spd = 0.07
b.targetlock=false
end
end
end
end

-->8
-- hud,enemies & items creation

--enemies

function enemy_death ()
for a in all(actor) do
if (a.role!="player" and a.life<=0) then
if (a.chest==true) then
--fx stop
if (a.subrole=="invocation1") then
del (fx,ifx2)
end
make_item (a,a.item,a.itsprite,a.x,a.y,a.itcolor)
end
sfx (61,3,17,7)
del (actor,a)
make_iexplosion (a.x,a.y,8,a.color,3,true)
if (pl.life<=0) then
sfx (63,3,0,4)
enemy_extinction=true
end
end
end
end


--create enemies
function create_sanctuary (x,y)
	ensa ={}
 ensa = make_actor (x+0.5,y+0.5) 
 ensa.role = "enemy"
 ensa.subrole= "sanctuary"
 ensa.still=true
 ensa.life = 1400
 ensa.color = 6
 ensa.head = 170
 ensa.idle={f=186,n=1,spd=0}
 ensa.chest = true
 ensa.item = "orb"
 ensa.itcolor = 12
 ensa.itsprite = 177
 pl.orb_max +=1
end

function create_block (x,y)
	obbl ={}
 obbl = make_actor (x+0.5,y+0.5) 
 obbl.role = "obstacle"
 obbl.subrole= "block"
 obbl.color = 6
 obbl.inertia = 0.87
 obbl.w  = 0.4
 obbl.h  = 0.4
 obbl.idle={f=164,n=1,spd=0}
 obbl.chest = false
end

function create_worm (x,y)
	enwo ={}
 enwo = make_actor (x+0.5,y+0.5) 
 enwo.role = "enemy"
 enwo.subrole= "worm"
 enwo.still=true
 enwo.life = 1400
 enwo.fireball_cooldown = 0
 enwo.color = 8
 enwo.head = 96
 enwo.idle={f=112,n=2,spd=2}
 enwo.attack={f=112,n=5,spd=10}
 enwo.chest = false
end

function create_specter (x,y)
	ensp ={}
 ensp = make_actor (x+0.5,y+0.5) 
 ensp.role = "enemy"
 ensp.subrole= "specter"
 ensp.life=1400
 ensp.color = 15
	ensp.head = 64
 ensp.headt = 66
 ensp.headd = 65
 ensp.idle={f=80,n=1,spd=0}
 ensp.walk={f=80,n=2,spd=5}
 ensp.walkd={f=82,n=2,spd=5}
 ensp.walkt={f=84,n=2,spd=5}
 ensp.attack={f=80,n=2,spd=8}
 ensp.attackt={f=82,n=2,spd=8}
 ensp.attackd={f=84,n=2,spd=8}
end

function create_eye (x,y)
	eney ={}
 eney = make_actor (x+0.5,y+0.5) 
 eney.role = "enemy"
 eney.subrole= "eye"
 eney.life=700
 eney.color = 8
 eney.frame = 71
 eney.targetlock=false
 eney.idle={f=67,n=4,spd=5}
 eney.walk={f=67,n=4,spd=5}
 eney.walkd={f=70,n=1,spd=5}
 eney.walkt={f=70,n=1,spd=5}
 eney.attack={f=67,n=4,spd=5}
 eney.attackt={f=67,n=4,spd=5}
 eney.attackd={f=67,n=4,spd=5}
end

function create_gargoyle (x,y)
	enga ={}
 enga = make_actor (x+0.5,y+0.5) 
 enga.role = "obstacle"
 enga.subrole= "gargoyle"
	enga.life=300
 enga.still=true
 enga.color = 8
 enga.frame = 71
 enga.spd=0.1
 enga.head = 101
 enga.idle={f=117,n=1,spd=5}
 enga.walk={f=118,n=2,spd=5}
 enga.walkd={f=120,n=2,spd=5}
 enga.walkt={f=122,n=2,spd=5}
 enga.attack={f=118,n=2,spd=7}
 enga.attackt={f=120,n=2,spd=7}
 enga.attackd={f=122,n=2,spd=7}
end

function create_fireball (x,y,flp)
	enfb ={}
 enfb = make_actor (x+0.5,y+0.5) 
 enfb.role = "enemy"
 enfb.subrole= "fireball"
 enfb.life = 5000
 enfb.w = 0.1
 enfb.h = 0.3
 enfb.color = 9
 enfb.flp = flp
 enfb.idle={f=97,n=2,spd=4}
end

function sanctuary_particles ()
for a in all (actor) do
	if (a.subrole=="sanctuary" 
	and particles_timer==20) then
	make_iparticles (a.x,a.y-0.8,2,12,7,18)
	end
end
particles_timer -=1
if (particles_timer <= 0) then
particles_timer=20
end
end

function create_portal (x,y) 
	is_portal=true
 port ={}
 port = make_actor (x+0.5,y+0.5) 
 port.role = "portal"
 port.still=true
 port.w = 0.4
 port.h = 0.4
 port.color = 12
 port.idle={f=185,n=1,spd=0}
 port.chest = false
end

function open_portal ()
	if (pl.orb_nb >=pl.orb_max 
	and pl.orb_max > 0 
	and is_open==false) then
	is_open=true
	sfx (62,3,0,7)
	make_iexplosion (port.x,port.y,4,12,2.5,true)
	make_iparticles (port.x,port.y,4,12,7,32)
	--gargoyle waking
	for a in all(actor) do
	if (a.subrole=="gargoyle") 
	then
	a.role="enemy"
	a.still=false
	a.head = 102
 a.headt = 106
 a.headd = 104
	end
	end
	del (actor,port)
	end
end

--items
function make_item (e,n,s,x,y,c)
 a={}
 a.x = x
 a.y = y
 a.name = n
 a.sprite= s
 a.color = c
 a.state="idle"
	a.idle={f=a.sprite,n=2,spd=6}
	a.shadowy = y
	a.shadowsy = (a.shadowy * 8) -4
	add (item,a)
end

function draw_item(a)
 a.sx = (a.x * 8)-4
 a.sy = (a.y * 8)-4
	spr (anim_actor (a),a.sx,a.sy-3,1,1,a.flp,false)
end

function move_item ()
	for a in all(item) do
	if (particles_timer>=11) then
	a.y -= 0.04	
	else
	a.y += 0.04	
	end
	end
end

function take_item ()
for a in all(item) do
	if (flr(pl.x)==flr(a.x) and flr(pl.y)==flr(a.y)) then
	if (a.name=="orb") then
	pl.orb_nb += 1
	elseif (a.name=="skull") then
	pl.zombi_nb +=1
	elseif (a.name=="potion") then
	pl.potion_nb +=1
	end	
	pl.take_cooldown=10
 pl.state="invocd"
 sfx (61,3,13,4)
	make_iexplosion (a.x+0.5,a.y-0.9,1,a.color,3,false)
	del (item,a)
 end
 end
end

--hud
function draw_hud ()
--orbs
spr (177,4,4,1,1)
highlighttext (pl.orb_nb.."/"..pl.orb_max,13,4,12)
--skulls
for i=1,pl.zombi_max do
spr (181,28+(i*8),2,1,1)
end
for i=1,(pl.zombi_nb) do
spr (179,28+(i*8),2,1,1)
end
--potion
spr (182,74,2,1,1)
highlighttext (pl.potion_nb,83,4,6)
end







-->8
--fxs

-- text fx
function highlighttext (f,x,y,col)
	print (f,x,y+1,0)
	print (f,x+1,y,0)
	print (f,x,y-1,0)
	print (f,x-1,y,0)
	print (f,x,y,col)
end

function highlightsprite (sx,sy,sw,sh,dx,dy,w,h)
	pal (8,0)
	sspr (sx,sy,sw,sh,dx,dy+1,w,h)
	sspr (sx,sy,sw,sh,dx+1,dy,w,h)
	sspr (sx,sy,sw,sh,dx,dy-1,w,h)
	sspr (sx,sy,sw,sh,dx-1,dy,w,h)
	pal (8,8)
	sspr (sx,sy,sw,sh,dx,dy,w,h)
end

--flame fx
function create_flame (x,y)
	flfx = make_actor (x+0.5,y+0.5)
	flfx.role = "obstacle"
	flfx.still = true
	flfx.idle={f=166,n=3,spd=10}
end

--fountain fx
function create_fountain (x,y)
	flfx = make_actor (x+0.5,y+0.5)
	flfx.role = "obstacle"
	flfx.idle={f=86,n=3,spd=6}
end

--make a fx
function make_fx(x, y)
 a={}
 a.x = x
 a.y = y
 a.state="idle"
 a.dx = 0
 a.dy = 0
	a.acc= 0.01 
 add(fx,a) 
 return a
end

--draw fxs
function draw_fx(a)
a.sx = (a.x * 8) - 4
a.sy = (a.y * 8) - 4 
spr (anim_actor (a),a.sx,a.sy,1,1,a.flp,false)
end

function move_ifx ()
	for ifx2 in all(fx) do
	if (ifx2.subrole!="wing") then
	ifx2.dy += ifx2.acc
	ifx2.y -= ifx2.dy
	else
	spr (a.head,a.sx,
	a.hat,1,1,a.flp,false)	
	end
	end
end

--make a attack
function make_attack(x,y,targ,flp)
 a={}
 if (targ == 0) then
 a.x = x+0.2
 a.y = y-0.1
 elseif (targ == 1) then
 a.x = x-0.2
 a.y = y-0.1
 elseif (targ == 2) then
 a.x = x
 a.y = y-0.7
 elseif (targ == 3) then
	a.x = x
 a.y = y-0.6
 end
 a.dx = 0
 a.dy = 0
 a.flp = flp
	a.cooldown = 1

 add(attack,a)
 
	return a
end

function draw_attack(a)
 a.sx = (a.x * 8) - 4
 a.sy = (a.y * 8) - 4
 --fx-- 
spr (anim_actor (a),a.sx,a.sy,1,1,a.flp,false)
a.cooldown -= 1
	if (a.cooldown<= 0) then
	del (attack,a)	
	end
end

function make_iparticles (x,y,nb,c1,c2,f)
--create invocation particles
 	while (nb> 0 ) do
 	ipart = {}
 	ipart.x = ((x* 8))+(flr((rnd(6)-3)))
 	ipart.y = ((y* 8))+(flr((rnd(6)-3)))
 	ipart.col = c1
 	ipart.col2 = c2
 	ipart.dx = 0
 	ipart.dy = (flr(rnd (3)) -4)/6
 	ipart.f = 1
 	ipart.maxf = f
 	add (particle,ipart)
 	nb -=1
 	end	
end

function draw_iparticles ()	
	for ipart in all(particle) do
	if (ipart.f == ipart.maxf-2) then
	ipart.col = ipart.col2
	end
	pset (ipart.x,ipart.y,ipart.col)
	ipart.x += ipart.dx
	ipart.y += ipart.dy
	ipart.f += 1
	if (ipart.f > ipart.maxf) then
	del (particle,ipart)	
	end
	end
end

function make_iexplosion (x,y,nb,c,r,multiple)
--create smoke
	while (nb> 0) do
	iexplo = {}
	if (multiple==true) then
	iexplo.x = ((x* 8))+(flr((rnd(6)-3)))
 iexplo.y = ((y* 8))+(flr((rnd(6)-3)))
	else
	iexplo.x = (x* 8)-4
 iexplo.y = (y* 8)-4
 end
	iexplo.r = r
	iexplo.c = c
	add (explosion,iexplo)
	nb -= 1
	end
end

function draw_iexplosions ()
	for iexplo in all (explosion) do
	circfill (iexplo.x,iexplo.y,iexplo.r,iexplo.c)
	iexplo.r -=0.4
	if (iexplo.r <= 0) then del (explosion,iexplo)
	end
end
end

--create clouds
function make_clouds (cy)
	while (cloud_nb> 0) do
	cloud = {}
	if (cloud_nb>12) 
	then
	cloud.x = flr(rnd(128))
	else
	cloud.x = flr(rnd(110)+140)
	end
 cloud.y = flr(rnd(5)+cy)
	cloud.r = flr(rnd(8)+2)
	add (clouds,cloud)	
	cloud_nb-= 1
	end
end

function draw_clouds ()
	for cloud in all (clouds) do
	circfill (cloud.x,cloud.y,cloud.r,clcol1)
	circfill (cloud.x-2,cloud.y+1,cloud.r,clcol2)
	cloud.x -=0.4
	if (cloud.x <= -cloud.r*2) 
	then del (clouds,cloud)
	cloud_nb+=1	
	end
end
end

--create air particles
function make_aparticles (nb) 
 	if (maxapart>0) then
 	while (nb> 0 ) do
 	apart = {}
 	apart.x = flr(rnd (90))+128
 	apart.y = flr(rnd (90))+32
 	apart.col = 2
 	apart.dx = 1
 	apart.dy = rnd (2)-1
 	add (aparticle,apart)
 	nb-= 1
 	maxapart-= 1
 	end
 	end
end

function draw_aparticles ()	
	for apart in all(aparticle) do
	pset (apart.x,apart.y,apart.col)
	apart.x -= apart.dx
	apart.y += apart.dy
	if (apart.x < 0 or apart.y>128 or apart.y<0) then
	del (aparticle,apart)	
	maxapart += 1
	end
	end
end

--screenshake
function screenshake (nb,intensity)
scr.shake = nb
scr.intensity = intensity
end

function camera_pos ()
if (scr.shake > 0) then
scr.x = (rnd(2)-1)*scr.intensity
scr.y = (rnd(2)-1)*scr.intensity
scr.shake -= 1
bwcolor_fx ()
else
pal ()
palt(14, true)
palt(0, false)
scr.x = 0
scr.y = 0
end
camera (scr.x,scr.y)
end

function bwcolor_fx ()
pal (1,5)
pal (2,5)
pal (3,6)
pal (4,7)
pal (9,6)
pal (10,6)
pal (14,6)
pal (15,7)
end

-->8
-- new data compressor
-- from the lab of dw817

function initglobal()
chr6x,asc6x={},{}
local b6=".abcdefghijklmnopqrstuvwxyz1234567890!@#$%^&*()`~-_=+[]{};':,<>?"
local i,c
for i=0,63 do
c=sub(b6,i+1,i+1)
chr6x[i]=c asc6x[c]=i
end
end

function chr6(a)
local r=chr6x[a]
if (r=="" or r==nil) r="."
return r
end

function btst(a,b)
local r=false
if (band(a,2^b)>0) r=true
return r
end

function fnca(a,b)
local r=asc6x[sub(a,b,b)]
if (r=="" or r==nil) r=0
return r
end

function strng(a,b)
local i,r=0,""
for i=1,a do
r=r..b
end
return r
end

function bit6to8(t,m)
local i,d,e,f,n,p=0,0,0,0,0,1
repeat
if sub(t,p,p)=="/" then
d=fnca(t,p+1)
e=fnca(t,p+2)+64*fnca(t,p+3)
t=sub(t,1,p-1)..strng(e,sub(t,p+4,p+4+d-1))..sub(t,p+d+4)
p+=d*e-1
end
p+=1
until p>=#t
p=1 d=0 e=0
for i=1,#t do
c=fnca(t,i)
for n=0,5 do
if (btst(c,n)) e+=2^d
d+=1
if (d==8) poke(m+f,e) d=0 e=0 f+=1
end
end
end

initglobal()

 


-->8
--update & draw
function _update ()
	if (scene=="menu") then
	update_menu ()
	elseif (scene=="game") then
	update_game ()
	end
end

function _draw ()
camera_pos ()
palt(14, true)
palt(0, false)
	if (scene=="menu") then
	draw_menu ()
	elseif (scene=="game") then
	draw_game ()
	end
end

function reset_game ()	
for b in all(item) do
del (item,b) 
end
is_death=false
pl.potion_nb=3
reload()
scene_num=0
load_scene (scene_num)
enemy_extinction=false
end

function draw_actor(a)
 a.sx = (a.x * 8) - 4
 a.sy = (a.y * 8) - 4
 a.hat = a.sy-8
 --actors-- 
 if (a.subrole!="eye") then
spr (anim_actor (a),a.sx,a.sy,1,1,a.flp,false)
else
spr (anim_actor (a),a.sx,a.sy-2,1,1,a.flp,false)
end
end

function draw_eyewings ()
--wings & shadow for eyes			
for a in all(actor) do
	if (a.subrole=="eye") then	
	spr (flr(a.frame),a.sx-8,a.sy-3,1,1,true,false)
	spr (flr(a.frame),a.sx+8,a.sy-3,1,1,false,false)
	
a.frame += 0.025
if a.frame>=74 then
a.frame=71
end
end
end
end

function gargwings(a)
	pal (8,13)
	pal (2,6)
	spr (flr(a.frame),a.sx-5,a.sy-5,1,1,true,false)
	spr (flr(a.frame),a.sx+5,a.sy-5,1,1,false,false)	
	pal (8,8)
	pal (2,2)
a.frame += 0.025
if a.frame>=74 then
a.frame=71
end
end

function draw_gargwings ()
--wings for gargoyles
for a in all(actor) do
if (a.subrole=="gargoyle" and a.still==false and a.state!="walkt") then	
gargwings (a)
end
end
end

function draw_gargwingstop ()
--wings for gargoyles
for a in all(actor) do
if (a.subrole=="gargoyle" and a.still==false and a.state=="walkt") then	
gargwings (a)
end
end
end

function put_head ()
--draw portal columns
	if (is_portal==true) then
	spr (184,port.sx+9,port.sy,1,1,true,false)
	spr (184,port.sx-9,port.sy,1,1,false,false)
end

--here is your head--
for a in all(actor) do
	if (a.head!=nil) then
	if (a.targ == 0 or a.targ == 1) then
	spr (a.head,a.sx,
	a.hat,1,1,a.flp,false)
	elseif (a.targ == 2) then
	spr (a.headt,a.sx,
	a.hat,1,1,a.flp,false)
	elseif (a.targ == 3) then
	spr (a.headd,a.sx,
	a.hat,1,1,a.flp,false)
	end
	end
	end
end

function draw_game ()
cls (1)
--draw moon--
pal (6,clcol1)
spr (155,100,6,1,1)
pal (6,6)
draw_clouds ()

map (scenex,sceney,0,0,16,16)

--item shadow
for a in all (item) do
spr (176,a.sx,a.shadowsy,1,1)
end

--eye shadow
for a in all (actor) do
if  (a.subrole=="eye") then	
a.sx = (a.x * 8) - 4
 a.sy = (a.y * 8) - 4
 a.hat = a.sy-8
	pal (2,0)
	spr (176,a.sx,a.sy+2,1,1)
	pal (2,2)
end
end

--draw explosion
	draw_iexplosions ()
	
--draw gargoyle wings
foreach(actor,draw_gargwings)

--draw actors
foreach(actor,draw_actor)
	
--draw wings
foreach(actor,draw_eyewings)
foreach(actor,draw_gargwingstop)

--draw particles
draw_iparticles ()
	
--draw fx
foreach(fx,draw_fx)

--put head
put_head ()

--draw hero's hat--
spr (1,pl.sx,pl.sy-8,1,1,pl.flp,false)

--draw_item
foreach (item,draw_item)

--draw_item
foreach (item,draw_item)

--draw game over--
if (gameover==true) then
	highlightsprite (0,96,64,8,33,60,64,8)
	if (pl.potion_nb>0) then
	rectfill (0,71,128,89,0)
	sspr (48,88,8,8,83,72,8,8)
	highlighttext ("❎ retry (    )",35,74,8)
	highlighttext ("-1",75,74,6)
	highlighttext ("🅾️+❎ quit",45,82,8)
	else
	rectfill (0,71,128,81,0)
	highlighttext ("🅾️+❎ quit",45,74,8)
	end
end

--draw level clear
if (end_scene==true and gameover==false) then
if (endtitle_dw>72)then 
endtitle_dw=flr(((main_timer^2)/30)*4.8)-44
else
endtitle_dw=72
rectfill (0,71,128,81,0)
highlighttext ("❎ continue",42,74,8)

end
highlightsprite (0,104,72,8,((128-endtitle_dw)/2)+2,(128-(endtitle_dw)/9)/2,endtitle_dw,endtitle_dw/9)
	
end

--air particles
draw_aparticles ()	

--draw attack
if (gameover_timer <=30) then
foreach(attack,draw_attack)
end 
draw_hud ()

--retry system
if (pl.retry_cooldown >0) then
rectfill (0,115,128,125,0)
if (pl.potion_nb>0) then
highlighttext ("hold 🅾️ to quit and retry",7,118,8) 
else
highlighttext ("hold 🅾️ to abandon all hope",7,118,8) 
end
end
palt()
--print ("track "..track,0,8)
end

function update_game ()
-- if player is alive control it
if (paralisis == false) then
controls()
end

--retry system
if (pl.retry_cooldown >60) then
pl.retry_cooldown =0
pl.life=0
end

move_ifx ()
move_item ()
make_clouds (17)
make_aparticles (2)
sanctuary_particles ()
foreach (actor, move_actor)
move_worm ()
move_fireball ()
move_block ()
take_item ()

--delete fx
if (pl.cooldown==1) then
if (ifx1.life>=0) then
del (actor,ifx1)
del (fx,ifx2)
create_zombi ()
else
pl.zombi_nb -= 1
end
end

--check level clear
end_level ()
--portal opened
open_portal ()
--check player death
enemy_death ()
--check player death
pl_death ()

--game over menu
if (gameover==true and enemy_extinction==true) then	
music (-1,5000) 
if (btnp(4) and btnp(5) ) then	
reset_game ()
end
	
if (pl.potion_nb>0) then	
if (btn(5) and not btn (4)) then
	for b in all(item) do
	if (b.name!="potion") then 
 del (item,b)
	end
	end
	is_death=true
	reload()
	pl.potion_nb -= 1
	load_scene (scene_num)
	screenshake (3,0)
	enemy_extinction=false
	end
	end
end

--scene ending cooldown
if (end_scene==true and gameover==false) then
music (-1,5000) 
main_timer -=1
if 	(btn(5)) and main_timer<=20 then
scene_num +=1
if (scene_num==17) then
for a in all(clouds) do
a.y += 72
end	
end
load_scene (scene_num)
screenshake (3,0)
end
end
end

--menu
function update_menu ()
--main screen
if (scene_num==0) then
if 	(btnp(5) 
and end_scene==false)	then
--cloud reinit
for a in all(clouds) do
a.y += 72
end	
end_scene=true
scene_num =1
load_scene (scene_num)
end
--main menu
elseif (scene_num==1) then
if(btnp(2)) then
selectedtile-=1
elseif(btnp(3)) then
selectedtile+=1	
elseif(btnp(5)) then
if(selectedtile==1)then
scene_num=4
elseif(selectedtile==2)then
scene_num=2
elseif(selectedtile==3)then
scene_num=3
end
end_scene=true	
load_scene (scene_num)
	
end
--menu tiles limit
if(selectedtile < 1) then
selectedtile = 1
elseif(selectedtile > numberoftiles) then
selectedtile = numberoftiles
end 
--credits & controls
elseif (scene_num==2 or scene_num==3) then
if 	(btnp(4) 
and end_scene==false)	then
scene_num =1
load_scene (scene_num)
		
end
--introduction
elseif (scene_num==4) then
if 	(btnp(5) 
and end_scene==false)	then
for a in all(clouds) do
a.y -= 72
end
scene_num =5
load_scene (scene_num)	
screenshake (3,0)
end

elseif (scene_num==17) then
if (btn(4) and btn(5)) then	
reset_game ()
end
end
end

function draw_menu ()
if scene_num!=0 then
cls (1)
--draw moon
pal (6,clcol1)
spr (155,100,78,1,1)
pal(6,6)
make_clouds (89)
draw_clouds ()
--air particles
make_aparticles (2)
draw_aparticles ()
end
palt(14, true)
palt(0, false)
map (scenex,sceney,0,0,16,16)
if (scene_num==0) then
print ("press ❎ to start",30,43,8) 
print ("2020-fred osterero",28,111,1)       
print ("musics by nicolas grandgirard",6,118,1)    
elseif (scene_num==1) then

--main menu
highlightsprite (0,112,32,8,48,16,32,8)
for i=1,numberoftiles do
highlighttext (tiles[i],48,24+(12*i),8)    
end
spr(35,36,22+(12*selectedtile))
highlighttext ("❎ select",90,118,8) 
--controls screen
elseif (scene_num==2) then
-- controls
highlighttext ("controls",47,8,8)
highlighttext ("collect skulls and ",8,17,6)
highlighttext ("press ❎ to resurrect",8,24,6)
highlighttext ("the dead ones.they could",8,31,6) 
highlighttext ("destroy foes,pillars",8,38,6) 
highlighttext ("or...you!",8,45,6)
highlighttext ("collect orbs to open",8,54,6)
highlighttext ("the portal.",8,61,6)					
highlighttext ("if you get stuck,hold 🅾️",8,70,6)
highlighttext ("to quit and retry.",8,77,6)	
highlighttext ("🅾️ back",90,118,8) 
elseif (scene_num==3) then
-- credits
highlighttext ("credits",50,8,8)
highlighttext ("design,art,code",8,17,13) 
highlighttext ("fred osterero",71,17,6)
highlighttext ("musics",8,25,13) 
highlighttext ("nicolas grandgirard",36,25,6)
highlighttext ("testers",8,35,13) 
highlighttext ("thomas dolfini,sam condat",8,42,6) 
highlighttext ("extra thanks to",8,51,13)
highlighttext ("pico-8 month,zep,dw817,",8,58,6)
highlighttext ("kql1n,hop,sara,alex valentin",8,65,6)					
highlighttext ("for your tutorials,technical",8,72,13)
highlighttext ("solutions and help.",8,79,13)	
highlighttext ("🅾️ back",90,118,8)
elseif (scene_num==4) then
	-- introduction
highlighttext ("and lady proserpina said:",16,8,8)
highlighttext ("greetings mortimer!",8,18,6) 
highlighttext ("travel to the necropolis and",8,28,6) 
highlighttext ("pay tribute to our divinity",8,36,6)
highlighttext ("to become a true necromancer.",8,44,6)
highlighttext ("resurrect the dead ones along",8,54,6)
highlighttext ("your pilgrimage.but beware!",8,62,6)					
highlighttext ("they know no more master.",8,70,6)
highlighttext ("❎ start",90,118,8)
elseif (scene_num==17) then
--end
highlightsprite (0,120,40,8,44,64,40,8)
highlighttext ("so the divinity said:",22,8,8) 
highlighttext ("hey! what's up mortimer?",6,18,6) 
highlighttext ("you're a true necromancer now!",6,26,6)
highlighttext ("oh wait... ",6,34,6)
highlighttext ("you're next on my list!",6,42,6)
highlighttext ("lol! i'm kidding bro! see ya!",6,50,6)					
highlighttext ("🅾️+❎ quit",86,118,8)
end
end




__gfx__
00000000eeeeeeee0112420e0112420e0112420e0124421001244210012442100111111001111110011111100124421001244210011111100111111001244210
00000000eeeeeeeee01fff0ee01f7a0ee01ffa0e01ffff10017aa71001faaf1001111110011111100111111001ffff1001ffff10012442100124421001ffff10
00700700eeeeeeeee022180e0f2218a00f2218a0e021180e0a2118a00a2118a0e011110ee011110ee011110ee021180e0f2118f0e0ffff0ee0ffff0e10211801
00077000ee0000ee0fdd16f0e0dd1a0ee0dd1a0e0fd116f0e061160ee0d1160e0f2118f00f2118f00f2118f00fd116f0e0ddd60e0f2118f0e021180e102288f0
00077000e0ddd60ee0ddd60ee0ddaa0ee0dd6a0ee0ddd60ee06aa60ee0daa60ee022280ee022280ee022280ee0ddd60ee011110ee0ddd60e0fddd6f00fddd601
00700700e0ddd60e00ddd60000ddaa0000dd6a00e0ddd60ee06aa60ee0daa60ee0ddd60ee0ddd60ee0ddd60ee011110eee0000eee011110e0011110010dd6601
00000000e022280ee000000ee000000ee000000ee000000ee000000ee000000ee000000ee000000ee000000eee0000eeeeeeeeeeee0000eee000000e10000001
000000000dddd660ee0000eeee0000eeee0000eeee0000eeee0000eeee0000eeee0000eeee0000eeee0000eee000000ee000000ee000000ee000000e11000011
0111240ee011240e0111240ee011240e01244210012442100124421001244210011111100111111001111110011111100112420e0112420e0111240e0112420e
e0114f0e011fff0ee0114f0e011fff0e01ffff1001ffff1001ffff1001ffff1001111110011111100111111001111110e01fff0ee014ff0ee0114f0ee014ff0e
e022210ee022210ee022210ee022210ee021180ee021180ee021180ee021180ee011110ee0111110e011110e0111110ee022180ee022180ee022180ee022180e
e022280e022228f0e022280ee02f280ee022880ee02288f0e022880e0f22880ee021180e0f221110e021180e011128f0e022880ee022880ee022880ee022880e
e0fdd60e0fddd60ee0fdd60ee02dd60e0fddd6f00fddd60e0fddd6f0e0ddddf00f2228f0e02288f00f2228f00f22280e0fddd6f00fddd6f00fddd6f00fddd6f0
0ddd660ee0ddd60e0ddd660ee0ddd60ee0ddd60ee0dd660ee0ddd60ee0ddd60ee0ddd60ee0dd660ee0ddd60ee0dddd0ee0ddd60ee0ddd60ee0ddd60ee0ddd60e
e00000eee000000ee00000eee000000ee000000ee000000ee000000ee000000ee000000ee000000ee000000ee000000ee000000ee000000ee000000ee000000e
ee0000eeee0000eeee0000eeee0000eeee0000eeee0000eeee0000eeee0000eeee0000eeee0000eeee0000eeee0000eeee0000eeee0000eeee0000eeee0000ee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0eee0eee0e0e0e0112420111111111
eeeeeeeeeeeeeeeeeeeeeeeeeee0000eeee000eeee0000eeeee000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0eeeeee0eeee0800080e0808080101fff0111111111
ee0000eeeee000eeeee000eeee09aaa0ee0aaa0ee0999a0eee0aaa0eeeeeeeeeeeeeeeeeeeeee0eee0ee0a0eeee080eeee08880eee08880e1022180111111111
e0d6660eee06660eee06660ee0928a80e088a880e08928a0e0aaaaa0eeeeeeeeeeeeeeeeeeee0a0e0a0ee0eeee08880eee08880ee08888801022880111000011
0d28680ee0886880e0666660e0922a20e022a220e02922a0e09aaa90eee00eeeeeee00eee0e000eee0eeeeeeeee080eeee08880eee08880e0fddd6f010ddd601
0d22620ee0226220e0d666d0e099aaa0e09aaa90e0999aa0e0999990ee0a90eee000a9000a09900eee0e0e0eeeee0eeee0800080e080808010ddd60110ddd601
0dd6660ee0d666d0e0ddddd0ee00a0a0ee0a9a0ee090900eee09990ee0aaa90ee0aa9990e0a99a90e0a09090eeeeeeeeee0eee0eee0e0e0e1000000110222801
e016160eee06160eee06660eeeee000eeee000eeee000eeeeee000eeee0000ee000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeee110000110dddd660
00000000e0661660e021100ee021100ee021100ee021100ee0d111d0e0211120e0211120e0211120e0211120e0444440e0244420e0244420e0244420e0244420
110511100216416002664660026646600266466002664660e0622260e0d222d0e0d222d0e0d222d0e0d222d0e0444440e0444440e0444440e0444440e0444440
000000000211400002164160021641600216416002164160e0244420e0644460e0644460e0644460e0644460e0244420e0244420e0244420e0244420e0244420
01000051e0440eeee044000ee044000ee044000e0244000ee0244420e0244420e0244420e0244420e0244420e0222220e0222220e0222220e0222220e0222220
00ddd600e0220eeee0220eeee00220eee0220eee0220220ee0220220e0220220e0440220e0220220e0220440e0220220e0220220e0440220e0220220e0220440
10ddd600e02440eee02440ee0202440ee02440ee02440220e0440440e0440440ee000440e0440440e044000ee0440440e0440440ee000440e0440440e044000e
002228000000000e0000000e0000000e0000000e0000000e00000000000000000000000000000000000000000000000000000000000000000000000000000000
0dddd660e00000eee00000eee00000eee00000eee00000eee000000ee000000ee000000ee000000ee000000ee000000ee000000ee000000ee000000ee000000e
e0eeeeeeeee0eeeee0eeeeeeee0ee0eeeeeeeeeeee0ee0eeee0ee0eeeeeeeeeeee0eeeeeeeeeeeee110000111111111111111111ee0eee0eeee00eeeee0eee0e
04000eeeee040eee04000eeee080080eee0000eee080080ee080080eeeeeeeeee080eeeeeeeeeeee10dd66011111111110000001e000e000ee0dd0eee000e000
0444f0eee044f0ee044ff0eee026620ee086680ee026620ee026620ee00eeeee08280eeee0eeeeee10dd66011111111102444440ee0eee0ee05dd50eee0eee0e
e04fff0ee04fff0ee044ff0e0d8877700d2662700d6688600d6887700880eeee822280ee080eeeee10171101110000010022004000000000015dd5d000000000
044000f004400ff004444ff0028787700d6887700d6287800d28787082280eee022280ee8280eeee0dddd6601044444006024040ee0eee00515dd5d50e0eee0e
040110f0040110f004444ff0022887700d2878700dd228800d22887002280eeee02080ee2280eeee02442220104444400500224000000001515dd5d5d0000000
040110f0040110f004444ff0e022660ee022880ee0dd220ee0d2260e02080eeeee0e0eee020eeeee084ff801104444400601024000000051510000d5d5000000
e0400f0ee0400f0ee044ff0eee0000eeee0000eeee0000eeee0000eee0e0eeeeeeeeeeeee0eeeeee104f880110222220101102404444015150011005d5d04444
04444440044444400444444004444440044ffff0044ffff006cccc6006c77c60067cc760101111011012280110505050111102401110515106600770d5d01111
0574457005744570075445700754457004444ff004444ff0067cc76006cccc6006c77c60060000600557d5f01050505011110240111051500066770005d01111
e011f110e011f110e011f110e011f110e044fff0e044fff006c77c60067cc76006cccc600d0660d0015550011060606011110240111051010065570010d01111
0444ff0e0444ff0eee04ff0eee04ff0eee04ff0eee04ff0e066666600666666006666660106886010f1110d01060606011110240111050111016710111001111
e04ff0eee004ff0eeee04ff0ee04ff0ee04ff0eeee04ff0e0dd55dd00dd55dd00dd55dd006d66d60105dd0601070707011110240111000000000000000001111
040f000ee040f0eee00040f0e0040f0ee040f0eee0040f0e0dddddd00dddddd00dddddd000d11d00105150601022222011110240111000110212120199101111
000000000000000000000000000000000000000000000000000000000000000000000000060cc06010d1d0011000000010000240000010510454540199101115
e000000ee000000ee000000ee000000ee000000ee000000e1000000110000001100000010ddccdd0000000001000000010000000000011000454540144101111
eeeeeeeeeeeeeeeeeeeeeeee1111001111111111eeeeeeeeeeeeeeee11111111eeeeeeee11100011eeeeeeee1111111111111100000051100414140d66d01111
eeeeeeeeee8eeeeeeeeeeeee1100550111111111e0e00e0eeee000ee11000111e0e00e0e110f8801e0e00e0e1110011111111040000000110454540001101511
eee0eeeee8988eeeee8eeeee101185001111111106066060e00d660e1088f0110606606010888f800d0d6060110ff01110010401000010510454540105101111
ee0800ee89a9988ee8988eee11001555000111110dd66660060d666008f888010dd66660108f88800dd666601102401105504011000000000000000000001111
e022280e8aaaa98889aa988e11110111555011110d1551d00d6d8180100500110d8118d0110050010d66666010224401055601111044f0000555550000011111
02228a8089a9988ee8988eee11111050000111110dd66dd0e0ddd660110f01110dd66dd01110f0110dd666600002400010655011100000111000001111111111
02228880e8988eeeee8eeeee1111050501111111e0d11d0eee0dd11010000011e0d11d0e11000001e0d1160e1000000100000000044f0f011111111111111111
06060080ee8eeeeeeeeeeeee110000000000111106155160e0d5500e11000111e015510e11100011e055550e1100001111111111100000111111111111111111
0222888000110880e0000880e00008800011088006611660e0dddd0ee0dddd0ee0dddd0ee0dddd0ee0d55d0ee0d55d0e111111110000511001011010d5d01111
e022288002288880e0a92880e099288002288880066556600d6656600d66566006655660066556600dddddd00dddddd0111111110000001100d0060005d01111
ee02880ee022280ee099280e0222880ee022280e061dd1600111d1100111d110e01dd10ee01dd10ee0dddd0ee0dddd0e1888811100001051000d600010d01111
ee02880eee02880e0222880ee022880eee02880e0d1dd1d0e0d55d0ee0dddd0ee0dddd0ee0dddd0ee0d55d0ee065560e88888811000000001010010111001111
e002000ee002000ee002000ee002000ee002000ee015510e0d60160e06d06d0ee0d55d0ee051150ee065560ee065560e18881111181110000000000000001111
01d01dd001d01dd001d01dd001d01dd001d01dd0e0d11d0e060060eee00e00eee061160eee0000eee061160eee0000ee11111188111881110222220188101111
0001d0000001d0000001d0000001d0000001d000066116600000000e0000000e0000000000000000000000000000000011111111118888110888880188101115
100000011000000110000001100000011000000100000000e00000eee00000eee000000ee000000ee000000ee000000e11111111111881110000000144101111
11010101111111111111111100000000011111111111240000000000000000001111111111000011110001111111111110666601111111111102401110101101
1030b0b0111111111111111100444440001111111111240000044444444440001111111110d66d01106660111100111110dddd01110000111102401102040040
055b3b0111111111ddd1111144222224001111111111124000112222222224401111111110d66d0106ddd601105d011106111160106666011102401110400401
053533b011111111111ddddd22111112001111111111124001111111111112401111111010d66d010ddddd01110011110666666006dddd601102401110040040
10535350111111110111111111111111001111111111124001111111111112401111114010d66d0110555011111111110dddddd00dd55dd01022440102024040
05555501111111110010100011111111011111111111124001111111111112401111124010dddd010ddddd01111100110000000010dddd010002400010224401
105050111111111100000000111111110111111111112400011111111111124011111240100000011000001111105d0110000001110110111000000111024011
11020011111111110000000011111111011111111111240001111111111112401111124011000011100000111111001111000011110dd0111100001111024011
00000000000000000000000000000200555555501111124001111111111112400000000011100060ee0eee0eee6666ee11000111111111111111111110111011
110511000000011011051110110511105555555011111124011111111111114000000000111050d0e000e000e6ffff6e1066601111111111111111110b010b01
00000000000000000000000000000000111111101511111201d1111111111d100000000011105000ee0eee0e6ffffff606ddd601110000111101110110b0b001
001000510000005105111011051212110000000011111111011dddddddddd1100000000011105060000000006ffffff60ddddd0110d6660110b010b010303011
000000000000000000000000000020025555555011111151001111111111110000000000111000d0ee0eee0e6ffffff60d555d010dd06001100b0b0111111111
100001100000011011051110210511105555555011511111000101011010100000000000111050d0000000006ffffff60ddddd010ddd66010b03030111111111
0000000000000000000000000000020011111110111111110000000000000000000000001110505000000000e6ffff6e00000001000d0d011030301111111111
0511105100000051051110110511101100000000111111110000000000000000000000001110505044144414ee6666ee10000011100000111111111111111111
11111011111111110000000000000000e000000e00000000111111111118111114111141ee0e0e0eeeeeeeee111000111100001110100101e0e0ee0e11111111
11110601111111112208222011051110057777d000000000111818111818881111118111e030b0b0eeeeeeee11024401106666010503b0b00204004011111151
11110d60131311110000000000888800057287d004040404118888911188988111888881055b3b0eeee00eee1110201110dddd01003883000040040e11511111
1010d001113111110822202205811811057227d005050505198998811889998118898981053533b0ee0cc0ee1110201110d55d01055223b0e004004011111111
06000060111111110000000000800800057777d004040404109779011097790110977901e0535350e0cc7c0e1110601106dddd60050330300202404011111511
10dd6601111131312208222011888810055555500505050505000050050000500500005005555500e0cccc0e110655010dddddd0000550000022440011111111
06000060111113110000000000000000000000000404040405099050050440500508805000505000070cc0701106650110000001100000010002400015111151
00000000111111110822202205111011e000000e0000000010000001100000011000000144020044057007501000000011000011111001114402404411111111
eeeeeeeeeee00eeeeee00eeeeeeeeeeeeeeeeeeeeeeeeeeeee000eeeee000eeeeeeee00eee0000eee057750e1111111111111111060001110000000000000001
eeeeeeeeee0cc0eeee0dd0eeee0000eeee0000eeee0000eeee040eeeee040eeeeeee0660e06dd60ee0d55d0e11100111110001110d0501110600060006000601
eeeeeeeee0cc7c0ee0dd7d0ee09aaa0ee09aaa0ee055550ee0cc70eee0cc70eeeeee05500651156000d66d001102401110000001000501110d060d060d060d01
eeeeeeeee0cccc0ee0dddd0e0928a80e0914a40e0500500ee00c00eee00c00eeeee0655605511550065665601011240110000001060501110d000d000d000d00
eee22eeeee0cc0eeee0dd0ee0922a20e0911a10e0500500e0222270e0888870eeee06666055c65500665566000121240000000110d0001110000000000000001
ee2222eeeee00eeeeee00eee099aaa0e099aaa0e0555550e0888880e0888880eeee05555055cc5500566665001010120100000010d0501110550550505505501
eee22eeeeeeeeeeeeeeeeeeee00a0a0ee00a0a0ee005050ee08880eee08880eeeeee000005511550005555001010101111000011050501110110110101101100
eeeeeeeeeeeeeeeeeeeeeeeeeee000eeeee000eeeee000eeee000eeeee000eeeeeeee00e00000000e000000e1111111111111111050501110000000000000001
e8888eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee10000011ee0eee0e1111000111111111e0eee0e00e0eee0eeeeee0000000eeee
88ee8eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee8888eeeeeeeeeeeeeeeeeeeeeee0d222d01e00000001100dd6011111111000e00056000e000ee000677777700ee
88e8eee888e8eee8e888e888eee8888eeeee888e88e8e888eee8888ee8eee8ee0d888d01e066660e105dd60111100111e0eee055660eee0ee066dddddddd770e
88888eee8888eee8888888888e888e88eee8888e88e888e88e888e88e88888ee0d888d0106dddd60055dd660100dd0010000055566600000ee0ddd000000dd70
888e8ee88888eee888e88e888e88888eeee8888e88e888e88e88888ee888eeee0ddddd010dd55dde05500d600dd77dd0e0e0555566660e0eee0dd005d70e000e
88ee8e888888eee888e88e888e88888eeee8888e88e888e88e88888ee888eeee0555550100dddd00050000d00d7557d00005555566666000eee05055dd70e0ee
88ee8e888e88eee888e88e88ee888eeeeee8888e8ee888e8ee888eeee888eeee1000001100011000050110d0065555600055555006666600eee05050d070070e
e888eee8888888e888e88e888ee8888eeeee8888eeee888eeee8888ee888eeee11111111440dd01410055001066556604055550dd0666604eee0505000600670
888eeeeeeeeeeeeeeeeeeeeeeee8e8eeeeeeeeeeeeee8e8eeeeeeeeeeeeeeeeeeeeeeee8800000000550056010066001105550d67d066601ee00005101600670
888eeeeeeeeeeeeeeeeeeeeeeee88eeeeeeee8888eee88eeeeeeeeeeeeeeeeeeeeeeee88800000000505d0d010d00d0110550dd66dd06601e005605010605000
888eeee8888ee8e888eee8888ee88eeeeeee888e88ee88eee8888eee888e8eee8eee8e88e00000001055dd01061dd1601050dd6dd6dd0601ee05605000605500
888eee888e88e888e88e888e88e88eeeeee8888e888e88ee888e88eee8888eee88888e88e00000000d0000600661166010000000000000010000001555560000
888eee88888ee888e88e88888ee88eeeeee8888e88ee88ee88888eee88888eee888eee8ee00000000ddd66600d6666d00d66666666666660ee005055d6660ee0
888e8e88888ee888e88e88888ee88eeeeee8888e88ee88ee88888ee888888eee888eeeeee00000000555555000dddd0010000000000000010000505dd6600000
88888e888eeee888e8ee888eeee88eeeeee8888eeeee88ee888eeee888e88eee888eee88e0000000100000011000000110011000000110010000505d65600000
8e88eee8888eee888eeee8888eee88eeeeee88888eeee88ee8888eee888e888e888eee8ee00000001100001111000011101d6101101d61014440505d65604441
8e88e88eeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000ee0eee00000eee0e10100101101d6101101d61011110005d65000111
88888888eeeeeeeeeeeeeeeeeeeeeeee0004444444444440444440000000000000000000e000e0777770e0000505d0d0101d6101101d61011110600000060111
88e88e88ee8888ee8eee8ee888ee8eee0011222222222224222224400000000000000000ee0e07ddddd70e0e10811801101d6100001d61011110555555550111
88e88e88e888e88e888888ee88e88eee011111111111111211111240000000000000000000000ddddddd000010511d01101dd155551dd1001106666666666011
88e88e88e88888ee888e88e888e88eee0111111111111111111112400000000000000000ee0ee0d555d0ee0e101001010d666666666666601105555555555011
88e88e8ee88888ee888e88e888e88eee0d111ddddd111dddddd112400000000000000000000000d555d00000050000d00dddddddddddddd01105555555555011
88e88e8ee888eeee888e8ee888e88eee01ddd11111ddd111111d12100000000000000000000006ddddd6000005515dd000000000000000001000000000000001
88e88e88ee8888ee888e88ee888e888e0011100000111000000111000000000000000000441406ddddd60414015151d010000000000000011100000000000011
888888e8e8eeeeeeeeeeeeeeee888eeeeeeeee88eeeeeeee100000010000000000000000111106666666011105515dd010000001100000010000eeee01600e0e
88888ee88eeeeeeeeeeeeeeee8e88eeeeeeeeee88eeeeeee0555555005510551000000001111055555550313015151d00444444002444440777700ee1060e000
ee8eeee88eeeee8888eeeeee88eeeeeeeeeeeee88eeeeeee055555500511051100000000111061111111603105515dd00454554010024040dddd770e0060ee0e
e88eeee88e8ee888e88eeeee88ee8e8ee8eeee888eeeeeee05555550011101110000000011106ddddddd6011015151d004444440055024400000dd7055560000
e88eeee88888e88888eeeeee88888e88888ee8e88eeeeeee055555500000000000000000111066666666601105515dd0000220010a900240d70e000ed6660e0e
e88eeee88e88e88888eeeeee88eeee88e88e88e88eeeeeee055555500551055100000000313055555555501100515d000b0440110a900240dd70eeeed6600000
e88eeee88e8ee888eeeeeeee88ee8e88e8ee88e88eeeeeee0555555005110511000000001310000000000111100000011030001105500240d070eeee65600000
ee88eee88e88ee8888eeeeeee888ee88e88ee88e8eeeeeee10000001011101110000000011110000000001111100001111100111100102400060eeee65604414
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000111000000000000000000000000000000000000000000000000000000000000000000000000000001110000000000000000000000000
00000000000000000001000100000000000000000000000000000000000000000000000000000000000000000000000000110001000000000000000000000000
0000000000000000001044f010000000000000000000000000000000000000000000000000000000000000000000000001008880100000000000000000000000
0000000000000000001044ff01000000000000001111111111111111110000000000000000000000000000000000000010888801000000000000000000000000
0000000000000000010444ff0100000000000001000000000000000000100000ccccccccccccccccccccc0000000000108888801000000000000000000000000
0000000000001111110444ff010000000000001066666666666666666601000c000000000000000000000cc00000001088822801000011000000000000000000
000000000001000000444fff01000000000001066666666666666666110100c066666666666666666666600c0000010888222801000100100000000000000000
000000000110044444444fff010000000000010dd666666666666111110100c011666666666666666666660c0000108882222801001028010000010000000000
0000000010044444444ffff0100000000000010dddddd11111111111110100c011111116666666666666dd0c0000108822222801010288010000101000000000
000000010444444ffffffff0100000000000010dddddd11111111111110100c011111111111ddddddddddd0c0001088222228801102880111001020100000000
00000010444444fffffffff01000000000000010ddd11111111111111110100c01111111111ddddddddddd0c0001088222282880102880100110288010000000
000000104444ffffffffffff0100000000000010ddd11111111111111110100c01111111111dddddddddd0c00010882222822280102888077001028801000000
000001044444444ffffffffff010000000000010dd111111111111111110100c01111111111dddddddddd0c00010882222822288060280777770028801000000
000001044444444444fffffff01000000000001000111000011111110000100c01111111111ddddddddd0c000010822000022222666007777702288010000000
000010444ffffff4444fffffff0100000000011077000777700000007770111c01111111111ddddddddd0c000010800111100226666777777702888010000000
00001044fffffffff444fffff40100000011100066707070770777776660000c00111111111dddddd0000c000001011000010226666677777702880100000000
000010444fffffffffffffff440100000100066000606777760666660000660c022000000000000008880c000000100000001066668877777770001000000001
00010444400000000fffffff4401000010666dd1110006066000000011111ccc022222222228888888880cc00000000000001066688888777777760100000010
001044440000000000fffff44401000010dddddddd11100000111111111cc00002222222222888888880000ccc00000000001066888877888777660100000108
0010444400000000000ffff4440100000100ddddd11111111111111111c000dd1002222222288888800dd66000c0000000001066888277888766666011111088
00010444000000000000ff44440100111111000d11111111111111111c0ddd1111100000000000000dddddd6660c000000001066282228888666600000000888
000010440000000000000444440101000010111000000111111000000c01111111111111111ddddddddddddddd0c000000001066288288888666088888888822
000010440000000000000444441010fff0100102222200000004440402c0011111111111111ddddddddddddd000c000000000106228888888666082222822222
00000104400000000001044440110ff00f0101028880444440000044028cc011111111111111ddddddddd000ccc0000000000106622888826666082222282222
0000001044000000001104444000ff000f0101028880444f007504440028cc00000000000111ddddd0000110c0c0000000000010662222266666600222282222
000000010440011111110444fffff0000f010102280444ff075404440ff08c011110444440000000044011100a0c000000000001066666666666011002282222
000000001044001111110444fffff00560f0101022044ffff744ff440ff08c01000000004444440000400010c0c0000000000000100666666000100110822222
000000110444400111104444ffff0566660010102044ffffffffff44fff08c004400775604444056774044010ccc000000000000011000000111000001022222
0001110044444400000444444fff05666660101020ffffffffffff444f40c010f40477507444475077404f010cc0c00000000000000111111000000000102222
01100044444444444444444444ff0665666010010fffffffffffff440000c010f4044755744447557fa04a010c0a0c0000000000000000000000000000102228
100444444444f4444444444444ff06005660100100fff00ffffff4400022c011044444444fffffffffafaa010cc0c00000000000000000000000000000102288
10444004444fff444444444444ff060056001010200fffffffff44002222c0111004444fffffffffffa00010c0ccc00000000000000000000000000000108800
104400004fffff444444444444fff0005600101022000ffffff4002222220c01111044fffffffffffa0111100a00c00000000000000000000000000000108011
104000000fffff444444444444fff00000f010102200000000000000222010c00000044ff0000ffaa000000c0a0a0c0000000000aaaaaa000000000000010100
104000560fffff444444ff4444fff00000f0101020666507770556660220100c02280004ffffffa00028a0c0aa00c0000000000a000000aaa000000000001000
1040566660ffff444444fff4444ff0000ff01001006650007000006602010000c022880000000000288a0c00aaa0c000000000a0999999000aa0000000000000
1005666660ffff444444fff44444ff000f01000010600dd070dddd06001000000c0288804444440228a0c0aaa7aa0c0000000a0999999999900a000000000000
1005660060ffff444444ffff44444ffff4401000010dddd070d11dd000100000cc00000800000050000000aa77aaa0c00000a099999999999990a00000000000
1005660000ffff444444ffff444444ff44401000010ddddd0dd110d110100000c02222200111100222aa00aa77aa0c00000a09999999999999990a0000000000
1040560000fffff444444ffff444444444f01000010dddd090d110dd11010000c022228880000888888a0c0aaaaa0c00000a0aa99999999988990a0000a00000
0140566000fffff444444fffff4444444fff0100010d0dd090dd10dd1101000c02222888880088888888a0000000c00000a0aaaa99999998877990a00aaa0000
001400040ffff04444f444fffff444444fff0100010d0ddd0ddd100dd10110c02222288808008088888880a0cc0cc00000a0aaaa88899992287890a000a00000
001044444ffff00444ff44ffffff44444ffff01010dd0ddd0ddd110dd1101c0222228880a0000a0888880ffa00a0c0000a0aaaa888779992228890a000000000
00010000444ff01044ff444fffffff4444ffff0110000dd000ddd10ddd101c02222888880aaaa088888804ffaa00c0000a0aaaa88887899222889a0000000000
000011110444f01044ff4444ffffff00444ffff01060dd01110dd100000601c022888888800008888888044ff00c00000a0aaaa22288889922890a0000000000
000000001000011044fff4444ffff01104444ff01000d0111110d10066660c0100088888801108888880000000c000000a0aaaa222222299999900a000000000
000000000111101044ffff0444fff010100000010f40d0000000d11000000c0011d0888801111088880011110c0000000a0aaaa222222299999990a000000000
0000000000000010444fff04444fff01011111110f4001ddddd000000ff4004011d0000000000000000c0000c00000000a0aaaaa222229999909990a00000000
0000000000000010444fff004444fff01000000010001ddd0dd111100f00c0f40002224040555555550ccccc0000000000a0aaaaaaaaa9999000990a00000000
0000000000000001044fff0104444fff010000001060dddd0ddd1110000c0ffff400000040555555550c000000000000000a00aaaaaaaaa9990000a000000000
00000000000000001000ff0110000000100000001060ddd000ddd1106660c0000f02222040000000000c00000000000a0000aa000000aaa999900a0000000000
00000000000000000111001001111111000000010660ddd100ddd11066601cccc0c0000001dddddddd0c0000000000aaa00000aaaaaa0aaa9990a00000000000
00000000000000000000110000000000000000100660dd11060dd110666601000cc0111111dddddddd0c00000000000a000000000000a0aa990a000000000000
00000000000000000000000000000000000001066660dd11060ddd110666010000c011111ddddddddd0c0000000000000000000000000a0000a000000a000000
000000000000000000000000000000000000010666600000060000000666010000c0111111dddddddd0c00000000000000000000000000aaaa000000aaa00000
00000000000000000000000000000000000001066660551106605511066660100c011111111ddddddd0c0000000000000000000000000000000000000a000000
00000000000000000000000000000000000001006660551106605511106666010c011111111111111110c0000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000008888800000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000888888880000000000000000000000000080000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000088888188888000800000000000000000088880000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000008888118888008880000008000000800088880000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000018888018811000100000088000008800088880000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000008888001111001810000888000088800088880000800000000000000000000000000000000000000000000
00000000000000000000000000000000000000000008888001100008880008888800888880088880008880000000000000000000000000000000000000000000
00000000000000000000000000000000000000000008888000000008880008888800888880088880088880000000000000000000000000000000000000000000
00000000000000000000000000000000000000000008888000000008880008888100888810088880888888000000000000000000000000000000000000000000
00000000000000000000000000000000000000000008888000000008880008888100888810088880881888800000000000000000000000000000000000000000
00000000000000000000000000000000000000000008888000000008880008888000888800088880881888000000000000000000000000000000000000000000
00000000000000000000000000000000000000000008888000000008880008888000888800088880810188100000000000000000000000000000000000000000
00000000000000000000000000000000000000000008888000000008880008888000888800088888880881000000000000000000000000000000000000000000
00000000000000000000000000000000000000000008888000000008880008888000888800088888888811000000000000000000000000000000000000000000
00000000000000000000000000000000000000000008888000000008880008888000888800088881888110000000000000000000000000000000000000000000
00000000000000000000000000000000000000000008888000000008880008888000888800088881888100000000000000000000000000000000000000000000
00000000000000000000000000000000000000000008888000008808880008888000888800088880888800000000000000000000000000000000000000000000
00000000000000000000000000000000000000000008888000888808880008888000888800088880888880000000000000000000000000000000000000000000
00000000008888800880000000000000000000000008888088888808880008888000888800088880188888800000000000000000000000000000000000000000
00000000008888808888000000000000000000000088888888888808880008888000888800088880118888000000000000000000000000000000000000000000
00000000001888888888800000000000000000000088888888888808880001888000188800088880011881100000000000000000000000000000000000000000
00000000001888888888800000000000000000000011111111111101110001181000118100011110001111000000000000000000000000000000000000000000
00000000000888888888880000000000000000000011111111111101110000111000011100011110000110000000000000000000000000000000000000000000
00000000000888811888880000008000000800000000000000008000000800018000081000000888000008000080000000800000008000000000000000000000
00000000000888811888880000088800008880000880088000088800000880088800880000008888800008800888000008880000088800008800880000000000
00000000000888800188880000888800088880008888888000888880008888888888888000088888880088888888800088880000888800088888880000000000
00000000000888800188880008888880888888808888888008888880008888888888888800001188880088888888800888888808888880088888880000000000
00000000000888800018880008818888881888008888888008818888008888188881888800011188880088881888800881888008818888088888880000000000
00000000000888800018880008818880881181108888181008111888008888188881888800000888880088881888800881181108818880088881810000000000
00000000000888800008880008101881880111008888111008801888008888088880888800088818880088880888800880111008101881088881110000000000
00000000000888800008880088808810880010008888010008800188008888088880888800088118880088880888800880010088808810088880100000000000
00000000000888800008880088888118880000008888000008800188808888088880888800888108880088880888808880000088888110088880000000000000
00000000000888800008880018881100888000008888000008880088808888088880888800888008880088880888800888000018881100088880000000000000
00000000000888800008810018881001888000008888000008880018108888088880888800888008880088880888801888000018881000088880000000000000
00000000000888800008810008888000888800008888000008888018108888088880888808888008880088880888800888800008888000088880000000000000
00000000000888800088100008888800888880008888000008888888008888088880888800888808880088880888800888880008888800088880000000000000
00000000000888800088100001888888188888008888000001888881008888088880888801888888880088880888800188888001888888088880000000000000
00000000000888800088880001188880188888008888000001188811008888088880888800888808880088880888800188888001188880088880000000000000
00000000000888800888880000118811018881008888000000188810008888088880888800188111810088880188100018881000118811088880000000000000
00000000000111100011110000011110011811001111000000018100001111011110111100111101110011110111100011811000011110011110000000000000
00000000000111100111110000001100001110001111000000011100001111011110111100011000100011110011000001110000001100011110000000000000
00000000000000000000000000000000000100000000000000001000000000000000000000000000000000000000000000100000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000001110111011101110000011101110111011000000011001101110111011101110111001100000000000000000000000000000
00000000000000000000000000000010101000101010000010001010100010100000101010000100100010101000101010100000000000000000000000000000
00000000000000000000000000001110101011101010111011001100110010100000101011100100110011001100110010100000000000000000000000000000
00000000000000000000000000001000101010001010000010001010100010100000101000100100100010101000101010100000000000000000000000000000
00000000000000000000000000001110111011101110000010001010111011100000110011000100111010101110101011000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020000000000000000020202020002020200000000000202000002000200020002020200000000000200000000000000020002
0202020202020202020203020202020200020000000202020202000002020202000202000000020202020002020202000000000000000000020202020202020200000000000000000200000202020000000000000000000002020202000000000000000002020200000000000202020200000000000000000000000200020000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a9a94d4e4faea9aea9a9a9aeaea9a9a9a9aea9a9a9aea9a9a9a9aea9a9aea9a9aea9aeaea9aea9aeaea9aeaea9a9aea9a9a99a9a9ac99aaeaea99a9a9aa99aa9aea99a9a9a9a9a9a9a9a9a9a9a9aaea9
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008e8e5d5e5f8e8e8e8e8e8e8e8e8e8e8e8f8f8f8e8e8e8e8e8e8f808e808e8e8e8080808e8e8e8e8e8f808e8e8e8e8e8e8e8efc818a8ca18e8e8ea68a9c8e9e8e8e8e9d88829e88828282828282828e8e
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009e9f6d6e6ffc9e818f8081bbbca081af8e8e8e88828282819e8e8e818e8882828e8e8e6b819e69678e8e6ba16b6caf9f8282828282828282828282828badadaf82828297508485ba9292b390925084ad
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009e9d81af9f8181a18e8e9fa6816b6bad81bbab8550929084888281fd8185a3a2816b69888282828282828282828281ad911092939292ba939350929296af9f819110929292849587929c9286879284ad
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000828282828b8882828282828282828281af888297a4ba92848598845ca085b986816781859392b39293909250929284ad87929092868383879c8aac9392848daf8383879292969f859390928485b99682
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000911092928485929293939092ba9292849e85b3929292929697989682829792848282829792e4e5e6a4928687ba86818b8592929296828297bebebf9092848c818989859290929697938683af8592a3a2
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000083838792969790868792868387928680889792e4e5e6939290a592929292b3849110929292909292929284859284a68185b3509392ba9270929292929296819e9e9f8592927092b6929681a695838383
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008080859292b3928485b684ad8590848085b692909250868387988687928683818383e5e5838383838383af85929681af85928683838387929292a492939284899cac8593929292be8dbf968282818faf
000000000000000000000000000000000000000000000000000000000000000000000000000000cecf000000000000008f8095838383836b9583a6a18592848095838383838381a69583818592848f819f8592ba9681fd81a6adad859292849e859084afa69f95838792929cac9284a6af8b8593929290bd8c9992b393848e81
00000000000000000000000000000000a9a94d4e4faea9aea9a9a9aeaea9a9a99a9a9aa99a9a9adedf9a9a9aa99a9a9a8e8e9ebba6888282828282829792848e81adad8882828282a188829792968e819e8592a450845c8882828297b693849f859284bbbcab8aac85a4929290b3849d81818592927092bebebf929292848abc
000000000000000000000000000000008e8e5d5e5f8e8e8e8e8e8e8e8e8e8e8eacad8f8e8dbda7eeefa8998d8e818fad88828282829792929290a4929292848f82828297b392a492969793929292848b8195e69292968297509292929392848085ba9682828282829792929292928481bbab859292929293929092a492849e9f
000000000000000000000000000000009e9f6d6e6f2f4a818f8081bbbca081af819f8e8b8cbdaf9230af998c8bad8ea18550909292ba9292b386838387b98480911092929092a4929292928687ba8481a185baa4929390929286838387b9848085928a9270929290b692928687b984818181958792868383838383e692968281
000000000000000000000000000000009e9d81af9f2e5aa18e8e9f8181818181ad8089898dbda8920fa7998dad9e8a8195838383838792868381adad85a3848e838383879292a492868383a1958381808095879392929292b3849f6985a3848095838383838383838383838b85a3849f8f81a695838181a0bc8185ba9292b384
00000000000000000000000000000000818f81818181af8f818b818181af8181818e81ad8cbebf9494bebe8c819c81ad816b6b9e9f958381bb81ad8b85a2849e80808f9583838383818f808180808f8080809583838383838381679e85a28480819e8bac818aa1af9f819c8185a284818e8a8181ac9caf818f8f958383838381
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cefe0000000000000000000000000000000000000000000000
9a9aa99a9a9a9aaeae9a9a9aaecccda9aea99a9a9a9a9aa99aa99a9a9aaea9ae9aaea99a9aaeae9a4d4e4fae9aa9ae9aa99aaea99a9aa99a9a9a9a9a9a9aaea99acccd9aa9a9ae9a9a9a9a9aa99a9a9a9ac99aa99aa9ae9a9a9a9aa9e9eaa9ae9a9a9aa99a9a9adeff9a9a9aa99a9a9aaea9ae9a9aaeaeae9aaea9a99a9a9a9a
adad8eac9c9eaf8e8e9c8baf8edcdd8e8e8e88828282828eca8e8882818e8e8e818e8e63648e8ec85d7e7f8ec88e8e4c8e818e8ea69f8ec8c87c888281eb8e8eaddcddad8e8e8e88828182818e888282cb8ccb8e9f8e8e9c8882ad8ef9fa8e8eacad8f8e8dbda6eeefa6998d8e818fad8e8e8e9c8a8e8e8ebb8e8e8e9caf9e81
828282828282828282828282a6eceda69d9f85709292b384da8897b39681a66b8282828281a6a0a17d6e6f9fa6af7c5ceb888282828282816b6c85ba84fba1afa6eceda688828297755975968185a3a2dba6db8882a188829775968282828282819f8e8b8cbdaf9292af998c8bad8ea188828282828282828282afbc8badadaf
91929290929292939392929096afaf81a1fc958387939284a68592924384819f911092939682828282829f88828282affb8592939392909681889792968281eb8188828297929392f756f7929697b986adadad855984859292f792939392a3a2ad8089898dbda692a3a6998dad9e8a818592929292ba92bd8d9981cccda69f81
911092b3929292929292ba9292848aac82828282979292968297909292846b8b879292929292939392928485b3b3b3848297bae4e5e6929896979392927084fb80859392a4509292f7f7f7929392928488828297569697b9bebebebebebebf86a18e81ad8cbebebf94bebe8c819c81ad85759392939292bd8c9981dcdd81acaf
83838792929086838792929250849c8a911092939292939292929292ba849e8185929092ac92868387438485bf92be8491109290b39292a5929092929086a6af8085b392ac92929092929292bebe86ad85937092f750929292909292ba939384888282828281a185929682af8882828185929293a49292bfb69981ecedaf8a81
8f9e8592929284af85b3bebebf96819e8383838792909292a492939290847c8185ba92928a92968297929697909250848387bebebfa4929892868792929682818085b69292a49292928a9292bdba84cb8590bebebebebf929c8ae4e5e69292848575ba93508459859292928485ba7584859292b39292898994bf96828282819e
8e81855092a49682979292bcacad848181ac9c8592928aac8683838383814c8085bebebebf9292909292ba9292b69284a68593939292989192969792929050848e85bebebf929cac9cac8a92bf9284db8592ba9392b39293929250927092928485bebf92928456958387b9969792869f95838792929292929292929292928489
81a695838794bd759994bdab8dad84adabbcbc8590929c8a9682828263645c8e85909250ac9c928687bebebf929092848185b3929250a592929093928687b996a1857092909292b392939292929284a18592e4e5e6adadadad928989898992848593b392929682828297929290928480898995879292929292929292927584ad
888282829794bf92bf94bdbc8cad849d81af4c85b3929292939292439682828185ba9292929292848593929392929284eb85929290929891b39292929685a3a2fc85bebebfbabebebe868383875084ad8592709050929292929292b3ba9292848592909292939292b39290929292848e828282979292b392929292929292849d
857092929292b3925092bebebebf8481a14b5c85bebebebf9286879292939384859292929c8a929697ac92868387b996fb85bebf92bebebebebf92bebe9583838297939292929293929682829792968197bebfe4e5e5e692bebebebebebf86818592929292929292929292929270848a91109292929292929292929292928481
859292ba92928687b986838383839e81815b8185ba929292929697928687b9848570929293929292929392844c85a3a2af85b6439292ac9350929392ba844b4b911092a48aac9ca49292929092ba92849110939392b3929293927592b69984ad979cac8aa4adadadbebf43bebe86cbaf87929292929286838387b98683838181
9583838383839e85a384a0af8f8f81819e81a69583838387929092928485a38495838383838383838383834b5c958383a69583838383838383838383839d5b5b83879292924392929292b386838383818383838383838387bebebebebebf84ad911092909292b392b692ba929384db8195838383838381a6af85a3848f8f8181
819e8bac819c8185a284819f8e8e819f819e819f817c8195838383838185a2848fa6af8f8f6967818b7c9d5ba081a68f81bcbc818bbbbb81a6819e819fa16364819583838383838383838381ad8b9f8180a1808f818989958383838383838081838383838383838383838383839e8080819e8bac81ac81819f85a2848e8e81bf
__sfx__
00250000291122911228112281122911229112291122b112291122911228112291122511225112261122811229112291122911229112291122911229112291122611226112261122611228112281122411224112
00250000261102611026110261102611026110261102511026110261102611024110211102111022110251102611023110211101f11021110211101f1102111022110221102111022110211101f1102111022110
012500001321013210162101a2101d2101a210162101521016210162101a2101621015210192101c210212101a2151a2151a2151a2151d2151d2151a2151a2151621016210162101621015215132151521016210
01250000291122911228112281122911229112291122b112291122911228112291122511221112251122811229112291122911229112281152611525115231152b1122b1122b1122b11229115281152611525115
0125000026110261102611026110261102611026110251102611026110261102411021110211102211025110261152511523115211152311023110231101f1102411522115211151f11521110211102111021110
012500001a2101a210162101a2101d2101a210162101521016210162101a2101621015210192101c210212101a2101a2101a2101a210172101721015210152101821018210182101821016210162101c2101c210
01250000261122611226000261122411224000241122611222112221122200022112261122511222112211121f11221112221122511221112221121f1121d1122111221112210002111221000210122110221112
012500001d1101f1102111022110211101f1101d1101c1101f1101f1101d1101c1101a1101a1101a1101c1101d1121d1121c1121c1121a1121a11219112191121a1121a1121a1121a1121d1121d1122111221112
01250000112101121011210112101121511215112101121010210102101021510215102101021010215102150d2100d2100e2100e210102101021011210112100e2100e210210000e210220000e210250000e210
011e00002812428124271242812424124241242812424124231242312421124231242412423124241242712428124281242712428124241242412423124241242712427124271242712428124281242812428124
011e000024410234102300023000204102141023000230001b4101c410230001f00021410204101e4101c4102341024410230002300020410214102300023000204101e4101b4101c410204101e4101c4101a410
011e00001521015210142101521015210152102300015210142101421012210142101421014210122101421015210152101421015210152101521023000152101721017210172101721016210162101621016210
011e00002812428124271242812424124241242812424124231242312421124231242412423124241242712428124281242712428124241242412423124211242312423124231242312426124261242612426124
011e000024410234102300023000204102141023000230001b4101c410230001f00021410204101e4101c4102341024410230002300020410214102300023000204101e4101c4101e410214101f4101d4101b410
011e00001521015210142101521015210152102300015210142101421012210142101421014210122101421015210152101421015210152101521023000152101421014210142101421013210132101321013210
011e000026122271222612224122261222612227122241222612226122271222412223122231221f1221f12223122241222312221122231222312224122211222312223122241222112226122261222712227122
011e00001f4101f4101f4101d4101f410204101f4101d4101b4101b4101b4101a4101b4151a4151b4151d4151f4101f4101f4101e4101f4101e4101c4101b4101e4101e4101e4101f41021410214102341023410
011e00000c4100e4100b4100c4100f4100f4100e4100e4100c4100c4100c4100c4100b4100b410094100f410104101041010410104100f41510415134151241510410104100e4100e41007410074100741007410
011e000026122271222612224122261222612227122241222612226122271222412223122231221f1221f12223122241222312224122261222112223122241222612226122261222612227122271222712227122
011e00001f4101f4101f4101d4101f410204101f4101d4101b4101b4101b4101a4101b4151a4151b4151d4151f4101f4101f4101e4101f4101e4101f410214101e4101e4101e4101e41021410214102141021410
011e00000c4100e4100b4100c4100f4100f4100e4100e4100c4100c4100c4100c4100b4100b410094100f410104100f410104101241013415124150f4150c4150b4100b4100b4100b4100c4100c4100c4100c410
011800002752027520275202752027520275202652026520265202452026520275202e5202e5202e5202e5202e5202e5202d5202d5202d5202b5242d5242e5242a5242a5242a5242d5202d5202d5202752027520
011800001f11500000201151f1150c000201152311500000201151f11520115231152411500000201152311500000241152711027110271102611026110261102411024110241102311424114261142011420114
0118000018410184101841017410000000000018410184101841017410184101a4101b4101b4101b4101a41000000000001d4101d4101d4101b4101a410184101a4101a4101a410184101a4101b4101741017410
011800002752026524275242b5242652426524275242652426524245242b5242b5242b5242952429524295242752027520275202752027520275202652026520265202452026520275202e5202e5202e5202e520
01180000201141f11420114231141f1141f114201141f1141f1141d1142411424114241142311423114231141f11500000201151f11500000201152311500000201151f115201152311524115000002011523115
0118000017410164101a4101d4101b4101b410184101a4101a4101641014410144101441013410134101341018410184101841017410000000000018410184101841017410184101a4101b4101b4101b4101a410
011800002e5202e5202d5202d520000002d5242b5242a5242d5242d5242d5242752027520275202452024520245202452426524275242652426524275242a5242a524265242b5242b5242b5242a5242752426524
0118000000000241152711027110271102611026110261102411024110241102311424114231142011420114201141f11420114231141f1141f1142011423114231141f114241142411424114181142311420114
011800001a410000001b4101b4101b4101a41018410174101a4101a4101a4101841017410144101341013410000001341011410134101441014410174101a4101a41017410184101841000000184101741013410
011800002b5242b5202b5202a5202a5202a5202752027520275202652026520265202452424524265242452424524265242752427524265242452424524265242552425524275242552425524275242852428524
0118000027114271102711026110261102611024110241102411023110231102311000010000101d11500000000001d11500000000001d11500000000001d11500000000001e11500000000001e1150000000000
011800001841018410184101741017410174101441014410144101341013410134101441514415000001441500000144151441514415000001441014410144101541515415000001541500000154151541515415
01181c1f2752425524255242752426524265242852426524265242852427524275242952427524275242952428524285242a52429524295242b5242a5242a5242c52429524265242052429500295002950029500
01181c1f1e11500000000001e1151d1151d015000001d1151d115000001e1151e115000001e1151e115000001d1101d1101e1151d1101d1101f1151e1101e1102011021110201101e11022100221002210022100
01181c1f000001541015410154101641516415000001641016410164101741517425000001741017410174101641016410164101741017410174101841018410184101a410174101441013400134001340013400
01100000265202652026520265202952029520285202852028520265202552025520265202652021520215201f5201f5202252022520225202252022520225202152021520215202152022520225202152021520
011000001d1101d1101c1101c1101d1101d1101f1101f1101f1101f1101f1101f1101d1101d1101d1101d1101d1101d1101c1101c1101a1101a11019110191101a1101a1101a1101a1101a1101a1101a1101a110
011000001a1101a1101a1101a1101a1101a1101911019110191101911019110191101611016110161101611016110161101511015110151101511015110151101311013110131101311015110151101611016110
011000001f5201f5201d5201d5201f5201f5201f5201f5201f5201f5202152021520215202152025520255202652026520265202652029520295202b5202b5202b520295202b5202b5202d5202d5202d5202b520
011000001a1101a1101a1101a1101a1101a1101c1101c1101d1101d1101c1101c1101d1101d1101f1101f11021110211102111021110211102111022110221102211022110221102211024110241102411024110
01100000161101611016110161101511015110151101511015110151101911019110191101911015110151101a1101a1101a1101a1101a1101a1101c1101c1101c1101c1101c1101c1101d1101d1101d1101d110
011000002952028520295202952029520295202952029520285202852028520295202852026520255202552026520265202852028520265202652026520265202652026520265202652026520265202652026520
011000002411024110261102611026110261102611026110241102411024110241102411024110221102211021110211101f1101f1101d1101d1101d1101d1101d1101d1101d1101d1101d1101d1101d1101d110
011000001d1101d1101c1101c1101c1101c1101c1101c1101d1101d1101d1101d1101d1101d11019110191101a1101a1101c1101c1101a1101a1101a1101a1101a1101a1101a1101a1101a1101a1101a1101a110
011000002d5202d5202d5202d5202e5202e5202d5202d5202d5202d5202e5202e5202d5202d5202d5202d5202b5202b520295202952029520295202b5202b5202d5202d5202d5202b52029520295202852028520
01100000221102211021110211101f1101f1101d1101d1101f1101f1101f1101f1101c1101c1101d1101d1101d1101d1101a1101a1101c1101c1101c1101c1101d1101d1101d1101d1101d1101d1101c1101c110
011000001311013110131101311013110131101611016110161101611016110161101511015110151101511015110151101311013110131101311011110111101011010110101101011010110101101511015110
01100000285202852029520295202d5202d5202d5202d5202d5202d5202b5202b5202b5202b52026520265202d5202d5202d5202d5202d5202d5202e5202e5202e5202e5202e5202e5202e5202e5202d5202d520
011000001f1101f1101d1101d1101c1101c1101c1101c1101c1101c1101a1101a1101a1101a1101811018110221102211021110211101f1101f1101d1101d1101f1101f1101d1101d1101c1101c1101d1101d110
0110000015110151101311013110111101111011110111101111011110101101011010110101100e1100e11013110131101311013110131101311016110161101611016110161101611015110151101511015110
011000002e5202e5202d5202d5202d5202d5202b5202b5202d5202d5202d5202b5202952028520295202952028520285202552025520265202652026520265202652026520265202652026520265202952029520
011000001c1101c1101a1101a1101a1101a11018110181101a1101a1101a1101a1101a1101a1101c1101c1101c1101c1101c1101c1101d1101d1101d1101d1101d1101d1101d1101d1101d1101d1101d1101d110
0110000015110151101311013110131101311011110111101011010110101101011010110101100d1100d1100d1100d1100d1100d1100e1100e1100e1100e1100e1100e1100e1100e1100e1100e1100e1100e110
01100000265202652026520265202652026520265202652026520265202952029520285202852028520285202852028520285202852028520285202b5202b5202d5202d5202d5202d5202d5202d5202b5202b520
011000001d1101d1101d1101d1101d1101d1101d1101d1101d1101d1101f1101f1102111021110211102111021110211102111021110211102111021110211101f1101f1101f1101f1101f1101f1101d1101d110
011000001011010110101101011010110101101011010110101101011010110101101111011110111101111011110111101111011110111101111011110111101011010110111101111010110101100e1100e110
010800002b5202b5202b5202b5202b5202b5202b5202b520295202952029520295202952029520295202952029520295202952029520285202852028520285202852028520285202852025520255202552025520
010800001d1101d1101d1101d1101d1101d1101d1101d1101c1101c1101c1101c1101c1101c1101c1101c1101c1101c1101c1101c110191101911019110191101911019110191101911019110191101911019110
01080000101101011010110101100e1100e1100e1100e1100d1100d1100d1100d1100e1100e1100e1100e1100d1100d1100d1100d110091100911009110091100911009110091100911009110091100911009110
011500001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000
010a000019623196311b6311164111621085610275506745027450874508735057250e02310041180311b0311f02109073056410b035070551004504075170550000000000000000000000000000000000000000
010f00001067307673227741a764127741775426774026530e0230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e00001066301621046310463010673091731f7641c77421754247741c7642b7742b7302b710000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 00010244
00 03040544
02 06070844
01 090a0b44
00 0c0d0e44
00 0f101144
02 12131444
01 15161744
00 18191a44
00 1b1c1d44
00 1e1f2044
02 2122233c
01 24252644
00 27282944
00 2a2b2c44
00 2d2e2f44
00 30313244
00 33343544
00 36373844
02 393a3b44
