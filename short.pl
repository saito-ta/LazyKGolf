use strict;
#use warnings;

my $varid=0;
sub next_var {
    die if $varid>=26;
    chr(97+$varid++);
}

=comment
my $unget;

sub get_c {
    my $x = $unget;
    undef $unget;
    return defined $x ? $x : getc();
}

sub unget_c {
    $unget = $_[0];
}
=cut

sub get_c { getc();}

sub read_many {
    my($end)=@_;
    my $l=read_one();
    my $l2;
    while( defined($l2=read_one($end)) ){
	$l=[$l,$l2];
    }
    $l;
}

sub read_one {
    my($end)=@_;
    my $c;
    while( $c=get_c(), $c =~ /\s/ ){
    }
    if( $c eq $end ) {
	return undef;
    }
    if(!defined $c){
	die;
    }
    if( $c eq '(' ) {
	return read_many(')');
    }
    if( $c eq '`' ) {
	return [ read_one(), read_one() ];
    }
    if( $c =~ /\w/ ){
	return $c;
    }
    die;
}

my $nojot;
my $last='';

sub show {
    my($e,$need_paren)=@_;
    if( ref $e ) {
	my $e0=$e->[0];
	my $e1=$e->[1];
	if( !$nojot && ( $e0 eq 'K' && $e1 eq 'I' || $e0 eq 'S' && $e1 eq 'K' ) ){
	    if($last=~/\d$/){
		return $last='(0)';
	    }else{
		return $last='0';
	    }
	}else{
	    my $opening='';
	    my $closing='';
	    if( $need_paren ) {
		if( ref $e0 ) {
		    $opening='(';
		    $closing=')';
		}else{
		    $opening='`';
		}
	    }
	    return $last=$opening . show($e0,0) . show($e1,1) . $closing;
	}
    } else {
	return $last=$e;
    }
}

if(@ARGV){
    if($ARGV[0] eq '-nj'){
	$nojot=1;
    }
}

my $root = read_many();
print show($root,0);
