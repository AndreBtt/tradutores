float imprimir(float v) {
  writeFloat v;

  return v;
}

int main() {
  int a,b,c;
  readInt a;
  readInt b;
  readInt c;

  if (a + b == c) {
    float v;
    v = a + b - c;
    v = imprimir(v);

    List<int> l;
    l = {10, 15, 5, 10};
    
    float media;
    media = Avg(l);

    if (v == media) {
      List <float> lista3;
      lista3 = {1.4, 1.4, 2.1, 3.2};
      float moda;
      moda = Md(lista3);
      v = moda;
    }

    v = media;

    while (v > 0) {
      writeFloat v;
      v = v - 1;
    }
  }

  return 1;
}