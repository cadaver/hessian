all: hessian.d64 hessian.d81

clean:
	del *.bin
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

hessian.d64: boot.prg loader.pak main.pak testmusic.pak testspr.pak testlev.pak
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

main.pak: actor.s actordata.s data.s file.s init.s loadsym.s macros.s main.s memory.s raster.s screen.s sound.s sprite.s loader.pak bg/scorescr.chr
	dasm main.s -omain.bin -smain.tbl -f3
	pack2 main.bin main.pak

testmusic.pak: music/testmusic.bin
	pack2 music/testmusic.bin testmusic.pak

testlev.pak: testlev.s bg/testlev.map bg/testlev.blk bg/testlev.chi bg/testlev.chc bg/testlev.chr
	dasm testlev.s -otestlev1.bin -f3
	pack2 testlev1.bin testlev1.pak
	pchunk2 bg/testlev.map testlev2.pak
	pchunk2 bg/testlev.blk testlev3.pak
	pack2 bg/testlev.chr testlev4.pak
	filejoin testlev1.pak+testlev2.pak+testlev3.pak+testlev4.pak testlev.pak

testspr.pak: spr/testspr.spr
	pchunk2 spr/testspr.spr testspr.pak
