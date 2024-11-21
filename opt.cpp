#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <iostream>
#include <string>
#include <set>
#include <queue>

#define DIE() die("died. line=%d",__LINE__)

void die(char const * fmt = "died.", ...){
  va_list ap;
  char buf[256];
  va_start(ap,fmt);
  vsprintf(buf,fmt,ap);
  va_end(ap);
  std::cerr << buf << std::endl;
  exit(1);
}

typedef unsigned val_t;
typedef unsigned cellref_t;

bool is_cons(val_t v){ return (v&7)==0; }
bool is_comb(val_t v){ return (v&7)==1; }
bool is_lambda(val_t v){ return (v&7)==2; }
bool is_var(val_t v){ return (v&7)==3; }
bool is_free(val_t v){ return (v&7)==4; }
bool is_end(val_t v){ return (v&7)==7; }

val_t mk_cons(int i){ return i<<3; }
val_t mk_comb(int c){ return c<<3|1; }
val_t mk_lambda(){ return 2; }
val_t mk_var(int i){ return i<<3|3; }
val_t mk_free(int c){ return c<<3|4; }
val_t mk_end(){ return ~0; }

#define I (mk_comb('I'))
#define K (mk_comb('K'))
#define S (mk_comb('S'))

cellref_t mk_cellref(int i,int j){ return i<<3|j; }

struct Ent {
  std::string s;
  //int ll;  // lembda level
  int len;  // length in combinator form
};

bool operator<(Ent const & e1, Ent const & e2){
  //return (20<<e1.ll)+e1.s.size() > (20<<e2.ll)+e2.s.size();
  //return (20*e1.ll)+e1.s.size() > (20*e2.ll)+e2.s.size();
  //return e1.len > e2.len;
  //return e1.len > e2.len || e1.len == e2.len && e1.s.size() > e2.s.size();
  return e1.s.size() > e2.s.size() || e1.s.size() == e2.s.size() && e1.len > e2.len;
}

std::priority_queue<Ent> pq;

typedef unsigned long long hash_t;

std::set<hash_t> ahashset;

struct Cell {
  val_t car;
  val_t cdr;
};

Cell cells[1000000];
int celln;

val_t carof(val_t t){ return cells[t>>3].car; }
val_t cdrof(val_t t){ return cells[t>>3].cdr; }
void setpart(cellref_t r,val_t v){ (r&1 ? cells[r>>3].cdr : cells[r>>3].car)=v; }
val_t getpart(cellref_t r){ return r&1 ? cells[r>>3].cdr : cells[r>>3].car; }

char const * pe;
int lambdaroot;
cellref_t lambdaref;

val_t parse_one(int end);

val_t parse_many(int end){
  val_t v=parse_one(end);
  if(is_end(v)) DIE();
  val_t v2;
  while(v2=parse_one(end), !is_end(v2)){
    cells[celln].car=v;
    cells[celln].cdr=v2;
    v=mk_cons(celln++);
  }
  return v;
}

val_t parse_one(int end){
  int c;
  do {
    c=*pe++;
  } while(c==10 || c==32);
  if(c==end){
    return mk_end();
  }
  switch(c){
  case '(':
    return parse_many(')');
  case '`':
    {
      int i=celln++;
      cells[i].car=parse_one(-1);
      cells[i].cdr=parse_one(-1);
      return mk_cons(i);
    }
  case '0':
    cells[celln].car=K;
    cells[celln].cdr=I;
    return mk_cons(celln++);
  case 'S':
    return S;
  case 'K':
    return K;
  case 'I':
    return I;
  case '[':
    lambdaroot=celln;
    {
      int i=celln++;
      cells[i].car=mk_lambda();
      cells[i].cdr=parse_many(']');
      return mk_cons(i);
    }
  case 'v':
    {
      int i;
      i=(*pe++-48)*10;
      i+=*pe++-48;
      return mk_var(i);
    }
  default:
    if(c>='a'&&c<='z'){
      return mk_free(c);
    }
    die("c=%d",c);
  }
}

val_t parse(std::string const & s){
  char const * saved_pe=pe;
  pe=s.c_str();
  val_t v=parse_many(0);
  pe=saved_pe;
  return v;
}

bool is_same(val_t v1,val_t v2){
  if(v1==v2) return true;
  if(is_cons(v1)&&is_cons(v2)){
    return is_same(carof(v1),carof(v2)) && is_same(cdrof(v1),cdrof(v2));
  }
  return false;
}

bool is_novar(val_t v){
  if(is_cons(v)){
    return is_novar(carof(v))&&is_novar(carof(v));
  }
  return !is_var(v);
}

