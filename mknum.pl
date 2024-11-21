my $maxnum = 4096;

# n51b (51b numbers)

my @n51br;
my @n51bl;
my @numr;
my @numl;

sub make_n51b_add1 {
    my($i,$e)=@_;
    if($i<=$maxnum){
	if(!defined $n51br[$i] || length($n51br[$i])>length($e)){
	    $n51br[$i]=$e;
	}
	0 while $e=~s/^`// || $e=~s/^\((.*)\)$/$1/;
	if(!defined $n51bl[$i] || length($n51bl[$i])>length($e)){
	    $n51bl[$i]=$e;
	}
    }
}

sub make_n51b {
    $n51bl[0]='K0'; $n51br[0]='`K0';
    $n51bl[1]='0';  $n51br[1]='0';
    make_n51b_add1(42,"(SS(SS`K(SS0))(SSS))"); # 42 = fof(2), f(x)=(1+x)*x
    make_n51b_add1(729,"(SS`S(S`SSKSSS)(SS0))"); # 
    make_n51b_add1(1872,"(SI(SI`K(SS0))`S(SSSSS))");
    for my $i (0..$maxnum){
	my $ei=$n51br[$i];
	make_n51b_add1(1+$i,            "(SS$ei)");
	make_n51b_add1($i**$i,          "(SSI$ei)");
	make_n51b_add1((1+$i)**$i,      "(SSSS$ei)");
	make_n51b_add1((2+$i)**$i,      "(SS(S`K`SS`SS)$ei)"); # 125 = 5**3
	make_n51b_add1((2+$i)**$i*$i,   "(S(S`KS`SI)(SS(S`K`SS`SS))$ei)"); # 375 = 5**3*3
	make_n51b_add1($i**$i**2,       "(SS(SSI)$ei)");
	make_n51b_add1((1+$i)**$i**2,   "(SSSSSS$ei)");
	make_n51b_add1($i**(1+$i),      "(S`SSKS`SSI$ei)"); # 1024 = 4**5
#	make_n51b_add1(($i*(1+$i))**$i, "(SS`S(SSS)$ei)");
	make_n51b_add1(($i*(1+$i))**$i, "(SSSI`SSS$ei)");
	make_n51b_add1($i+(1+$i)*(2+$i),"(S(S`KS(SS`KS))(S`K`S(SSS)`SS)$ei)"); # not helpful below 1024
	if($i>1){
	    my $j=1+$i;
	    my $b='';
	    while(($j*=$i)<=$maxnum){
		$b.='SS';
		make_n51b_add1($j,"(S(S$b)$ei)");
		make_n51b_add1($i+$j,"(S(S`KS(SS`KS))(S`K`S(S$b)I)$ei)");  # not helpful below 1024
	    }
	}
	if($i>1){
	    my $j=2+$i;
	    #my $b='(S(SIS)S)';
	    my $b='`S(SIS)S';
	    while(($j*=$i)<=$maxnum){
		$b="(SS$b)";
		make_n51b_add1($j,"(S$b$ei)");
	    }
	}
	if($i>0){
	    my $j=$i+2;
	    my $b='';
	    while(($j*=$i+1)<=$maxnum){
		$b.='SS';
		make_n51b_add1($i+$j,"(S(S`KS(SS`KS))(S`K`S(S$b)`SS)$ei)");
	    }
	}
	for my $j (0..$i){
	    my $ej=$n51br[$j];
	    make_n51b_add1($j+$i,  "(S(S${ej}S)${ei})");
	    make_n51b_add1($j*$i,  "(S(SI${ej})${ei})");
	    make_n51b_add1($i**$j, "(S${ej}${ei})");
	    make_n51b_add1($j**$i, "(S${ei}${ej})");
	}
    }
}

sub make_num {
    #my $succ="S(S`KSK)";
    my $succ="SSS`KSK";
    my $two="${succ}I";
    #my $four="SII($two)";
    my $four="SSI($succ)I";
    $numr[0]="0";
    $numr[1]="I";
    $numr[2]="($two)";
    $numr[4]="($four)";
    $numr[16]="(S`SII($two))";
    #$numr[256]="(SII(SII($two)))";
    #$numr[256]="(SII$four)";
    $numr[256]="(SSI(SSI($succ))I)"
}


make_n51b();
make_num();

for(0..$maxnum){
    my $r=$n51br[$_];
    my $l=$n51bl[$_];
    0 while $r=~s/^`// || $r=~s/^\((.*)\)$/$1/;
    die "$_ l=$l r=$r" if $l ne $r;
}

print "my \@n51b;\n";
for(0..$maxnum){
    print "\$n51b[$_]='$n51br[$_]';\n";
}

print "my \@num;\n";
for(0..$maxnum){
    if(defined $numr[$_]){
	print "\$num[$_]='$numr[$_]';\n";
    }
}

print <<'END';

# n51b number
sub bnum {
    $n51b[$_[0]];
}

# church number
sub num {
    $num[$_[0]] //= $n51b[$_[0]]=~s/\)$/(S`KSK))/r
}

END

# church
