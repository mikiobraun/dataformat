import re

class ArffFile(object):
    def __init__(self):
        self.relation = ''
        self.attributes = []
        self.attribute_types = dict()
        self.attribute_data = dict()
        self.comment = []
        self.data = []
        pass

    @staticmethod
    def load(filename):
        """Load an ARFF File from a file."""
        o = open(filename)
        s = o.read()
        a = ArffFile.parse(s)
        o.close()
        return a

    @staticmethod
    def parse(s):
        """Parse an ARFF File already loaded into a string."""
        a = ArffFile()
        a.state = 'comment'
        a.lineno = 1
        for l in s.splitlines():
            a.parseline(l)
            a.lineno += 1
        return a

    def define_attribute(self, name, atype, data=None):
        self.attributes.append(name)
        self.attribute_types[name] = atype
        self.attribute_data[name] = data

    def parseline(self, l):
        if self.state == 'comment':
            if len(l) > 0 and l[0] == '%':
                self.comment.append(l)
            else:
                self.state = 'in_header'
                self.parseline(l)
        elif self.state == 'in_header':
            ll = l.lower()
            if ll.startswith('@relation '):
                self.parse_relation(l)
            if ll.startswith('@attribute '):
                self.parse_attribute(l)
            if ll.startswith('@data'):
                self.state = 'data'
        elif self.state == 'data':
            if len(l) > 0 and l[0] != '%':
                self.parse_data(l)

    def parse_relation(self, l):
        l = l.split()
        self.relation = l[1]

    def parse_attribute(self, l):
        p = re.compile(r'[a-zA-Z_][a-zA-Z0-9_]*|\{[^\}]+\}|\'[^\']+\'|\"[^\"]+\"')
        l = [s.strip() for s in p.findall(l)]
        name = l[1]
        atype = l[2].lower()
        if (atype == 'real' or
            atype == 'numeric' or
            atype == 'integer'):
            self.define_attribute(name, 'numeric')
        elif atype == 'string':
            self.define_attribute(name, 'string')
        elif atype[0] == '{' and atype[-1] == '}':
            values = [s.strip () for s in atype[1:-1].split(',')]
            self.define_attribute(name, 'nominal', values)
        else:
            print "Unsupported type " + atype + " for attribute " + name + "."

    def parse_data(self, l):
        l = [s.strip() for s in l.split(',')]
        if len(l) != len(self.attributes):
            print "Warning: line %d contains wrong number of values" % self.lineno
            return 

        datum = []
        for n, v in zip(self.attributes, l):
            at = self.attribute_types[n]
            if at == 'numeric':
                if re.match(r'[+-]?[0-9]+(?:\.[0-9]*(?:[eE]-?[0-9]+)?)?', v):
                    datum.append(float(v))
                else:
                    self.print_warning('non-numeric value %s for numeric attribute %s' % (v, n))
                    return
            elif at == 'string':
                datum.append(v)
            elif at == 'nominal':
                if v in self.attribute_data[n]:
                    datum.append(v)
                else:
                    self.print_warning('incorrect value %s for nomial attribute %s' % (v, n))
                    return
        self.data.append(datum)

    def print_warning(self, msg):
        print ('Warning (line %d): ' % self.lineno) + msg

    def dump(self):
        print "Relation " + self.relation
        print "  With attributes"
        for n in self.attributes:
            if self.attribute_types[n] != 'nominal':
                print "    %s of type %s" % (n, self.attribute_types[n])
            else:
                print ("    " + n + " of type nominal with values " +
                       ', '.join(self.attribute_data[n]))
        for d in self.data:
            print d
    

#a = ArffFile.read('../examples/diabetes.arff')

a = ArffFile.parse("""@relation foobar
@attribute foo {a,b,c}
@attribute bar real
@data
a, 1
b, 2
c, d
d, 3
""")
a.dump()

