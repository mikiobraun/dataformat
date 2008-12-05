# Copyright (c) 2008, Mikio L. Braun, Cheng Soon Ong, Soeren Sonnenburg
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#     * Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
# copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the
# distribution.
#     * Neither the names of the Technical University of Berlin, ETH
# Zürich, or Fraunhofer FIRST nor the names of its contributors may be
# used to endorse or promote products derived from this software without
# specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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
