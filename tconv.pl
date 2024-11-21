use strict;
use warnings;
no warnings qw(recursion);

sub mydir {$0=~m{.*/};$&}
require(mydir.'num.pl');
require(mydir.'macro.pl');
our %macros;

my $t_var=1;
my $t_lambda=2;
my $t_appl=3;
my $t_comb=4;
my $t_freevar=5;
my $t_string=6;

my $c_I = 1;
my $c_K = 2;
my $c_S = 3;

my $l_c_I = { t => $t_comb, id => $c_I };
my $l_c_K = { t => $t_comb, id => $c_K };
my $l_c_S = { t => $t_comb, id => $c_S };
my $l_c_0;

my $last_var_id=0;
sub mk_var {
	{ t => $t_var, id => ++$last_var_id };
}

sub mk_freevar {
	{ t => $t_freevar, name => $_[0] };
}

sub mk_lambda {
	my($v,$e)=@_;
	{ t => $t_lambda, v => $v, e => $e };
}

sub mk_appl {
	my($f,$e)=@_;
	{ t => $t_appl, f => $f, e => $e };
}

sub mk_num {
	my($a)=@_;
	if($a==0){
		mk_appl($l_c_S,$l_c_K);
	} else {
		my $l=$l_c_I;
		#if( $a>=72 ) {
		#	my $l8=mk_num(8);
		#	my $l9=mk_num(9);
		#	my $f=mk_var();
		#	$l=mk_lambda($f,mk_appl($l8,mk_appl($l9,$f)));
		#	$a-=72-1;
		#}
		#if( $a>=27 ) {
		#	my $l3=mk_num(3);
		#	$l=mk_appl($l3,$l3);
		#	$a-=27-1;
		#}
		if( $a>=64 ) {
			my $l4=mk_num(4);
			my $l3=mk_num(3);
			$l=mk_appl($l3,$l4);
			$a-=64-1;
		}
		if($a){
			my $succ= mk_appl($l_c_S, mk_appl(mk_appl($l_c_S,mk_appl($l_c_K,$l_c_S)),$l_c_K));
			while(--$a){
				$l=mk_appl($succ,$l);
			}
		}
		$l;
	}
}

sub mk_cons {
	my($a,$b)=@_;
	my $f=mk_var();
	mk_lambda($f,mk_appl(mk_appl($f,$a),$b))
}

sub mk_string {
	my($a)=@_;
	if($a eq ''){
		#mk_cons(mk_num(256),mk_num(0));
		#my $l=mk_var();
		#mk_lambda($l,$l);
		parse("<sii>[f.[p.p{num 256}(ff)]]");
	}else{
		mk_cons(parse(num(ord($a))),mk_string(substr($a,1)));
	}
}

###----------------------------------------------------------------------

sub string {
	my($a)=@_;
	if($a eq ''){
		'(<sii>[f.[p.p'.num(256).'(ff)]])';
	}else{
		my $c=ord($a);
		'(<cons1>'.num(ord($a)).string(substr($a,1)).')';
	}
}

###----------------------------------------------------------------------

sub is_free {
	my($vid,$e)=@_;
	if( $e->{t} == $t_var ) {
		$e->{id} != $vid;
	} elsif( $e->{t} == $t_lambda ) {
		die if $e->{v}{t} != $t_var;
		die if $e->{v}{id} == $vid;
		is_free($vid,$e->{e});
	} elsif( $e->{t} == $t_appl ) {
		is_free($vid,$e->{f}) && is_free($vid,$e->{e});
	} elsif( $e->{t} == $t_comb || $e->{t} == $t_freevar ) {
		1;
	} else {
		die;
	}
}

my $no_eta = 0;

sub T_lambda {
	my($vid,$a)=@_;
	my $r;
	if( is_free($vid,$a) ) {
		$r=mk_appl($l_c_K,T($a));
	} elsif( $a->{t} == $t_var ) {
		die if $a->{id} != $vid;
		$r=$l_c_I;
	} elsif( $a->{t} == $t_lambda ) {
		$r=T_lambda($vid,T($a));
	} elsif( $a->{t} == $t_appl ) {
		if( !$no_eta && $a->{e}{t} == $t_var && $a->{e}{id} == $vid && is_free($vid,$a->{f}) ) {
			# eta reduction
			$r=T($a->{f});
		} else {
			$r=mk_appl(mk_appl($l_c_S,T_lambda($vid,$a->{f})),T_lambda($vid,$a->{e}));
		}
	} else {
		die $a->{t};
	}
	return $r;
}

#my $dbg_T_lvl=0;
sub T {
	#++$dbg_T_lvl;
	my($a)=@_;
	#print " "x($dbg_T_lvl*4),show($a),"\n";
	my $r;
	if( $a->{t} == $t_var || $a->{t} == $t_comb || $a->{t} == $t_freevar ) {
		$r=$a;
	} elsif( $a->{t} == $t_appl ) {
		$r=mk_appl(T($a->{f}),T($a->{e}));
	} elsif( $a->{t} == $t_lambda ) {
		die if $a->{v}{t} != $t_var;
		$r=T_lambda($a->{v}{id},$a->{e});
	} else {
		die $a->{t} ;
	}
	#print " "x($dbg_T_lvl*4),show($r),"\n";
	#--$dbg_T_lvl;
	return $r;
}

