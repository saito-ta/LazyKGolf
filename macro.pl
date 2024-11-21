our %macros2=(
   #succ     => 'S<ucc>',
   #succ     => 'S`SSKSK',
    succ     => 'SISSKSK',
   #pred     => 'S(S(SI`K(S`K`SI(S`KK(SI`K`S(S`KSK)))))`K`K0)0',
   #pred     => 'S(S(SI`K(S`K`SI(S`KK(SI`K(S`SSKSK)))))`K`K0)0',
    pred     => 'S(S(SI`K(S`K`SI(S`KK(SI`K(SISSKSK)))))`K`K0)0',
   #pred1    => '_1(S`K`SI(S`KK(SI`K`S(S`KSK))))`K0I',
    pred1    => '_1(S`K`SI(S`KK(SI`K(SISSKSK))))`K0I',
    predf1   => '_1(S`K`SI(S`KK(SI`K(SISSKSK))))`K0',
    ucc      => 'S`KSK',
    swap     => 'S`K`SIK',
    car      => 'SI`KK',
    cdr      => 'SI`K0',
    caar     => 'S(SS0)`KK',
    cddr     => 'S(SS0)`K0',
    cdddr    => 'S(S(SS0)`K0)`K0',
   #cons     => 'S(S`KS(S`KK(S`KS(S`K`SIK))))`KK',
    cons     => 'S`SSKS(S`KK(S`KS(S`K`SIK)))`KK',
    cons1    => 'S`K`S(SI`K_1)K',
    cons2    => 'S(SI`K_1)`K_2',
    consb2   => 'S(S`KS(S`K`SIK))`K`K_2_1',
    nth2     => '_1(SI`K0)_2K',

    ifle2    => '_1(S`K`SIK)`KK(_2(S`K`SIK)`K0)',
    iflt2    => '_2(S`K`SIK)`K0(_1(S`K`SIK)`KK)',
    ifge2    => '_2(S`K`SIK)`KK(_1(S`K`SIK)`K0)',
    ifgt2    => '_1(S`K`SIK)`K0(_2(S`K`SIK)`KK)',

    not      => 'S(SI`K0)`KK',
   #ifeven1  => 'S`K(_1(SI`K0)I)K',
   #ifodd1   => 'S`K(_1(SI`K0)0)K',
   #ifeven3  => '_1(SI`K0)I`K_2 _3',
   #ifodd3   => '_1(SI`K0)0`K_2 _3',
    ifeven1  => '_1(S(SI`K0)`KK)K',
    ifodd1   => '_1(S(SI`K0)`KK)0',

    even1    => '_1K(SI`K0)I',
    odd1     => '_1K(SI`K0)0',

    add_two   => 'SSSISS(S`KSK)',
    add_three => 'SIS`SISS(S`KSK)',
    x2succ    => 'SSSISS(S`KSK)',
    x3succ    => 'SIS`SISS(S`KSK)',

    sii      => 'SII',
    y        => 'SSI`S`S`K`SII', #'SS`S(S`KSK)`K(SII)', #'SS(SISSKSK)`K(SII)',
    y1       => 'SSI`S`S`K_1I', #'SSI`S`K_1(SII)',
    );

