int f(int a, float b) {
  return 1;
}

int main() {
  int x;
  x = 3;
  float y;
  y = 9.5;

  f(y, y);
  f(1, 2, 3);
  f(1);
  f(x, x);
  f(1.0, y);
  f(1, 1);

  return 1;
}