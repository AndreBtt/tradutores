int f(int a, float b) {
  b = 9;

  return a;
}

int main() {
  int b;
  b = 8;

  f(b, 1.0);

  b = 5;

  return 1;
}