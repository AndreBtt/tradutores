int main() {
  List<int> a;
  a = {9, 15, 8, 7, 9, 9, 1, 5};
  
  float c;
  c = Med(a);
  writeFloat c;

  c = Avg(a);
  writeFloat c;

  c = Md(a);
  writeFloat c;

  return 0;
}