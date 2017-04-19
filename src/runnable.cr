module Minitest
  class Runnable
    macro def self.runnables : Array(Runnable.class)
      {% begin %}
        [self, {{ @type.all_subclasses.join(", ").id }}]
      {% end %}
    end

    alias Data = {Test.class, String, Proc(Test, Nil)}
    @@tests = [] of Data

    def self.tests
      @@tests
    end

    # Builds, at compile time, an Array with the test method name (String) and a
    # proc to call that method. The Array will then be shuffled at runtime.
    macro def self.collect_tests
      {% begin %}
        {% for name in @type.methods.map(&.name).select(&.starts_with?("test_")) %}
          %proc = ->(test : Test) {
            test.as({{ @type }}).{{ name }}
            nil
          }
          Runnable.tests << { {{ @type }}, {{ name.stringify }}, %proc }
        {% end %}
      {% end %}
      nil
    end

    getter reporter : AbstractReporter

    def initialize(@reporter)
    end
  end
end