val_t opt(val_t v){
  #include "optsub.cpp"
  if(is_cons(v)){
      val_t v_car=opt(carof(v));
      val_t v_cdr=opt(cdrof(v));
      if(v_car==carof(v)&&v_cdr==cdrof(v)){
        return v;
      }
      cells[celln].car=v_car;
      cells[celln].cdr=v_cdr;
      return opt(mk_cons(celln++));
  }
  return v;
}

hash_t calc_hash( val_t v ){
  hash_t h;
  if( is_cons(v) ) {
    h=calc_hash(carof(v))*131071+calc_hash(cdrof(v))*3415408;
  }else{
    h=v;
  }
  return h;
}

bool is_ki(val_t v){
  return is_cons(v) && ( carof(v)==K && cdrof(v)==I || carof(v)==S && cdrof(v)==K );
}

//int lambdalevel;
std::string strfy( val_t v, bool need_paren=false) {
  std::string s;
  if(is_cons(v)){
    if(is_ki(v)){
      s+="0";
    }else if(is_lambda(carof(v))){
      //++lambdalevel;
      s+="[";
      s+=strfy(cdrof(v));
      s+="]";
    }else{
      char const * opening="";
      char const * closing="";
      if(need_paren){
        if(is_cons(v)&&!is_ki(v)){
          if(carof(v)==I) DIE();
          if(is_cons(carof(v))){
            if(is_ki(carof(v))) DIE();
            if(carof(carof(v))==K) DIE();
            opening="(";
            closing=")";
          }else{
            opening="`";
          }
        }
      }
      s+=opening;
      s+=strfy(carof(v),false);
      s+=strfy(cdrof(v),true);
      s+=closing;
    }
  }else if(is_lambda(v)){
    DIE();
  }else if(is_comb(v)||is_free(v)){
    s+=(char)(v>>3);
  }else if(is_var(v)){
    int varid=v>>3;
    if(varid>=100) DIE();
    s+="v";
    s+=(char)(varid/10+'0');
    s+=(char)(varid%10+'0');
  }else{
    die("v=%d",v);
  }
  return s;
}

bool is_s1(val_t v){
  return is_cons(v) && carof(v)==S;
}

bool is_s2(val_t v){
  return is_cons(v) && is_s1(carof(v));
}

bool is_s3(val_t v){
  return is_cons(v) && is_s2(carof(v));
}

bool is_vnfree(val_t v,val_t vn){
  if(v==vn){
    return false;
  }
  if(is_cons(v)){
    if(is_lambda(carof(v))){
      return is_vnfree(cdrof(v),vn+8);
    }
    return is_vnfree(carof(v),vn) && is_vnfree(cdrof(v),vn);
  }
  return true;
}

bool is_v0free(val_t v){
  return is_vnfree(v,mk_var(0));
}

val_t inc_vars(val_t v){
  if(is_var(v)){
    return v+8;
  }
  if(is_cons(v)){
    val_t v_car=inc_vars(carof(v));
    val_t v_cdr=inc_vars(cdrof(v));
    if(v_car==carof(v) && v_cdr==cdrof(v)){
      return v;
    }
    cells[celln].car=v_car;
    cells[celln].cdr=v_cdr;
    return mk_cons(celln++);
  }
  if(is_comb(v)||is_free(v)){
    return v;
  }
  if(is_lambda(v)){
    DIE();
  }
  DIE();
}

val_t dec_vars(val_t v,int level=0){
  if(is_var(v)){
    if(v==mk_var(0)&&level==0){
      DIE();
    }
    return (v>>3)<level ? v : v-8;
  }
  if(is_cons(v)){
    val_t v_car;
    val_t v_cdr;
    if(is_lambda(carof(v))){
      v_car=carof(v);
      v_cdr=dec_vars(cdrof(v),level+1);
    }else{
      v_car=dec_vars(carof(v),level);
      v_cdr=dec_vars(cdrof(v),level);
    }
    if(v_car==carof(v) && v_cdr==cdrof(v)){
      return v;
    }
    cells[celln].car=v_car;
    cells[celln].cdr=v_cdr;
    return mk_cons(celln++);
  }
  if(is_comb(v)||is_free(v)){
    return v;
  }
  if(is_lambda(v)){
    DIE();
  }
  DIE();
}

val_t delambda(val_t v){
  if(is_v0free(v)){
    int i=celln++;
    cells[i].car=K;
    cells[i].cdr=dec_vars(v);
    return mk_cons(i);
  }
  if(is_var(v)){
    if(v!=mk_var(0)){
      DIE();
    }
    return I;
  }
  if(is_cons(v)){
    if(cdrof(v)==mk_var(0) && is_v0free(carof(v))){
      // eta reduction
      return dec_vars(carof(v));
    }
    {
      int i1=celln++;
      int i2=celln++;
      cells[i1].car=S;
      cells[i1].cdr=delambda(carof(v));
      cells[i2].car=mk_cons(i1);
      cells[i2].cdr=delambda(cdrof(v));
      return mk_cons(i2);
    }
  }
  DIE();
}

