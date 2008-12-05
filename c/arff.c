#include <stdio.h>
#include "arff.h"

arff_t arff_load(char *filename)
{
  FILE *f = fopen(filename, "r");

  while(!feof(f)) {
    
  }

  fclose(f);
}

static
void readline(FILE *f)
{
}
