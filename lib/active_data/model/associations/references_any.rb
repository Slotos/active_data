module ActiveData
  module Model
    module Associations
      class ReferencesAny < Base
        def scope(source = read_source)
          reflection.persistence_adapter.scope(owner, source)
        end

      private

        def source_present?
          owner.attribute_initially_provided?(reflection.reference_key)
        end

        def read_source
          attribute.read_before_type_cast
        end

        def write_source(value)
          attribute.write_value value
        end

        def attribute
          @attribute ||= owner.attribute(reflection.reference_key)
        end

        def build_object(attributes)
          reflection.persistence_adapter.build(attributes)
        end

        def persist_object(object, **options)
          reflection.persistence_adapter.persist(object, **options)
        end
      end
    end
  end
end