=comment
# 371
<shownum> =
  <sii>[f.[f.[a.[b.
    (10 <swap> (KK))
    (b  <swap> (K0))
    (f (<succ>a) (10<pred>b))
    (a 0 0 (<o1>(f 0 a)) (<cons1>(S 48' S <ucc> b)))
  ]]](<sii>f)]
  0
;
$macros2{shownum} = 'SSI`S`K(S`SSKS(S`K`S`KS(S`K`S`K`S(S`K(SS(SSSS(SS0))(S`KSK)(S`K`SIK)`KK)(S(SI`K(S`K`SIK))`K`K0))(S`SSKS(S`K`S`KS(S`K`S`KK(S`SSKSK`K(S`SSKSK))))`K`K(SS(SSSS(SS0))(S`KSK)(S(S(SI`K(S`K`SI(S`KK(SI`K(S`SSKSK)))))`K`K0)0)))))(S`SSKS(S`K`S`KS(S`K`S`KK(S`K`S(S(SI`K0)`K0)(S`K`S`KS(S`K`S`KK(SI`K0))))))`K`K(S`SSKS(S`KK(S`KS(S`K`SI(S`KK(S(S(SSSSSSSSS)(SS0))S(S`KSK))))))`KK)))(SII)0';


# 343
shownum =
  sii
  [self.
  [n.
    n 0 0
    (
      n
      [p.
         #iflt2 (cdr1 p) 9  # shorter for opt
         iflt4 (cdr1 p) 9  # shorter for optj
         (cons2 (car1 p) (succ (cdr1 p)))
         (cons2 (succ (car1 p)) 0)
      ]
      (K 0)
      [div.[rem.
        o1 (self self div) (cons1 ({addconst 48} rem))
      ]]
    )
  ]
  ]
;
=cut

# 341
$macros2{shownum} = 'SSI`S`K`S(S(SI`K0)`K0)(S`K`S(S(SI`K(S(S(S`K(SSSS(SS0)(S`KSK)(S`K`SIK)`K0)(S(S(SI`K0)`K(S`K`SIK))`K`KK))(S`SSKS(S`K`SI(S`SI`KK))(S`KK(S`K`S(S`KSK)(SI`K0)))))(S`SSKS(S`K`SI(S`KK(S`K`S(S`KSK)(SI`KK))))`K`K0)))`K`K0)(S`KK(S`SSKS(S`K`S`KS(S`K`S`KK(S`K`S`KS(S`S`K`S`KKI))))`K`K(S`SSKS(S`KK(S`KS(S`K`SI(S`KK(S(S(SSSSSSSSS)(SS0))S(S`KSK))))))`KK))))';

# test opt=333
$macros2{shownum} = 'SSI`S`K`S(S(SS0)`S`K0)(S`K`S(S(SI`K(S(S`K(SSSS(SS0)(S`KSK)(S`K`SIK))(S`KK(S`K`S(SI`S`K0)(S`KK(S`K`S(S`KSK)(SI`S`K0))))))(S(S(SS`K`S`K`SI)`KK)(S`KK(SISSKS(S`K`SI(SS`S`S(S`SSKS)`KK))(S`KK(SI`S`K0)))))))`S`K`S`K0)(S`KK(S`SSKS(S`KK(S`KS(S`K`S`KS(S`S`K`S`KKI))))`K(SS`S(S`KS(S`KK(S`KS(S`K`SI(S`KK(S(S(SSSSSSSSS)(SS0))S(S`KSK)))))))`KK))))';

# shownumj (shownum for optj)
# 339 (optj=287)
$macros2{shownumj} = 'SII(S`K`S(S(SI`K0)`K0)(S`K`S(S(SI`K(S(S`K(SSSS(SS0)(S`KSK)(S`K`SIK))(S`KK(S`K`S(SI`K0)(S`KK(S`K(SISSKSK)(SI`K0))))))(S(S(SI`KK)`K(S`K`SIK))(S`KK(S(S`KS(S`K`SI(S`KK(S`K(SISSKSK)(SI`KK)))))(S`KK(SI`K0)))))))`K`K0)(S`KK(S(S`KS(S`KK(S`KS(S`K`S`KS(S`S`K`S`KKI)))))`K(S`KK(S(S`KS(S`KK(S`KS(S`K`SI(S`KK(S(S(SSSSSSSSS)(SS0))S(S`KSK)))))))`KK))))))';

=comment
# 353
<shownum-zero> =
  <sii>
  [self.
  [n.
      n
      [prev.
         <iflt2> (<cdr1> prev) 9
         (<cons2> (<car1> prev) (<succ> (<cdr1> prev)))
         (<cons2> (<succ> (<car1> prev)) 0)
      ]
      (<cons2> 0 0)
      [div.[rem.
        <o1> (div 0 0 (self self div)) (<cons1> ({addconst 48} rem))
      ]]
  ]
  ]
;
=cut

$macros2{"shownum-zero"} = 'SSI`S`K`S(S(SI`K(S(S(S`K(SSSS(SS0)(S`KSK)(S`K`SIK)`K0)(S(S(SI`K0)`K(S`K`SIK))`K`KK))(S`SSKS(S`K`SI(S`SI`KK))(S`KK(S`K(SISSKSK)(SI`K0)))))(S`SSKS(S`K`SI(S`KK(S`K(SISSKSK)(SI`KK))))`K`K0)))`K(S(SI`K0)`K0))(S`KK(S`SSKS(S`K`S`KS(S`K`S`KK(S`K`S`KS(S`K`S`KK(S`K`S(S(SI`K0)`K0)(SII))))))`K`K(S`SSKS(S`KK(S`KS(S`K`SI(S`KK(S(S(SSSSSSSSS)(SS0))S(S`KSK))))))`KK)))';

=comment
# SEE a+b problem for a better code
# fast and less stack consuming
<shownumfast> =
  [b.
    [l.
      <sii>[f.[f.[a.[b.
        (<car1>(9 <cdr> b))
        (
          <car1>a
          I
          (<o1>(f (<inflist1> K) a))
          (
            <cons1>
            (
              <sii>
              [f.[l.
                <car1>l
                48
                (<succ> (<sii>f (<cdr1>l)))
              ]]
              b
            )
          )
        )
        (f (<cons2> 0 a) (10 <cdr> b))
      ]]](<sii>f)]
      l
      (b (<cons1> 0) l)
    ](<inflist1> K)
  ]
;
$macros2{shownumfast} = 'S(S`K`S(SSI`S`K(S`SSKS(S`K`S`KS(S`K`S`K`S(S(SSSS(SS0)(S`KSK)(SI`K0))`KK)(S`SSKS(S`K`S`KS(S`K`S`KK(S`K`S(S(SI`KK)0)(S`K`S`KS(S`K`S`KK(SI`K(SSI`S`K`S(SI`KK)(S`KK(SII)))))))))`K`K(S`SSKS(S`KK(S`KS(S`K`SI(S`KK(SSI`S`K`S(S(SI`KK)`K(S(SSSSSSSSS)(SS0)(S`KSK)))(S`K`S`K(S`SSKSK)(S`SSKS(S`KK(SII))`K(SI`K0))))))))`KK))))(S`SSKS(S`K`S`KS(S`K`S`KK(S`SSKSK`K(S`K`S(SI`K0)K))))`K`K(SS(SSSS(SS0))(S`KSK)(SI`K0))))(SII))(SI`K(S`K`S(SI`K0)K)))`K(SSI`S`K`S(SI`KK)(S`KK(SII)))';
=cut

=comment
mkhello = [f.[w. o1 f[c.c 0 I 0 (cons1 1) (w(o1 cons [a. c K succ I a succ a]))]]];
getstr1 =
  [n.
    y1 [g.[r.
      #ifgt4 (car1 r) 2 I 0
      ifgt_two_3 (car1 r) I 0
      (o1 (cons1 (car1 r)) (g (cdr1 r)))
    ]]
    (n ucc cdr _1)
  ]
;
=cut
$macros2{mkhello} = 'S`SSKS(S`KK(S`KSK))`K(S`K`S(S(S(S(SI`K0)0)`K0)`K(S`K`S(SI0)K))(SISSKSK`K(S`K`S`K(S`SSKS(S`KK(S`KS(S`K`SIK)))`KK)(S`SSKS(S`SSKS(S(S(SS`K(SISSKS))`KK)0)`K`K(SISSKSK))0))))';

$macros2{getstr1} = 'S`K(SSI`S`K(S`K`S(S(S(S(SS`K`S`K`SI)`KK)`K`K0)`K(SI`K(SI`K0)))(S`K(SISSKS(SS(SISSKS(S`KK(SIKS(S`K`SI(S`SI`KK)))))`KK))(S(S`KSK)`K(SI`K0))))(SII))(S(S(SI`K(SIKSK))`K(SI`K0))`K_1)';

$macros2{inf} = 'SSI`S`S`K(S`SSKSK)I'; #'SSI`S`K(S`SSKSK)(SII)';
$macros2{inflist1} = 'SSI`S`K`S(SI`K_1)(S`S`KKI)'; #'SSI`S`K`S(SI`K_1)(S`KK(SII))';
#$macros2{natlist} = 'SSI`S`K(S`K`S(S`KS(S`K`SIK))(S`K`S`KK(SIK`S(S`KSK))))(SII)0';
$macros2{intlist} = 'SSI`S`S`K(S`K`S(S`KS(S`K`SIK))(S`K`S`KK(SIK`S(S`KSK))))I';
$macros2{natlist} = '<intlist>0';
$macros2{growlist} = 'S`SSKS(S`K`SI(SS`S`S(SISSKS)`KK))K';

#=comment
#<ifeq2> =
#        <nth2> _1
#	(_2 (<cons1> I) (<cons2> (K(K(KK))) 1))
#	I I 0
#;
#<ifne2> =
#        <nth2> _1
#	(_2 (<cons1> I) (<cons2> (K(K(K0))) 1))
#	I I K
#;
#=cut
#
#$macros2{ifeq2} = '_1(SI`K0)(_2(S`K`S(SI0)K)(S(SI`K`K`K`KK)0))KII0';
#$macros2{ifne2} = '_1(SI`K0)(_2(S`K`S(SI0)K)(S(SI`K`K`K`K0)0))KIIK';
#
#$macros2{ifeq4} = '_1(SI`K0)(_2(S`K`S(SI0)K)(S(SI`K`K`K`K_3)0))KII_4';
#$macros2{ifne4} = '_1(SI`K0)(_2(S`K`S(SI0)K)(S(SI`K`K`K`K_4)0))KII_3';
#
#=comment
## shorter but won't work when _1==_2-1
#alt_ifne2 =
#        nth2 _1
#	(_2 (cons1 I) (K(K(K(K0)))))
#	I I K
#;
#=cut
#$macros2{alt_ifne2}='_1(SI`K0)(_2(S`K`S(SI0)K)`K`K`K`K0)KIIK';

$macros2{ifeq2}='_1(S`K`SIK)(S(S(SI`K`KK)`K0)`KK)(_2(S`K`SIK)`K0)';
$macros2{ifne2}='_1(S`K`SIK)(S(S(SI`K`K0)`K0)`KK)(_2(S`K`SIK)`KK)';
$macros2{ifeq10_2}='_1(S`K`SIK)(S(SS0)`K0)(_2(S`K`SIK)`K0)';
$macros2{ifne10_2}='_1(S`K`SIK)(S(SI`K`K0)`K0)(_2(S`K`SIK)0)';
$macros2{ifeq3}=$macros2{ifeq10_2}.'`K_3';
$macros2{ifne3}=$macros2{ifne10_2}.'`K_3';

# tests whether _1 is out of range of [_2,_2+_3)
#   true  if _1 < _2
#   false if _2 <= _1 < _2+_3
#   true  if _2+_3 <= _1 AND _1^_2^_3 is odd
# ( I     if _2+_3 <= _1 AND _1^_2^_3 is even )
$macros2{isoutofrange3}='_1(SI`K0)(_2(S`K`S(SI`KK)K)(_3(S`K`S(SI`K0)K)0))K';
$macros2{'if-out-of-range3'}=$macros2{isoutofrange3};


our %macros=(
    %macros2,
    swap1    => 'SI`K_1',
    ifle4    => '(_1<swap>`K_3)(_2<swap>`K_4)',
    iflt4    => '(_2<swap>`K_4)(_1<swap>`K_3)',
    ifge4    => '(_2<swap>`K_3)(_1<swap>`K_4)',
    ifgt4    => '(_1<swap>`K_4)(_2<swap>`K_3)',
    ifleraw4 => '(_1<swap>_3)(_2<swap>_4)',
    ifgeraw4 => '(_2<swap>_3)(_1<swap>_4)',
    ifgt_two_3 => '(_1<swap>`K_3)(swap1(swap1(`K_2)))',
    ifnull2  => '_1(K(K0))(K_2)',
    _car     => 'true',
    _cdr     => 'false',
    car1     => '_1K',
    cdr1     => '_1`KI',
    setcar1  => 'S(SI`K_1)',    # (car1 (setcar1 a b)) ==> a, (cdr1 (setcar1 a b)) ==> (cdr1 b)
    setcdr2  => 'S(SI_2)`K_1',  # (car1 (setcdr1 a b)) ==> (car1 b), (cdr1 (setcdr1 a b)) ==> a
    setcdr1  => 'S(SS`K`K_1)',
    'cons-car-i2'  => 'S(SI_1)`K_2',
    nnot     => 'SI`K`KI', # = cdr
    nnot1    => '_1`KI',
    ifnz2    => '_1`K_2',
    ifz2     => '_1`KI`K_2',
    true     => 'K',
    false    => 'KI',
    o        => '<ucc>',
    o1       => 'S`K_1',
    i2       => '_1 _2',
    i3       => '_1 _2 _3',

    badd1    => 'S(S_1S)',
    bmul1    => 'S(SI_1)',
    );

$macros{"o-cdr2"}='_2(K_1)';
$macros{"o-cdr1"}='SI`K`K_1';
$macros{"apply-car-cdr2"}='S(S(SI`K_1)`K_2)'; #'[p. p _1 _2 (_3 p) ]';

# see two+weeks+per+column+calendar
#$macros{"forward"}='S`K`S(S`KS`SI)(S`K`S`KK(S`K`SI(S`KKK)))'; #	[f.[r. setcdr2 o-cdr2 f r r ]]

$macros{"forward"}='S`KS(S`K`S(SI0)K)'; # [f. apply-car-cdr2 I f]
$macros{"forward1"}='S(S(SI0)`K_1)';


1;