val_t tconv_delambda(val_t v);
val_t tconv(val_t v){
  //printf(" tconv(%s)\n",strfy(v).c_str());
  if(is_cons(v)){
    if(is_lambda(carof(v))){
      return tconv(tconv_delambda(cdrof(v)));
    }else{
      val_t v_car=tconv(carof(v));
      val_t v_cdr=tconv(cdrof(v));
      if(v_car==carof(v)&&v_cdr==cdrof(v)){
        return v;
      }
      cells[celln].car=v_car;
      cells[celln].cdr=v_cdr;
      return mk_cons(celln++);
    }
  }
  if(is_var(v)||is_comb(v)||is_free(v)){
    return v;
  }
  if(is_lambda(v)){
    DIE();
  }
  DIE();
}

val_t tconv_delambda(val_t v){
  //printf(" tconv_delambda(%s)\n",strfy(v).c_str());
  if(is_cons(v) && is_lambda(carof(v))){
    return tconv_delambda(tconv_delambda(cdrof(v)));
  }
  if(is_var(v)){
    if(v==mk_var(0)){
      return I;
    }
    int i=celln++;
    cells[i].car=K;
    cells[i].cdr=v-8;
    return mk_cons(i);
  }
  if(is_v0free(v)){
    int i=celln++;
    cells[i].car=K;
    cells[i].cdr=tconv(dec_vars(v));
    return mk_cons(i);
  }
  if(is_cons(v)){
    if(cdrof(v)==mk_var(0) && is_v0free(carof(v))){
      // eta reduction
      return tconv(dec_vars(carof(v)));
    }
    {
      int i1=celln++;
      int i2=celln++;
      cells[i1].car=S;
      cells[i1].cdr=tconv_delambda(carof(v));
      cells[i2].car=mk_cons(i1);
      cells[i2].cdr=tconv_delambda(cdrof(v));
      return mk_cons(i2);
    }
  }
  DIE();
}

int best=99999;

void add(){
  int saved_celln = celln;
  val_t v=opt(cells[0].cdr);
  Ent e;
  e.s=strfy(v);
  {
    hash_t h=0;
    for(char c : e.s){
      h=h*131+c;
    }
    if(ahashset.find(h)!=ahashset.end()){
      return;
    }
    ahashset.insert(h);
  }
  //printf("adding: %s\n",e.s.c_str());
  {
    val_t tconvv=opt(tconv(v));
    std::string tconvs=strfy(tconvv);
    e.len=tconvs.size();
    if(best>e.len){
      best=e.len;
      std::cout << e.len << " " << tconvs << std::endl;
      {
	FILE * file = fopen("o.lazy","w");
	fprintf(file,"%s",tconvs.c_str());
	fclose(file);
      }
    }
  }
  pq.push(e);
  celln=saved_celln;
}