sub show {
	my($t)=@_;
	if( $t->{t} == $t_comb ) {
		$t->{id}==$c_I ? 'I' : $t->{id}==$c_S ? 'S' : $t->{id}==$c_K ? 'K' : '?';
	} elsif( $t->{t} == $t_appl ) {
		#'(' . show($t->{f}) . ',' . show($t->{e}) . ')';
		'(' . show($t->{f}) . show($t->{e}) . ')';
	} elsif( $t->{t} == $t_var ) {
		'v'.$t->{id};
	} elsif( $t->{t} == $t_lambda ) {
		'<'.show($t->{v}).'.'.show($t->{e}).'>'
	} elsif( $t->{t} == $t_freevar ) {
		"($t->{name})";
	} else {
		die;
	}
}

sub show_bf {
	my($t)=@_;
	if( $t->{t} == $t_comb ) {
		$t->{id}==$c_I ? 'i' : $t->{id}==$c_S ? 's' : $t->{id}==$c_K ? 'k' : '?';
	} elsif( $t->{t} == $t_appl ) {
		'`' . show_bf($t->{f}) . show_bf($t->{e});
	} elsif( $t->{t} == $t_var ) {
		'v'.$t->{id};
	} elsif( $t->{t} == $t_lambda ) {
		'<'.show_bf($t->{v}).'.'.show_bf($t->{e}).'>'
	} elsif( $t->{t} == $t_freevar ) {
		$t->{name};
	} else {
		die;
	}
}

my %freevars;
my %named_vars;
my %pe;  # parse env

sub parse_many {
    my($end)=@_;
    my $e=parse_one($end);
    if( defined $e ) {
        my $e2;
        while($e2=parse_one($end),defined $e2){
            $e=mk_appl($e,$e2);
        }
    } else {
        warn( "warngin: empty expression.\n" );
        $e=parse("I");
    }
    $e;
}

sub expand_macro {
    my $c=$_[0];
    my $end=$_[1];
    if(exists $macros{$c}){
	my $m=$macros{$c};
	my $argn = $c=~/\d$/ ? $& : 0;
	local $named_vars{"_1"};
	local $named_vars{"_2"};
	local $named_vars{"_3"};
	local $named_vars{"_4"};
	for my $i (1..$argn){
	    $named_vars{"_$i"}=parse_one($end);
	}
	parse($m);
    }
}

sub parse_one {
    my($end)=@_;
    local *_=\$pe{input};
    s/^\s*//g;
    if(s/^<(.*?)>\s*=|^([_a-z][0-9_a-z-]*)\s*=//){
        my $c=$1//$2;
        s/^(.*?);//s or die;
        my $body=$1;
        $macros{$c}=$body;
        &parse_one;
    }elsif(s/^<(.*?)>//){
        my $c=$1;
        expand_macro($c,$end) or die "undefined macro <$c>";
    }elsif(s/^(\d+)'//){
        my$c=$1;
        parse(bnum($c));
    }elsif(s/^0//){
	my $e=mk_appl($l_c_K,$l_c_I);
	while(s/^[01]//){
            $e=$&?mk_appl($l_c_S,mk_appl($l_c_K,$e)):mk_appl(mk_appl($e,$l_c_S),$l_c_K);
	}
        $e;
    }elsif(s/^(\d+)//){
        my$c=$1;
        parse(num($c));
    }elsif(s/^([_a-z][0-9_a-z-]*)//){
        my$c=$1;
        $named_vars{$c} || expand_macro($c,$end) || do {
            $freevars{$c}++ or warn( "warning: freevar \"$c\"\n" );
            mk_freevar($c);
        }
    }elsif(s/^\?(.)'//){
        my$c=$1;
	parse(bnum(ord($c)));
    }elsif(s/^\?(.)//){
        my$c=$1;
	parse(num(ord($c)));
    }elsif(s/^(.|)//){
        my$c=$1;
        if(defined $end && $c eq $end){
            undef;
        }elsif($c eq '('){
            parse_many(')');
        }elsif($c eq '`'){
            mk_appl(parse_one(),parse_one());
        }elsif($c eq '['){
            s/^\s*([_a-z][0-9_a-z-]*)\s*\.// or die $_;
            my $varname=$1;
            local $named_vars{$varname}=my $var=mk_var();
            mk_lambda($var,parse_many(']'));
        }elsif($c eq '$'){
            my $e=parse_many($end);
            $_=$end.$_;
            $e;
        }elsif( $c=~/^[SKI]$/ ){
            #$c eq '0' ? ( $l_c_0 //= parse('KI') ) :
            $c eq 'I' ? $l_c_I :
                $c eq 'K' ? $l_c_K :
                $c eq 'S' ? $l_c_S :
                die;
        }else{
            die "token=<$c> end=".(defined$end?"<$end>":"undef");
        }
    }else{
        die;
    }
}

sub parse {
    local $pe{input} = $_[0];
    parse_many('');
}

###

sub addconst {
    my $n=$_[0]+0;
    "(S $n' S <ucc>)";
}

sub pre_str {
    my $e="";
    for($_[0]=~/./sg){
	$e.="cons2 ".(ord)." ";
    }
    "[z. $e z]";
}

sub pre_bstr {
    my $e="";
    for($_[0]=~/./sg){
	$e.="cons2 ".(ord)."' ";
    }
    "[z. $e z]";
}

###----------------------------------------------------------------------

if(@ARGV){
if( $ARGV[0] eq '-ne' ) {
	$no_eta = 1;
	shift;
}
}

my $code='';
while(<>){
    last if /^---/;
    s/#.*//;
    s/\{(.*?)\}/$1/gee;
    $code.=$_;
}

my $root=parse($code);
print show(T($root));
