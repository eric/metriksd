module Metriksd
  class LibratoMetricsReporter::TimesliceRollup
    class AverageGauge
      attr_accessor :name, :source, :count, :sum, :sum_of_squares, :min, :max

      def initialize(name, source)
        @name           = name
        @source         = source
        @count          = 0
        @sum            = 0
        @sum_of_squares = 0
        @min            = nil
        @max            = nil
      end

      def mark(value)
        @count += 1
        @sum += value
        @sum_of_squares += value ** 2

        if !@min || value < @min
          @min = value
        end

        if !@max || value > @max
          @max = value
        end
      end

      def to_hash
        {
          :name => name,
          :source => source,
          :count => count,
          :sum => sum,
          :sum_of_squares => sum_of_squares,
          :min => min,
          :max => max
        }
      end
    end

    class SumGauge
      attr_accessor :name, :source, :value

      def initialize(name, source)
        @name   = name
        @source = source
        @value  = 0
      end

      def mark(value)
        @value += value
      end

      def to_hash
        {
          :name => name,
          :source => source,
          :value => value
        }
      end
    end

    def initialize(timeslice)
      @timeslice = timeslice
    end

    def process
      return if @gauges
      @gauges = {}

      @timeslice.flush.each do |data|
        case data[:type]
        when 'counter'
          add_counter(data)
        when 'timer'
          add_timer(data)
        when 'utilization_timer'
          add_utilization_timer(data)
        when 'meter'
          add_meter(data)
        else
          raise "Unknown data type: #{data[:type].inspect}"
        end
      end
    end

    def to_hash
      process

      @gauges.map do |name, gauge|
        [ gauge.name, gauge.to_hash.merge(:measure_time => @timeslice.time) ]
      end
    end

    def add_counter(data)
      counter(data.name, data[:source], data[:count])
    end

    def add_timer(data)
      average_gauge(data.name + '.mean', data[:source], data[:mean])
      sum_gauge(data.name + '.one_minute_rate', data[:source], data[:one_minute_rate])

      if data[:median]
        average_gauge(data.name + '.median', data[:source], data[:median])
      end

      if data["95th_percentile"]
        average_gauge(data.name + '.95th_percentile', data[:source], data["95th_percentile"])
      end
    end

    def add_utilization_timer(data)
      average_gauge(data.name + '.mean', data[:source], data[:mean])
      sum_gauge(data.name + '.one_minute_rate', data[:source], data[:one_minute_rate])
      average_gauge(data.name + '.one_minute_utilization', data[:source], data[:one_minute_utilization])

      if data[:median]
        average_gauge(data.name + '.median', data[:source], data[:median])
      end

      if data["95th_percentile"]
        average_gauge(data.name + '.95th_percentile', data[:source], data["95th_percentile"])
      end
    end

    def add_meter(data)
      sum_gauge(data.name, data[:source], data[:one_minute_rate])
    end

    def average_gauge(name, source, value)
      key = [ name, source ].join('/')
      @gauges[key] ||= AverageGauge.new(name, source)
      @gauges[key].mark(value)
    end

    def sum_gauge(name, source, value)
      key = [ name, source ].join('/')
      @gauges[key] ||= SumGauge.new(name, source)
      @gauges[key].mark(value)
    end
  end
end