void modify(cellref_t r){
  val_t v=getpart(r);
  //std::cout << "modify(" << strfy(getpart(r),1) << ")" << std::endl;
  if((r&1)==1 && (is_s1(v)||is_s2(v))){
    //std::cout << "r=" << r << " v=" << v << " celln=" << celln << std::endl;
    // enlambda
    int saved_celln = celln;
    int i1=celln++;
    int i2=celln++;
    cells[i1].car=mk_lambda();
    cells[i1].cdr=mk_cons(i2);
    cells[i2].car=inc_vars(v);
    cells[i2].cdr=mk_var(0);
    setpart(r,mk_cons(i1));
    //std::cout << "i1=" << i1 << " i2=" << i2 << " celln=" << celln << std::endl;
    //printf("enlambda\n");
    add();
    setpart(r,v);
    celln = saved_celln;
  }
  if(is_s3(v)){
    int saved_celln = celln;
    int i1=celln++;
    int i2=celln++;
    int i3=celln++;
    cells[i1].car=mk_cons(i2);
    cells[i1].cdr=mk_cons(i3);
    cells[i2].car=cdrof(carof(carof(v)));
    cells[i2].cdr=cdrof(v);
    cells[i3].car=cdrof(carof(v));
    cells[i3].cdr=cdrof(v);
    setpart(r,mk_cons(i1));
    //printf("s3\n");
    add();
    setpart(r,v);
    celln = saved_celln;
  }
  if(is_cons(v)){
    if(is_lambda(carof(v))) DIE();
    if(is_cons(carof(v)) && is_cons(cdrof(v)) && is_same(cdrof(carof(v)),cdrof(cdrof(v)))){
      //printf("found same %s\n",strfy(cdrof(carof(v))).c_str());
      int saved_celln = celln;
      int i1=celln++;
      int i2=celln++;
      int i3=celln++;
      cells[i1].car=S;
      cells[i1].cdr=carof(carof(v));
      cells[i2].car=mk_cons(i1);
      cells[i2].cdr=carof(cdrof(v));
      cells[i3].car=mk_cons(i2);
      cells[i3].cdr=cdrof(carof(v));
      setpart(r,mk_cons(i3));
      //printf("same\n");
      add();
      setpart(r,v);
      celln = saved_celln;
    }
#if 1
    if(is_cons(cdrof(v)) && is_same(carof(v),cdrof(cdrof(v)))){
      //printf("found same %s\n",strfy(cdrof(carof(v))).c_str());
      int saved_celln = celln;
      int i1=celln++;
      int i2=celln++;
      int i3=celln++;
      cells[i1].car=S;
      cells[i1].cdr=I;
      cells[i2].car=mk_cons(i1);
      cells[i2].cdr=carof(cdrof(v));
      cells[i3].car=mk_cons(i2);
      cells[i3].cdr=carof(v);
      setpart(r,mk_cons(i3));
      //printf("same\n");
      add();
      setpart(r,v);
      celln = saved_celln;
    }
#else
    if(is_cons(carof(v)) && carof(carof(v))==S && cdrof(carof(v))==S && is_cons(cdrof(v)) && carof(cdrof(v))==S && cdrof(cdrof(v))==I ){
      int saved_celln = celln;
      int i1=celln++;
      cells[i1].car=S;
      cells[i1].cdr=cdrof(v);
      setpart(r,mk_cons(i1));
      add();
      setpart(r,v);
      celln = saved_celln;
    }
#endif
    if(is_cons(carof(v)) && is_same(cdrof(carof(v)),cdrof(v))){
      //printf("found same %s\n",strfy(cdrof(carof(v))).c_str());
      int saved_celln = celln;
      int i1=celln++;
      int i2=celln++;
      int i3=celln++;
      cells[i1].car=S;
      cells[i1].cdr=carof(carof(v));
      cells[i2].car=mk_cons(i1);
      cells[i2].cdr=I;
      cells[i3].car=mk_cons(i2);
      cells[i3].cdr=cdrof(v);
      setpart(r,mk_cons(i3));
      //printf("same\n");
      add();
      setpart(r,v);
      celln = saved_celln;
    }
    if(is_cons(carof(v)) && !is_v0free(cdrof(carof(v)))){
      int saved_celln = celln;
      int i1=celln++;
      int i2=celln++;
      int i3=celln++;
      int i4=celln++;
      cells[i1].car=S;
      cells[i1].cdr=carof(carof(v));
      cells[i2].car=K;
      cells[i2].cdr=cdrof(v);
      cells[i3].car=mk_cons(i1);
      cells[i3].cdr=mk_cons(i2);
      cells[i4].car=mk_cons(i3);
      cells[i4].cdr=cdrof(carof(v));
      setpart(r,mk_cons(i4));
      add();
      setpart(r,v);
      celln = saved_celln;
    }
    modify(v|0);
    modify(v|1);
  }
}

void add_init(){
#if 0
  Ent e;
  std::cin >> e.s;
  e.len=e.s.size();
  pq.push(e);
#else
  std::string s;
  std::cin >> s;
  lambdaroot=0;
  celln=1;
  cells[0].car=0;
  cells[0].cdr=parse(s);
  add();
#endif
}


bool search_lambdaref(cellref_t r){
  val_t v=getpart(r);
  if(is_cons(v)){
    if(v==mk_cons(lambdaroot)){
      lambdaref=r;
      return true;
    }
    return search_lambdaref(v|0) || search_lambdaref(v|1);
  }
  return false;
}

int verbose=0;

int main(int argc, char**argv){
  if(argc==2){
    verbose=1;
  }
  if(argc==3){
    verbose=2;
  }
  
  add_init();
  while(!pq.empty()){
    Ent e=pq.top();
    pq.pop();

    lambdaroot=0;
    celln=1;
    cells[0].car=0;
    cells[0].cdr=parse(e.s);

    if(verbose == 1){
      std::cout << e.len << " " << e.s.size() << std::endl;
    }
    if(verbose == 2){
      std::cout << e.len << " " << e.s.size() << " " << e.s << std::endl;
    }
#if 0
    if(lambdaroot==0){
      if(best>=e.s.size()){
        best=e.s.size();
        std::cout << e.s.size() << " " << e.s << std::endl;
      }
    }
#endif
    if(search_lambdaref(mk_cellref(0,1))){
      val_t v=getpart(lambdaref);
      if(!is_cons(v)) DIE();
      if(!is_lambda(carof(v))) DIE();
      int saved_celln = celln;
      val_t v1=delambda(cdrof(v));
      setpart(lambdaref,v1);
      //printf("delambda\n");
      add();
      setpart(lambdaref,v);
      celln = saved_celln;
    }
    modify(mk_cellref(lambdaroot,1));
  }
  return 0;
}
