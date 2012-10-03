all: hessian.d64 hessian.d81

clean:
	del *.bin
	del music\*.bin
	del sfx\*.sfx
	del *.pak
	del *.prg
	del *.tbl
	del *.d64
	del *.d81
	del hessian
	del 0?
	del 1?
	del 2?
	del 3?
	del 4?
	del 5?
	del 6?
	del 7?

hessian.d64: boot.prg loader.pak main.pak testmusic.pak testlev.pak common.pak weapon.pak player.pak
	makedisk hessian.d64 hessian.seq HESSIAN___________HE_2A 12

hessian.d81: hessian.d64 hessiand81.seq
	c1541 < hessiand81.seq

boot.prg: boot.s kernal.s memory.s loader.pak
	dasm boot.s -oboot.prg

loader.pak: kernal.s loader.s ldepack.s macros.s memory.s
	dasm loader.s -oloader.bin -sloader.tbl -f3
	symbols loader.tbl loadsym.s loadsym.txt
	lpack loader.bin ldata.pak
	dasm ldepack.s -oldepack.bin -f3
	invert ldepack.bin ldepack.bin
	filejoin ldepack.bin+ldata.pak loader.pak

sfx/pistol.sfx: sfx/pistol.ins
	ins2nt2 sfx/pistol.ins sfx/pistol.sfx

sfx/explosion.sfx: sfx/explosion.ins
	ins2nt2 sfx/explosion.ins sfx/explosion.sfx

sfx/throw.sfx: sfx/throw.ins
	ins2nt2 sfx/throw.ins sfx/throw.sfx

sfx/melee.sfx: sfx/melee.ins
	ins2nt2 sfx/melee.ins sfx/melee.sfx

sfx/punch.sfx: sfx/punch.ins
	ins2nt2 sfx/punch.ins sfx/punch.sfx

sfx/reload.sfx: sfx/reload.ins
	ins2nt2 sfx/reload.ins sfx/reload.sfx

sfx/cockfast.sfx: sfx/cockfast.ins
	ins2nt2 sfx/cockfast.ins sfx/cockfast.sfx

sfx/powerup.sfx: sfx/powerup.ins
	ins2nt2 sfx/powerup.ins sfx/powerup.sfx

sfx/select.sfx: sfx/select.ins
	ins2nt2 sfx/select.ins sfx/select.sfx

sfx/pickup.sfx: sfx/pickup.ins
	ins2nt2 sfx/pickup.ins sfx/pickup.sfx

sfx/damage.sfx: sfx/damage.ins
	ins2nt2 sfx/damage.ins sfx/damage.sfx

sfx/death.sfx: sfx/death.ins
	ins2nt2 sfx/death.ins sfx/death.sfx

main.pak: actor.s actordata.s ai.s aidata.s bullet.s data.s file.s init.s item.s itemdata.s level.s macros.s \
	main.s math.s memory.s panel.s physics.s player.s raster.s screen.s sound.s sounddata.s sprite.s \
	text.s weapon.s weapondata.s loader.pak bg/scorescr.chr sfx/pistol.sfx sfx/explosion.sfx sfx/throw.sfx \
	sfx/melee.sfx  sfx/punch.sfx sfx/reload.sfx sfx/cockfast.sfx sfx/powerup.sfx sfx/select.sfx \
	sfx/pickup.sfx sfx/damage.sfx sfx/death.sfx
	dasm main.s -omain.bin -smain.tbl -f3
	pack2 main.bin main.pak

testmusic.pak: music/ninjatr2.d64
	d642prg music/ninjatr2.d64 testmusic.bin music/testmusic.bin -h
	pack2 music/testmusic.bin testmusic.pak

testlev.pak: testlev.s bg/testlev.map bg/testlev.blk bg/testlev.chi bg/testlev.chc bg/testlev.chr bg/testlev.lva
	dasm testlev.s -otestlev1.bin -f3
	pack2 testlev1.bin testlev1.pak
	pchunk2 bg/testlev.map testlev2.pak
	pchunk2 bg/testlev.blk testlev3.pak
	pack2 bg/testlev.chr testlev4.pak
	filejoin testlev1.pak+testlev2.pak+testlev3.pak+testlev4.pak testlev.pak

common.pak: spr/common.spr
	pchunk2 spr/common.spr common.pak

weapon.pak: spr/weapon.spr
	pchunk2 spr/weapon.spr weapon.pak

player.pak: spr/player.spr
	pchunk2 spr/player.spr player.pak
