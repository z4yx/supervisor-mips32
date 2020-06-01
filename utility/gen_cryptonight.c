#include <stdio.h>

void crn(int pad[], unsigned int a, unsigned int b, unsigned int n) {
  unsigned int k;
  for (k = 0; k != 0x80000; k++)
    pad[k] = k;
  for (k = 0; k != n; k++) {
    unsigned int t, addr1, addr2;
    addr1 = a & 0x7FFFF;
    t = (a >> 1) ^ (pad[addr1] << 1); // Replace the AES step
    pad[addr1] = t ^ b;
    addr2 = t & 0x7FFFF;
    b = t;
    t = pad[addr2];
    a += b * t;
    pad[addr2] = a;
    a ^= t;
  }
}

int main(int argc, char const *argv[]) {
  FILE *fp = fopen("crypto.bin", "wb");
  int pad[0x80000]; // 2MB
  crn(pad, 0xdeadbeef, 0xdeadbeef, 0x100000);
  fwrite(pad, 1, sizeof(pad), fp);
  fclose(fp);
  return 0;
}
