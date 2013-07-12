require 'rspec'

require 'prototypical_inheritance'

describe Hash do

  let(:pele) do
    {:name => "Pele", :sport => "football", :position => "Forward"}
  end

  let(:pele_jr) do
    pele_jr           = {:name => "Pele Jr."}
    pele_jr.prototype = pele
    pele_jr
  end

  it 'should provide method-accessors' do
    pele_jr.name.should == "Pele Jr."
  end

  it 'use the parent hash as "defaults"' do
    include PrototypicalInheritance

    pele =
        pele_jr.name # => "Pele Jr."
    pele_jr.sport    # => "football"
    pele_jr.position # => "forward"

  end

  describe "performance" do
    before do
      require 'benchmark'
      include Benchmark
    end

    it 'should perform well' do
      key_count    = 10_000
      lookup_count = 100_000

      huge_parent = Hash[(1..key_count).map { |i| ["key#{i}".to_sym, i] }]

      inherited           = {}
      inherited.prototype = huge_parent

      lookups = (1..lookup_count).map { "key#{rand(key_count)}" }

      time = Benchmark.realtime {
        lookups.each { |key| inherited.send(key) }
      }

      puts "    Persisted    Time: #{time} s"

      time.should < 2


    end

    it 'should not perform better with method_persistence on huge objects' do
      key_count    = 40_000
      lookup_count = 400_000

      huge_parent = Hash[(1..key_count).map { |i| ["key#{i}".to_sym, i] }]

      non_persisted           = {}
      non_persisted.prototype = huge_parent

      non_persisted_lookups = (1..lookup_count).map { "key#{rand(key_count)}" }

      non_persisted_time = Benchmark.realtime {
        non_persisted_lookups.each { |key| non_persisted.send(key) }
      }

      puts "    Non-Persisted Time: #{non_persisted_time} s"

      persisted           = {}
      persisted.persisted_prototype = huge_parent

      persisted_lookups = (1..lookup_count).map { "key#{rand(key_count)}" }

      persisted_time = Benchmark.realtime {
        persisted_lookups.each { |key| persisted.send(key) }
      }

      puts "    Persisted    Time: #{persisted_time} s"

      persisted_time.should > non_persisted_time

    end

    it 'should not perform better with method_persistence on repeated objects' do
      key_count    = 100
      lookup_count = 400_000

      parent = Hash[(1..key_count).map { |i| ["key#{i}".to_sym, i] }]

      non_persisted           = {}
      non_persisted.prototype = parent

      non_persisted_lookups = (1..lookup_count).map { "key#{rand(key_count)}" }

      non_persisted_time = Benchmark.realtime {
        non_persisted_lookups.each { |key| non_persisted.send(key) }
      }

      puts "    Non-Persisted Time: #{non_persisted_time} s"

      persisted           = {}
      persisted.persisted_prototype = parent

      persisted_lookups = (1..lookup_count).map { "key#{rand(key_count)}" }

      persisted_time = Benchmark.realtime {
        persisted_lookups.each { |key| persisted.send(key) }
      }

      puts "    Persisted    Time: #{persisted_time} s"

      persisted_time.should be_within(0.02).of(non_persisted_time)

    end
  end

end