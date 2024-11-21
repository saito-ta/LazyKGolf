  if(is_cons(v)){
    // Ia => a
    if(carof(v)==mk_comb('I')){
      return opt(cdrof(v));
    }
    // Kab => a
    if(is_cons(carof(v)) && carof(carof(v))==mk_comb('K')){
      return opt(cdrof(carof(v)));
    }
    // SK => KI
    if(carof(v)==mk_comb('S')&&cdrof(v)==mk_comb('K')){
      cells[celln].car=mk_comb('K');
      cells[celln].cdr=mk_comb('I');
      return opt(mk_cons(celln++));
    }
    // SII(ab) => SSIab
    if(is_cons(carof(v))
       && is_cons(carof(carof(v)))
       && carof(carof(carof(v)))==mk_comb('S')
       && cdrof(carof(carof(v)))==mk_comb('I')
       && cdrof(carof(v))==mk_comb('I')
       && is_cons(cdrof(v))
       ) {
      int i1=celln++;
      int i2=celln++;
      int i3=celln++;
      int i4=celln++;
      cells[i1].car=mk_comb('S');
      cells[i1].cdr=mk_comb('S');
      cells[i2].car=mk_cons(i1);
      cells[i2].cdr=mk_comb('I');
      cells[i3].car=mk_cons(i2);
      cells[i3].cdr=carof(cdrof(v));
      cells[i4].car=mk_cons(i3);
      cells[i4].cdr=cdrof(cdrof(v));
      return opt(mk_cons(i4));
    }
#if 0
    // S(S`KSK) => SISSKSK # S`SSKSK
    // succ
    if(carof(v)==mk_comb('S')
       && is_cons(cdrof(v))
       && is_cons(carof(cdrof(v)))
       && carof(carof(cdrof(v)))==mk_comb('S')
       && is_cons(cdrof(carof(cdrof(v))))
       && carof(cdrof(carof(cdrof(v))))==mk_comb('K')
       && cdrof(cdrof(carof(cdrof(v))))==mk_comb('S')
       && cdrof(cdrof(v))==mk_comb('K')
       ) {
      int i1=celln++;
      int i2=celln++;
      int i3=celln++;
      int i4=celln++;
      int i5=celln++;
      int i6=celln++;
      cells[i1].car=S;
      cells[i1].cdr=I;
      cells[i2].car=mk_cons(i1);
      cells[i2].cdr=S;
      cells[i3].car=mk_cons(i2);
      cells[i3].cdr=S;
      cells[i4].car=mk_cons(i3);
      cells[i4].cdr=K;
      cells[i5].car=mk_cons(i4);
      cells[i5].cdr=S;
      cells[i6].car=mk_cons(i5);
      cells[i6].cdr=K;
      return opt(mk_cons(i6));
    }
#else
    // SISSKSK => S(S`KSK) =>  # S`SSKSK
    // succ
    if(cdrof(v)==K
       && is_cons(carof(v)) && cdrof(carof(v))==S
       && is_cons(carof(carof(v))) && cdrof(carof(carof(v)))==K
       && is_cons(carof(carof(carof(v)))) && cdrof(carof(carof(carof(v))))==S
       && is_cons(carof(carof(carof(carof(v))))) && cdrof(carof(carof(carof(carof(v)))))==S
       && is_cons(carof(carof(carof(carof(carof(v)))))) && cdrof(carof(carof(carof(carof(carof(v))))))==I
                                                        && carof(carof(carof(carof(carof(carof(v))))))==S
       ) {
      int i1=celln++;
      int i2=celln++;
      int i3=celln++;
      int i4=celln++;
      cells[i1].car=S;
      cells[i1].cdr=mk_cons(i2);
      cells[i2].car=mk_cons(i3);
      cells[i2].cdr=K;
      cells[i3].car=S;
      cells[i3].cdr=mk_cons(i4);
      cells[i4].car=K;
      cells[i4].cdr=S;
      return opt(mk_cons(i1));
    }
#endif
    // SSS`KS => SISSKS
    if(          is_cons(carof(v))
       &&  is_cons(carof(carof(v)))
       &&    carof(carof(carof(v)))==S
       &&    cdrof(carof(carof(v)))==S
       &&          cdrof(carof(v))==S
       &&        is_cons(cdrof(v))
       &&          carof(cdrof(v))==K
       &&          cdrof(cdrof(v))==S
       ) {
      int i1=celln++;
      int i2=celln++;
      int i3=celln++;
      int i4=celln++;
      int i5=celln++;
      cells[i1].car=S;
      cells[i1].cdr=I;
      cells[i2].car=mk_cons(i1);
      cells[i2].cdr=S;
      cells[i3].car=mk_cons(i2);
      cells[i3].cdr=S;
      cells[i4].car=mk_cons(i3);
      cells[i4].cdr=K;
      cells[i5].car=mk_cons(i4);
      cells[i5].cdr=S;
      return opt(mk_cons(i5));
    }
#if 0
    // negative
    // S`aS => SIaS
    if(carof(v)==S
       && is_cons(cdrof(v))
       && cdrof(cdrof(v))==S
       ) {
      int i1=celln++;
      int i2=celln++;
      int i3=celln++;
      cells[i1].car=S;
      cells[i1].cdr=I;
      cells[i2].car=mk_cons(i1);
      cells[i2].cdr=carof(cdrof(v)); // a
      cells[i3].car=mk_cons(i2);
      cells[i3].cdr=S;
      return opt(mk_cons(i3));
    }
#endif
    // S(SI`KK)`K`aK => S(SS`Ka)`KK
    // cons K aK
    if(is_cons(carof(v))
       && carof(carof(v))==mk_comb('S')
       && is_cons(cdrof(carof(v)))
       && is_cons(carof(cdrof(carof(v))))
       && carof(carof(cdrof(carof(v))))==mk_comb('S')
       && cdrof(carof(cdrof(carof(v))))==mk_comb('I')
       && is_cons(cdrof(cdrof(carof(v))))
       && carof(cdrof(cdrof(carof(v))))==mk_comb('K')
       && cdrof(cdrof(cdrof(carof(v))))==mk_comb('K')
       && is_cons(cdrof(v))
       && carof(cdrof(v))==mk_comb('K')
       && is_cons(cdrof(cdrof(v)))
       && is_novar(carof(cdrof(cdrof(v))))
       &&   cdrof(cdrof(cdrof(v)))==mk_comb('K')
       ) {
      int i1=celln++;
      int i2=celln++;
      int i3=celln++;
      int i4=celln++;
      int i5=celln++;
      cells[i1].car=mk_comb('S');
      cells[i1].cdr=mk_cons(i2);
      cells[i2].car=mk_cons(i3);
      cells[i2].cdr=mk_cons(i4);
      cells[i3].car=mk_comb('S');
      cells[i3].cdr=mk_comb('S');
      cells[i4].car=mk_comb('K');
      cells[i4].cdr=carof(cdrof(cdrof(v)));
      cells[i5].car=mk_cons(i1);
      cells[i5].cdr=cdrof(cdrof(carof(v)));
      return opt(mk_cons(i5));
    }
    // Sa(SIa) => S`SIa
    if(         is_cons(carof(v))
       &&         carof(carof(v))==S
       &&       is_cons(cdrof(v))
       && is_cons(carof(cdrof(v)))
       &&   carof(carof(cdrof(v)))==S
       &&   cdrof(carof(cdrof(v)))==I
       && is_same(cdrof(carof(v)),cdrof(cdrof(v)))
       ) {
      int i1=celln++;
      int i2=celln++;
      cells[i1].car=S;
      cells[i1].cdr=carof(cdrof(v)); // SI
      cells[i2].car=mk_cons(i1);
      cells[i2].cdr=cdrof(carof(v));
      return opt(mk_cons(i2));
    }
    // Sa(SII) => S`SaI
    if(is_cons(carof(v))
       && carof(carof(v))==S
       && is_cons(cdrof(v))
       && is_cons(carof(cdrof(v)))
       && carof(carof(cdrof(v)))==S
       && cdrof(carof(cdrof(v)))==I
       && cdrof(cdrof(v))==I
       ) {
      int i1=celln++;
      int i2=celln++;
      int i3=celln++;
      cells[i1].car=mk_cons(i2);
      cells[i1].cdr=I;
      cells[i2].car=S;
      cells[i2].cdr=mk_cons(i3);
      cells[i3].car=S;
      cells[i3].cdr=cdrof(carof(v));
      return opt(mk_cons(i1));
    }
    // SS`SI => S`SI
    if(         is_cons(carof(v))
       &&         carof(carof(v))==S
       &&         cdrof(carof(v))==S
       &&       is_cons(cdrof(v))
       &&         carof(cdrof(v))==S
       &&         cdrof(cdrof(v))==I
       ) {
      int i1=celln++;
      cells[i1].car=S;
      cells[i1].cdr=cdrof(v); // SI
      return opt(mk_cons(i1));
    }
    // S(SIKSa) => S`SSKSa
    if(            carof(v) == S
       &&  is_cons(cdrof(v))
       &&  is_cons(carof(cdrof(v)))
       &&  is_cons(carof(carof(cdrof(v))))
       &&  is_cons(carof(carof(carof(cdrof(v)))))
       &&  carof(carof(carof(carof(cdrof(v))))) == S
       &&  cdrof(carof(carof(carof(cdrof(v))))) == I
       &&  cdrof(carof(carof(cdrof(v)))) == K
       &&  cdrof(carof(cdrof(v))) == S
    ) {
      int i1=celln++;
      int i2=celln++;
      int i3=celln++;
      int i4=celln++;
      int i5=celln++;
      cells[i1].car=S;
      cells[i1].cdr=S;
      cells[i2].car=S;
      cells[i2].cdr=mk_cons(i1);
      cells[i3].car=mk_cons(i2);
      cells[i3].cdr=K;
      cells[i4].car=mk_cons(i3);
      cells[i4].cdr=S;
      cells[i5].car=mk_cons(i4);
      cells[i5].cdr=cdrof(cdrof(v));
      return opt(mk_cons(i5));
    }
  }
