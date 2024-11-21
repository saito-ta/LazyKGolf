all : opt.exe
#all : lazyk.exe num.pl opt.exe

lazyk.exe : lazyk.c
	gcc -O3 -o $@ $<

num.pl : mknum.pl
	perl $< >$@

num-ulsk.pl : mknum-ulsk.pl
	perl $< >$@

opt.exe : opt.cpp optsub.cpp
	g++ -std=gnu++11 -O3 -o $@ $<
#	g++ -std=gnu++11 -g -o $@ $<

optj.exe : optj.cpp optjsub.cpp
	g++ -std=gnu++11 -O3 -o $@ $<
#	g++ -std=gnu++11 -g -o $@ $<

optsub.cpp : mkoptsub.pl
	perl $< >$@
