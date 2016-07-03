module ActiveData
  module Model
    module Primary
      extend ActiveSupport::Concern
      DEFAULT_PRIMARY_ATTRIBUTE_OPTIONS = -> { {
        type: ActiveData::UUID,
        default: -> { ActiveData::UUID.random_create }
      } }

      included do
        class_attribute :_primary_name, instance_writer: false
        delegate :has_primary_attribute?, to: 'self.class'

        prepend PrependMethods
        alias_method :eql?, :==
      end

      module ClassMethods
        def primary *args
          options = args.extract_options!
          self._primary_name = (args.first.presence || ActiveData.primary_attribute).to_s
          unless has_attribute?(_primary_name)
            options.merge!(type: args.second) if args.second
            attribute _primary_name, options.presence || DEFAULT_PRIMARY_ATTRIBUTE_OPTIONS.call
          end
          alias_attribute :primary_attribute, _primary_name
        end
        alias_method :primary_attribute, :primary

        def has_primary_attribute?
          has_attribute? _primary_name
        end

        def primary_name
          _primary_name
        end
      end

      module PrependMethods
        def == other
          other.instance_of?(self.class) &&
            has_primary_attribute? ?
              primary_attribute ?
                primary_attribute == other.primary_attribute :
                object_id == other.object_id :
              super(other)
        end
      end
    end
  end
end
