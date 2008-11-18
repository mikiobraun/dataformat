require 'test/unit'
require 'arff'

class ArffTest < Test::Unit::TestCase
  def parse(s)
    ARFF::ARFFFile.parse s
  end
  

  def test_comment
    a = parse '% first comment'
    assert_equal ['first comment'], a.comment
  end

  def test_relation
    a = parse '@relation test'
    assert_equal 'test', a.relation
    a = parse '@RELATION test'
    assert_equal 'test', a.relation
  end

  def test_real_attribute
    a = parse '@attribute foo real'
    assert_equal ['foo'], a.attribute_names
    assert_equal :numeric, a.attribute_types['foo']
    assert_equal nil, a.attribute_data['foo']

    a = parse '@attribute \'foo\' integer'
    assert_equal ['foo'], a.attribute_names
    assert_equal :numeric, a.attribute_types['foo']
    assert_equal nil, a.attribute_data['foo']
  end

  def test_nominal_attribute
    a = parse '@attribute foo { 1, 2, 3 }'
    assert_equal :nominal, a.attribute_types['foo']
    assert_equal %w(1 2 3), a.attribute_data['foo']
  end

  def test_data
    puts "This should emit two warnings on line 6 and 7!"
    a = parse <<EOS
@attribute a real
@attribute b string
@attribute c { yes, no }
@data
1.0, 'hello', no
foo, 3, argh
oh, 'no, well', blah
EOS
    assert_equal [[1.0, "'hello'", 'no']], a.data
  end

  def test_load
    return
    require 'pp'
    Dir.glob('../examples/*.arff').each do |file|
      puts '-' * 70
      a = ARFF::ARFFFile.load(file)
      puts a.dump
      a.save('temp.arff')
      b = ARFF::ARFFFile.load('temp.arff')
      puts b.dump
    end
  end
end
