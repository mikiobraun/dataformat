#ifndef ARFF_H
#define ARFF_H

enum arff_types { 
  AT_NUMERIC = 1,
  AT_STRING,
  AT_NOMINAL
};

struct arff {
  char *comment;  // initial comment of the file
  char *relation; // name of the relation
  int size;       // number of datapoints
  char **attributes; // names of the attributes
  enum arff_types *attribute_types;
  char **attribute_data;
};

typedef struct arff *arff_t;

extern void arff_new();
extern arff_t arff_load(char *filename);

/* free an arff structure with everything */
extern void arff_free(arff_t a);

#endif
