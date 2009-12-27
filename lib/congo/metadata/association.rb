module Congo
  module Metadata
    class Association
      include MongoMapper::EmbeddedDocument
  
      key :name, String
      key :type, String, :default => 'many'
  
      validates_presence_of :name, :type, 
        :message => lambda { I18n.t('congo.errors.messages.empty') }
        
      validates_inclusion_of :type, 
        :within => ['many', 'belongs_to'],
        :message => lambda { I18n.t('congo.errors.messages.inclusion') }
  
      def apply(klass, scope)
        klass.send(type, name, :class => scope.content_type_as_const(name.classify))
        if type.to_sym == :belongs_to
          klass.key name.foreign_key, String
        end
      end
    end
  end
end