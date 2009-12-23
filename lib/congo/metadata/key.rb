module Congo
  module Metadata
    class Key
      include MongoMapper::EmbeddedDocument
  
      ## keys
      key :name, String
      key :label, String
      key :type, String, :default => 'String'
    
      ## validations
      validates_presence_of :name, :type, 
        :message => lambda { I18n.t('congo.errors.messages.empty') }
    
      ## callbacks
      before_validation do
        # FIXME: find something more robust to convert label to name
        self.name = self.label.underscore.gsub(' ', '_') if self.name.blank? && self.label
        self.name.downcase! if self.name
      end
        
      def apply(klass, scope)
        klass.key name.to_sym, scope.content_type_as_const(type)
      end

      def name=(value)
        @previous_name = self.name
        super
      end
    
      def name_changed?
        @previous_name != self.name
      end

    end
  end
end