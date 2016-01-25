all: hessian.d64 hessian.sid

clean:
	-rm *.bin
	-rm music/*.bin
	-rm sfx/*.sfx
	-rm *.pak
	-rm *.prg
	-rm *.tbl
	-rm *.d64
	-rm hessian
	-rm 0?
	-rm 1?
	-rm 2?
	-rm 3?
	-rm 4?
	-rm 5?
	-rm 6?
	-rm 7?
	-rm 8?
	-rm 9?
	-rm a?
	-rm b?
	-rm c?
	-rm d?
	-rm e?
	-rm f?

hessian.d64: hessian.seq loader.prg main.pak options.bin emptysave.bin savelist.bin logo.pak upgrade.pak \
	music00.pak music01.pak music02.pak music03.pak music04.pak music05.pak music06.pak music07.pak \
	music08.pak music09.pak music10.pak music11.pak music12.pak \
	script00.pak script01.pak script02.pak script03.pak script04.pak script05.pak script06.pak script07.pak \
	script08.pak script09.pak script10.pak script11.pak script12.pak script13.pak script14.pak script15.pak \
	script16.pak script17.pak script18.pak script19.pak script20.pak script21.pak script22.pak script23.pak \
	script24.pak script25.pak script26.pak script27.pak script28.pak script29.pak script30.pak script31.pak \
	script32.pak \
	charset00.pak charset01.pak charset02.pak charset03.pak charset04.pak charset05.pak charset06.pak charset07.pak \
	charset08.pak charset09.pak charset10.pak charset11.pak charset12.pak charset13.pak charset14.pak \
	level00.pak level01.pak level02.pak level03.pak level04.pak level05.pak level06.pak level07.pak level08.pak \
	level09.pak level10.pak level11.pak level12.pak level13.pak level14.pak level15.pak \
	sprplayert.pak sprplayerb.pak sprplayerta.pak sprplayerba.pak \
	sprsmallrobots.pak sprhazards.pak sprhazards2.pak spranimals.pak sprmediumrobots.pak sprguard.pak sprheavyguard.pak \
	sprcombatrobot.pak sprlargewalker.pak sprlargetank.pak sprhighwalker.pak sprhazmat.pak sprserver.pak sprsecuritychief.pak \
	sprrotordrone.pak sprlargespider.pak sprscientist.pak sprhacker.pak
	maked64 hessian.d64 hessian.seq HESSIAN___________HE_2A 10
	reorder hessian.d64

loader.prg: kernal.s loader.s loadsym.txt ldepacksym.txt ldepack.s boot.s macros.s memory.s
	dasm ldepack.s -oloader.prg -sldepack.tbl -f3
	symbols ldepack.tbl ldepacksym.s ldepacksym.txt
	dasm loader.s -oloader.bin -sloader.tbl -f3
	symbols loader.tbl loadsym.s loadsym.txt
	pack2 loader.bin loader.pak
	dasm ldepack.s -oloader.prg -sldepack.tbl -f3
	dasm boot.s -oboot.prg

sfx/pistol.sfx: sfx/pistol.ins
	ins2nt2 sfx/pistol.ins sfx/pistol.sfx

sfx/shotgun.sfx: sfx/shotgun.ins
	ins2nt2 sfx/shotgun.ins sfx/shotgun.sfx

sfx/autorifle.sfx: sfx/autorifle.ins
	ins2nt2 sfx/autorifle.ins sfx/autorifle.sfx

sfx/sniperrifle.sfx: sfx/sniperrifle.ins
	ins2nt2 sfx/sniperrifle.ins sfx/sniperrifle.sfx

sfx/minigun.sfx: sfx/minigun.ins
	ins2nt2 sfx/minigun.ins sfx/minigun.sfx

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

sfx/cockshotgun.sfx: sfx/cockshotgun.ins
	ins2nt2 sfx/cockshotgun.ins sfx/cockshotgun.sfx

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

sfx/flamer.sfx: sfx/flamer.ins
	ins2nt2 sfx/flamer.ins sfx/flamer.sfx

sfx/reloadflamer.sfx: sfx/reloadflamer.ins
	ins2nt2 sfx/reloadflamer.ins sfx/reloadflamer.sfx

sfx/launcher.sfx: sfx/launcher.ins
	ins2nt2 sfx/launcher.ins sfx/launcher.sfx

sfx/bazooka.sfx: sfx/bazooka.ins
	ins2nt2 sfx/bazooka.ins sfx/bazooka.sfx

sfx/reloadbazooka.sfx: sfx/reloadbazooka.ins
	ins2nt2 sfx/reloadbazooka.ins sfx/reloadbazooka.sfx

sfx/heavymelee.sfx: sfx/heavymelee.ins
	ins2nt2 sfx/heavymelee.ins sfx/heavymelee.sfx

sfx/emp.sfx: sfx/emp.ins
	ins2nt2 sfx/emp.ins sfx/emp.sfx

sfx/laser.sfx: sfx/laser.ins
	ins2nt2 sfx/laser.ins sfx/laser.sfx

sfx/plasma.sfx: sfx/plasma.ins
	ins2nt2 sfx/plasma.ins sfx/plasma.sfx

sfx/splash.sfx: sfx/splash.ins
	ins2nt2 sfx/splash.ins sfx/splash.sfx

sfx/object.sfx: sfx/object.ins
	ins2nt2 sfx/object.ins sfx/object.sfx

sfx/footstep.sfx: sfx/footstep.ins
	ins2nt2 sfx/footstep.ins sfx/footstep.sfx

sfx/roll.sfx: sfx/roll.ins
	ins2nt2 sfx/roll.ins sfx/roll.sfx

sfx/jump.sfx: sfx/jump.ins
	ins2nt2 sfx/jump.ins sfx/jump.sfx

sfx/animaldeath.sfx: sfx/animaldeath.ins
	ins2nt2 sfx/animaldeath.ins sfx/animaldeath.sfx

sfx/generator.sfx: sfx/generator.ins
	ins2nt2 sfx/generator.ins sfx/generator.sfx

sfx/radio.sfx: sfx/radio.ins
	ins2nt2 sfx/radio.ins sfx/radio.sfx

main.pak: intro.s actor.s actordata.s ai.s aidata.s aligneddata.s bullet.s enemy.s file.s init.s input.s item.s itemdata.s level.s \
	macros.s main.s math.s memory.s panel.s paneldata.s physics.s player.s raster.s screen.s script.s \
	sound.s sounddata.s sprite.s text.s weapon.s weapondata.s loader.prg bg/scorescr.chr bg/world.s sfx/pistol.sfx sfx/shotgun.sfx \
	sfx/autorifle.sfx sfx/sniperrifle.sfx sfx/minigun.sfx sfx/explosion.sfx sfx/throw.sfx sfx/melee.sfx sfx/punch.sfx sfx/reload.sfx \
	sfx/cockfast.sfx sfx/cockshotgun.sfx sfx/powerup.sfx sfx/select.sfx sfx/pickup.sfx sfx/damage.sfx sfx/death.sfx \
	sfx/flamer.sfx sfx/reloadflamer.sfx sfx/launcher.sfx sfx/bazooka.sfx sfx/reloadbazooka.sfx sfx/heavymelee.sfx \
	sfx/emp.sfx sfx/laser.sfx sfx/plasma.sfx sfx/splash.sfx sfx/object.sfx sfx/footstep.sfx sfx/roll.sfx sfx/jump.sfx \
	sfx/animaldeath.sfx sfx/generator.sfx sfx/radio.sfx pics/covert.iff pics/loadpic.iff loadermusic.bin
	pic2chr pics/covert.iff covert.chr -b11 -m12 -n13 -c -s -x30 -y4
	pic2chr pics/covert.iff covertscr.dat -b11 -m12 -n13 -x30 -y4 -t -c
	gfxconv pics/loadpic.iff loadpic.dat -r -b0 -o -nc -ns
	gfxconv pics/loadpic.iff loadpicscr.dat -r -b0 -o -nc -nb
	gfxconv pics/loadpic.iff loadpiccol.dat -r -b0 -o -nb -ns
	filesplit spr/common.spr sprcommon.hdr 2 1
	filesplit spr/common.spr sprcommon.dat 3
	filesplit spr/item.spr spritem.hdr 2 1
	filesplit spr/item.spr spritem.dat 3
	filesplit spr/weapon.spr sprweapon.hdr 2 1
	filesplit spr/weapon.spr sprweapon.dat 3
	dasm main.s -omain.bin -smain.tbl -f3
	symbols main.tbl mainsym.s
	symbols main.tbl >pagecross.txt
	dasm intro.s -ointro.bin -f3
	pack2 intro.bin main_1.pak
	pack2 loadpic.dat main_2.pak
	pack2 loadpicscr.dat main_3.pak
	pack2 loadpiccol.dat main_4.pak
	pack2 main.bin main_5.pak
	filejoin main_1.pak+main_2.pak+main_3.pak+main_4.pak+main_5.pak main.pak

emptysave.bin: emptysave.s mainsym.s
	dasm emptysave.s -oemptysave.bin -f3

options.bin: options.s mainsym.s
	dasm options.s -ooptions.bin -f3

savelist.bin: savelist.s mainsym.s
	dasm savelist.s -osavelist.bin -f3

logo.pak: pics/logo.iff logo.s
	pic2chr pics/logo.iff logo.chr -m14 -n15 -x24 -y7 -c -s
	pic2chr pics/logo.iff logoscr.dat -m14 -n15 -x24 -y7 -t
	dasm logo.s -ologo.bin -f3
	pack2 logo.bin logo.pak
	
upgrade.pak: spr/sight.spr bg/upgrade.chr upgrade.s
	dasm upgrade.s -oupgrade.bin -f3
	pack2 upgrade.bin upgrade.pak

script00.pak: script00.s memory.s mainsym.s
	dasm script00.s -oscript00.bin -f3
	pack2 script00.bin script00.pak

script01.pak: script01.s memory.s mainsym.s
	dasm script01.s -oscript01.bin -f3
	pack2 script01.bin script01.pak

script02.pak: script02.s memory.s mainsym.s
	dasm script02.s -oscript02.bin -f3
	pack2 script02.bin script02.pak

script03.pak: script03.s memory.s mainsym.s
	dasm script03.s -oscript03.bin -f3
	pack2 script03.bin script03.pak

script04.pak: script04.s memory.s mainsym.s
	dasm script04.s -oscript04.bin -f3
	pack2 script04.bin script04.pak

script05.pak: script05.s memory.s mainsym.s
	dasm script05.s -oscript05.bin -f3
	pack2 script05.bin script05.pak

script06.pak: script06.s memory.s mainsym.s
	dasm script06.s -oscript06.bin -f3
	pack2 script06.bin script06.pak

script07.pak: script07.s memory.s mainsym.s
	dasm script07.s -oscript07.bin -f3
	pack2 script07.bin script07.pak

script08.pak: script08.s memory.s mainsym.s
	dasm script08.s -oscript08.bin -f3
	pack2 script08.bin script08.pak

script09.pak: script09.s memory.s mainsym.s
	dasm script09.s -oscript09.bin -f3
	pack2 script09.bin script09.pak

script10.pak: script10.s memory.s mainsym.s
	dasm script10.s -oscript10.bin -f3
	pack2 script10.bin script10.pak

script11.pak: script11.s memory.s mainsym.s
	dasm script11.s -oscript11.bin -f3
	pack2 script11.bin script11.pak

script12.pak: script12.s memory.s mainsym.s
	dasm script12.s -oscript12.bin -f3
	pack2 script12.bin script12.pak

script13.pak: script13.s memory.s mainsym.s
	dasm script13.s -oscript13.bin -f3
	pack2 script13.bin script13.pak

script14.pak: script14.s memory.s mainsym.s
	dasm script14.s -oscript14.bin -f3
	pack2 script14.bin script14.pak

script15.pak: script15.s memory.s mainsym.s
	dasm script15.s -oscript15.bin -f3
	pack2 script15.bin script15.pak

script16.pak: script16.s memory.s mainsym.s
	dasm script16.s -oscript16.bin -f3
	pack2 script16.bin script16.pak

script17.pak: script17.s memory.s mainsym.s
	dasm script17.s -oscript17.bin -f3
	pack2 script17.bin script17.pak

script18.pak: script18.s memory.s mainsym.s
	dasm script18.s -oscript18.bin -f3
	pack2 script18.bin script18.pak

script19.pak: script19.s memory.s mainsym.s
	dasm script19.s -oscript19.bin -f3
	pack2 script19.bin script19.pak

script20.pak: script20.s memory.s mainsym.s
	dasm script20.s -oscript20.bin -f3
	pack2 script20.bin script20.pak

script21.pak: script21.s memory.s mainsym.s
	dasm script21.s -oscript21.bin -f3
	pack2 script21.bin script21.pak

script22.pak: script22.s memory.s mainsym.s
	dasm script22.s -oscript22.bin -f3
	pack2 script22.bin script22.pak

script23.pak: script23.s memory.s mainsym.s
	dasm script23.s -oscript23.bin -f3
	pack2 script23.bin script23.pak

script24.pak: script24.s memory.s mainsym.s
	dasm script24.s -oscript24.bin -f3
	pack2 script24.bin script24.pak

script25.pak: script25.s memory.s mainsym.s
	dasm script25.s -oscript25.bin -f3
	pack2 script25.bin script25.pak

script26.pak: script26.s memory.s mainsym.s
	dasm script26.s -oscript26.bin -f3
	pack2 script26.bin script26.pak

script27.pak: script27.s memory.s mainsym.s
	dasm script27.s -oscript27.bin -f3
	pack2 script27.bin script27.pak

script28.pak: script28.s memory.s mainsym.s
	dasm script28.s -oscript28.bin -f3
	pack2 script28.bin script28.pak

script29.pak: script29.s memory.s mainsym.s
	dasm script29.s -oscript29.bin -f3
	pack2 script29.bin script29.pak

script30.pak: script30.s memory.s mainsym.s
	dasm script30.s -oscript30.bin -f3
	pack2 script30.bin script30.pak

script31.pak: script31.s memory.s mainsym.s
	dasm script31.s -oscript31.bin -f3
	pack2 script31.bin script31.pak

script32.pak: script32.s memory.s mainsym.s
	dasm script32.s -oscript32.bin -f3
	pack2 script32.bin script32.pak

loadermusic.bin: music/hessianmusic.d64
	d642prg music/hessianmusic.d64 loader.bin loadermusic.bin -h

loadermusic2.bin: music/hessianmusic.d64
	d642prg music/hessianmusic.d64 loader2.bin loadermusic2.bin -h

music00.pak: music/hessianmusic.d64
	d642prg music/hessianmusic.d64 gameover.bin music00.bin -h
	pack2 music00.bin music00.pak

music01.pak: music/hessianmusic.d64
	d642prg music/hessianmusic.d64 title.bin music01.bin -h
	pack2 music01.bin music01.pak

music02.pak: music/hessianmusic.d64
	d642prg music/hessianmusic.d64 destruction.bin music02.bin -h
	pack2 music02.bin music02.pak

music03.pak: music/hessianmusic.d64
	d642prg music/hessianmusic.d64 victory.bin music03.bin -h
	pack2 music03.bin music03.pak

music04.pak: music/hessianmusic.d64
	d642prg music/hessianmusic.d64 mystery.bin music04.bin -h
	pack2 music04.bin music04.pak

music05.pak: music/hessianmusic.d64
	d642prg music/hessianmusic.d64 outside.bin music05.bin -h
	pack2 music05.bin music05.pak

music06.pak: music/hessianmusic.d64
	d642prg music/hessianmusic.d64 offices.bin music06.bin -h
	pack2 music06.bin music06.pak

music07.pak: music/hessianmusic.d64
	d642prg music/hessianmusic.d64 maintenance.bin music07.bin -h
	pack2 music07.bin music07.pak

music08.pak: music/hessianmusic.d64
	d642prg music/hessianmusic.d64 caves.bin music08.bin -h
	pack2 music08.bin music08.pak

music09.pak: music/hessianmusic.d64
	d642prg music/hessianmusic.d64 throne.bin music09.bin -h
	pack2 music09.bin music09.pak

music10.pak: music/hessianmusic.d64
	d642prg music/hessianmusic.d64 hideout.bin music10.bin -h
	pack2 music10.bin music10.pak

music11.pak: music/hessianmusic.d64
	d642prg music/hessianmusic.d64 nether.bin music11.bin -h
	pack2 music11.bin music11.pak

music12.pak: music/hessianmusic.d64
	d642prg music/hessianmusic.d64 assault.bin music12.bin -h
	pack2 music12.bin music12.pak

hessian.sid: hessiansid.s music00.bin music01.bin music02.bin music03.bin music04.bin music05.bin music06.bin music07.bin \
	music08.bin music09.bin music10.bin music11.bin music12.bin loadermusic2.bin
	dasm hessiansid.s -ohessian.sid -f3

charset00.pak: charset00.s memory.s bg/world00.blk bg/world00.chi bg/world00.chc bg/world00.chr
	dasm charset00.s -ocharset00_1.bin -f3
	pack2 charset00_1.bin charset00_1.pak
	pchunk2 bg/world00.blk charset00_2.pak
	filejoin charset00_1.pak+charset00_2.pak charset00.pak

charset01.pak: charset01.s memory.s bg/world01.blk bg/world01.chi bg/world01.chc bg/world01.chr
	dasm charset01.s -ocharset01_1.bin -f3
	pack2 charset01_1.bin charset01_1.pak
	pchunk2 bg/world01.blk charset01_2.pak
	filejoin charset01_1.pak+charset01_2.pak charset01.pak

charset02.pak: charset02.s memory.s bg/world02.blk bg/world02.chi bg/world02.chc bg/world02.chr
	dasm charset02.s -ocharset02_1.bin -f3
	pack2 charset02_1.bin charset02_1.pak
	pchunk2 bg/world02.blk charset02_2.pak
	filejoin charset02_1.pak+charset02_2.pak charset02.pak

charset03.pak: charset03.s memory.s bg/world03.blk bg/world03.chi bg/world03.chc bg/world03.chr
	dasm charset03.s -ocharset03_1.bin -f3
	pack2 charset03_1.bin charset03_1.pak
	pchunk2 bg/world03.blk charset03_2.pak
	filejoin charset03_1.pak+charset03_2.pak charset03.pak

charset04.pak: charset04.s memory.s bg/world04.blk bg/world04.chi bg/world04.chc bg/world04.chr
	dasm charset04.s -ocharset04_1.bin -f3
	pack2 charset04_1.bin charset04_1.pak
	pchunk2 bg/world04.blk charset04_2.pak
	filejoin charset04_1.pak+charset04_2.pak charset04.pak

charset05.pak: charset05.s memory.s bg/world05.blk bg/world05.chi bg/world05.chc bg/world05.chr
	dasm charset05.s -ocharset05_1.bin -f3
	pack2 charset05_1.bin charset05_1.pak
	pchunk2 bg/world05.blk charset05_2.pak
	filejoin charset05_1.pak+charset05_2.pak charset05.pak

charset06.pak: charset06.s memory.s bg/world06.blk  bg/world06.chi bg/world06.chc bg/world06.chr
	dasm charset06.s -ocharset06_1.bin -f3
	pack2 charset06_1.bin charset06_1.pak
	pchunk2 bg/world06.blk charset06_2.pak
	filejoin charset06_1.pak+charset06_2.pak charset06.pak

charset07.pak: charset07.s memory.s bg/world07.blk bg/world07.chi bg/world07.chc bg/world07.chr
	dasm charset07.s -ocharset07_1.bin -f3
	pack2 charset07_1.bin charset07_1.pak
	pchunk2 bg/world07.blk charset07_2.pak
	filejoin charset07_1.pak+charset07_2.pak charset07.pak

charset08.pak: charset08.s memory.s bg/world08.blk bg/world08.chi bg/world08.chc bg/world08.chr
	dasm charset08.s -ocharset08_1.bin -f3
	pack2 charset08_1.bin charset08_1.pak
	pchunk2 bg/world08.blk charset08_2.pak
	filejoin charset08_1.pak+charset08_2.pak charset08.pak

charset09.pak: charset09.s memory.s bg/world09.blk bg/world09.chi bg/world09.chc bg/world09.chr
	dasm charset09.s -ocharset09_1.bin -f3
	pack2 charset09_1.bin charset09_1.pak
	pchunk2 bg/world09.blk charset09_2.pak
	filejoin charset09_1.pak+charset09_2.pak charset09.pak

charset10.pak: charset10.s memory.s bg/world10.blk bg/world10.chi bg/world10.chc bg/world10.chr
	dasm charset10.s -ocharset10_1.bin -f3
	pack2 charset10_1.bin charset10_1.pak
	pchunk2 bg/world10.blk charset10_2.pak
	filejoin charset10_1.pak+charset10_2.pak charset10.pak

charset11.pak: charset11.s memory.s bg/world11.blk bg/world11.chi bg/world11.chc bg/world11.chr
	dasm charset11.s -ocharset11_1.bin -f3
	pack2 charset11_1.bin charset11_1.pak
	pchunk2 bg/world11.blk charset11_2.pak
	filejoin charset11_1.pak+charset11_2.pak charset11.pak

charset12.pak: charset12.s memory.s bg/world12.blk bg/world12.chi bg/world12.chc bg/world12.chr
	dasm charset12.s -ocharset12_1.bin -f3
	pack2 charset12_1.bin charset12_1.pak
	pchunk2 bg/world12.blk charset12_2.pak
	filejoin charset12_1.pak+charset12_2.pak charset12.pak

charset13.pak: charset13.s memory.s bg/world13.blk bg/world13.chi bg/world13.chc bg/world13.chr
	dasm charset13.s -ocharset13_1.bin -f3
	pack2 charset13_1.bin charset13_1.pak
	pchunk2 bg/world13.blk charset13_2.pak
	filejoin charset13_1.pak+charset13_2.pak charset13.pak

charset14.pak: charset14.s memory.s bg/world14.blk bg/world14.chi bg/world14.chc bg/world14.chr
	dasm charset14.s -ocharset14_1.bin -f3
	pack2 charset14_1.bin charset14_1.pak
	pchunk2 bg/world14.blk charset14_2.pak
	filejoin charset14_1.pak+charset14_2.pak charset14.pak

level00.pak: bg/world00.map bg/world00.lvo bg/world00.lva
	pack2 bg/world00.lvo level00_1.pak
	pack2 bg/world00.lva level00_2.pak
	pchunk2 bg/world00.map level00_3.pak
	filejoin level00_1.pak+level00_2.pak+level00_3.pak level00.pak

level01.pak: bg/world01.map bg/world01.lvo bg/world01.lva
	pack2 bg/world01.lvo level01_1.pak
	pack2 bg/world01.lva level01_2.pak
	pchunk2 bg/world01.map level01_3.pak
	filejoin level01_1.pak+level01_2.pak+level01_3.pak level01.pak

level02.pak: bg/world02.map bg/world02.lvo bg/world02.lva
	pack2 bg/world02.lvo level02_1.pak
	pack2 bg/world02.lva level02_2.pak
	pchunk2 bg/world02.map level02_3.pak
	filejoin level02_1.pak+level02_2.pak+level02_3.pak level02.pak

level03.pak: bg/world03.map bg/world03.lvo bg/world03.lva
	pack2 bg/world03.lvo level03_1.pak
	pack2 bg/world03.lva level03_2.pak
	pchunk2 bg/world03.map level03_3.pak
	filejoin level03_1.pak+level03_2.pak+level03_3.pak level03.pak

level04.pak: bg/world04.map bg/world04.lvo bg/world04.lva
	pack2 bg/world04.lvo level04_1.pak
	pack2 bg/world04.lva level04_2.pak
	pchunk2 bg/world04.map level04_3.pak
	filejoin level04_1.pak+level04_2.pak+level04_3.pak level04.pak

level05.pak: bg/world05.map bg/world05.lvo bg/world05.lva
	pack2 bg/world05.lvo level05_1.pak
	pack2 bg/world05.lva level05_2.pak
	pchunk2 bg/world05.map level05_3.pak
	filejoin level05_1.pak+level05_2.pak+level05_3.pak level05.pak

level06.pak: bg/world06.map bg/world06.lvo bg/world06.lva
	pack2 bg/world06.lvo level06_1.pak
	pack2 bg/world06.lva level06_2.pak
	pchunk2 bg/world06.map level06_3.pak
	filejoin level06_1.pak+level06_2.pak+level06_3.pak level06.pak

level07.pak: bg/world07.map bg/world07.lvo bg/world07.lva
	pack2 bg/world07.lvo level07_1.pak
	pack2 bg/world07.lva level07_2.pak
	pchunk2 bg/world07.map level07_3.pak
	filejoin level07_1.pak+level07_2.pak+level07_3.pak level07.pak

level08.pak: bg/world08.map bg/world08.lvo bg/world08.lva
	pack2 bg/world08.lvo level08_1.pak
	pack2 bg/world08.lva level08_2.pak
	pchunk2 bg/world08.map level08_3.pak
	filejoin level08_1.pak+level08_2.pak+level08_3.pak level08.pak

level09.pak: bg/world09.map bg/world09.lvo bg/world09.lva
	pack2 bg/world09.lvo level09_1.pak
	pack2 bg/world09.lva level09_2.pak
	pchunk2 bg/world09.map level09_3.pak
	filejoin level09_1.pak+level09_2.pak+level09_3.pak level09.pak

level10.pak: bg/world10.map bg/world10.lvo bg/world10.lva
	pack2 bg/world10.lvo level10_1.pak
	pack2 bg/world10.lva level10_2.pak
	pchunk2 bg/world10.map level10_3.pak
	filejoin level10_1.pak+level10_2.pak+level10_3.pak level10.pak

level11.pak: bg/world11.map bg/world11.lvo bg/world11.lva
	pack2 bg/world11.lvo level11_1.pak
	pack2 bg/world11.lva level11_2.pak
	pchunk2 bg/world11.map level11_3.pak
	filejoin level11_1.pak+level11_2.pak+level11_3.pak level11.pak

level12.pak: bg/world12.map bg/world12.lvo bg/world12.lva
	pack2 bg/world12.lvo level12_1.pak
	pack2 bg/world12.lva level12_2.pak
	pchunk2 bg/world12.map level12_3.pak
	filejoin level12_1.pak+level12_2.pak+level12_3.pak level12.pak

level13.pak: bg/world13.map bg/world13.lvo bg/world13.lva
	pack2 bg/world13.lvo level13_1.pak
	pack2 bg/world13.lva level13_2.pak
	pchunk2 bg/world13.map level13_3.pak
	filejoin level13_1.pak+level13_2.pak+level13_3.pak level13.pak

level14.pak: bg/world14.map bg/world14.lvo bg/world14.lva
	pack2 bg/world14.lvo level14_1.pak
	pack2 bg/world14.lva level14_2.pak
	pchunk2 bg/world14.map level14_3.pak
	filejoin level14_1.pak+level14_2.pak+level14_3.pak level14.pak

level15.pak: bg/world15.map bg/world15.lvo bg/world15.lva
	pack2 bg/world15.lvo level15_1.pak
	pack2 bg/world15.lva level15_2.pak
	pchunk2 bg/world15.map level15_3.pak
	filejoin level15_1.pak+level15_2.pak+level15_3.pak level15.pak

sprplayert.pak: spr/playert.spr
	pchunk2 spr/playert.spr sprplayert.pak

sprplayerb.pak: spr/playerb.spr
	pchunk2 spr/playerb.spr sprplayerb.pak

sprplayerta.pak: spr/playerta.spr
	pchunk2 spr/playerta.spr sprplayerta.pak

sprplayerba.pak: spr/playerba.spr
	pchunk2 spr/playerba.spr sprplayerba.pak

sprsmallrobots.pak: spr/smallrobots.spr
	pchunk2 spr/smallrobots.spr sprsmallrobots.pak

sprhazards.pak: spr/hazards.spr
	pchunk2 spr/hazards.spr sprhazards.pak

sprhazards2.pak: spr/hazards2.spr
	pchunk2 spr/hazards2.spr sprhazards2.pak

spranimals.pak: spr/animals.spr
	pchunk2 spr/animals.spr spranimals.pak

sprmediumrobots.pak: spr/mediumrobots.spr
	pchunk2 spr/mediumrobots.spr sprmediumrobots.pak

sprguard.pak: spr/guard.spr
	pchunk2 spr/guard.spr sprguard.pak

sprheavyguard.pak: spr/heavyguard.spr
	pchunk2 spr/heavyguard.spr sprheavyguard.pak

sprcombatrobot.pak: spr/combatrobot.spr
	pchunk2 spr/combatrobot.spr sprcombatrobot.pak

sprlargewalker.pak: spr/largewalker.spr
	pchunk2 spr/largewalker.spr sprlargewalker.pak

sprlargetank.pak: spr/largetank.spr
	pchunk2 spr/largetank.spr sprlargetank.pak

sprhighwalker.pak: spr/highwalker.spr
	pchunk2 spr/highwalker.spr sprhighwalker.pak

sprserver.pak: spr/server.spr
	pchunk2 spr/server.spr sprserver.pak

sprsecuritychief.pak: spr/securitychief.spr
	pchunk2 spr/securitychief.spr sprsecuritychief.pak

sprrotordrone.pak: spr/rotordrone.spr
	pchunk2 spr/rotordrone.spr sprrotordrone.pak

sprlargespider.pak: spr/largespider.spr
	pchunk2 spr/largespider.spr sprlargespider.pak

sprscientist.pak: spr/scientist.spr
	pchunk2 spr/scientist.spr sprscientist.pak

sprhacker.pak: spr/hacker.spr
	pchunk2 spr/hacker.spr sprhacker.pak

sprhazmat.pak: spr/hazmat.spr
	pchunk2 spr/hazmat.spr sprhazmat.pak