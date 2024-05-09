/* Source: https://lists.gnu.org/r/bug-gnulib/2010-12/msg00165.html  */

#include <stdio.h>

int main()
{
  FILE *fp;
  int flags1, flags2, flags3, flags4, flags5, flags6, flags7;
  int i;
  char buf[80];

  fp = fopen ("test1234", "w");
  flags1 = fp->_flag;
  fwrite ("foo", 1, 3, fp);
  flags2 = fp->_flag;
  for (i = 0; i < 10000; i++)
    fwrite ("x", 1, 1, fp);
  fclose (fp);
  fp = fopen ("test1234", "r");
  flags3 = fp->_flag;
  fgetc (fp);
  flags4 = fp->_flag;
  close (fp->_file);
  for (i = 0; i < 10000; i++)
    fread (buf, 1, 1, fp);
  flags5 = fp->_flag;
  fclose (fp);
  fp = fopen ("test1234", "r+w");
  flags6 = fp->_flag;
  fgetc (fp);
  flags7 = fp->_flag;

  printf ("#define _IOERR 0x%X\n", flags5 & ~flags4);
  printf ("#define _IOREAD 0x%X\n", flags3);
  printf ("#define _IOWRT 0x%X\n", flags1);
  printf ("#define _IORW 0x%X\n", flags6);
  printf ("#define _IORW 0x%X\n", flags7 & ~flags4);

  return 0;
}
