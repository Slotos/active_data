module ActiveData
  module Model
    module Attributes
      class Base
        attr_reader :name, :owner
        delegate :type, :readonly, to: :reflection

        def initialize name, owner
          @name, @owner = name, owner
        end

        def reflection
          @owner.class._attributes[name]
        end

        def write_initial value
          @value_cache = value
        end

        def write value
          return if readonly?
          @value_cache = value
        end

        def reset
          remove_variable(:value, :value_before_type_cast)
        end

        def read
          @value_cache
        end

        def read_before_type_cast
          @value_cache
        end

        def value_present?
          !read.nil? && !(read.respond_to?(:empty?) && read.empty?)
        end

        def readonly?
          !!(readonly.is_a?(Proc) ? evaluate(&readonly) : readonly)
        end

        def inspect_attribute
          value = case type
          when Date, Time, DateTime
            %("#{read.to_s(:db)}")
          else
            inspection = read.inspect
            inspection.size > 100 ? inspection.truncate(50) : inspection
          end
          "#{name}: #{value}"
        end

      private

        def evaluate *args, &block
          if block.arity >= 0 && block.arity <= args.length
            owner.instance_exec(*args.first(block.arity), &block)
          else
            args = block.arity < 0 ? args : args.first(block.arity)
            block.call(*args, owner)
          end
        end

        def remove_variable(*names)
          names.flatten.each do |name|
            name = :"@#{name}"
            remove_instance_variable(name) if instance_variable_defined?(name)
          end
        end

        def variable_cache(name)
          name = :"@#{name}"
          if instance_variable_defined?(name)
            instance_variable_get(name)
          else
            instance_variable_set(name, yield)
          end
        end
      end
    end
  end
end
