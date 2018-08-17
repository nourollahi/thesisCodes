#!/bin/sh

TDTROOT=/data/data2/TDT/Dryrun2000/TDT2_release3.1.patch1

if [ ! -f index.flist ] ; then
    (cd $TDTROOT; find *_bnd -type f -print) | grep .bnd | \
	sed -e 's:^.*/::' -e 's/\..*$//' | sort -u > index.flist
fi

rm -fr *.ndx trk_ndx *.ctl *.key Subset*

/data/data2/TDT/Software/TDT3eval_v2.0/TDT3BuildIndex.pl \
	-t 4 \
	-n 2 \
	-v 3 \
	-s \
	-S English=as1,Mandarin=as0 \
	-L LnkDB \
	-T TDT99_mul \
	-R $TDTROOT \
	-r 393826261 \
	-f index.flist -O . -a ccap \
	-y 2000

