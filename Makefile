VERSION=0.1.1

release:
	(cd java; ant jar javadoc)
	tar czv --exclude=.svn --exclude=semantic.cache -f dataformat-$(VERSION).tar.gz python/arff.py ruby/arff.rb ruby/arff_test.rb matlab/arffload.m matlab/arffsave.m java LICENSE README