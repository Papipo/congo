module MongoMapper
  module Plugins
    module Associations
      class ManyEmbeddedProxy < EmbeddedCollection
      
        def replace_with_dirty_mode(values)
          @_previous_values = @_values
          replace_without_dirty_mode(values)
        end
      
        def previous
          @_previous_values || []
        end
      
        alias_method_chain :replace, :dirty_mode
      end
    end
  end
end