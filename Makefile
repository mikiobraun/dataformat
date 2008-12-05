VERSION=0.1

release:
	(cd java; ant jar javadoc)
	tar czvf dataformat-$(VERSION).tgz python/arff.py ruby/arff.rb ruby/arff_test.rb matlab/arffload.m matlab/arffsave.m java/dist LICENSE README