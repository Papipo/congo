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
      before_validation { |c| c.send(:normalize_name) }
        
      def apply(klass, scope)
        if type == 'File'
          klass.send(:include, Congo::Grip::HasAttachment) unless klass.include?(Congo::Grip::HasAttachment) # do not add the module twice
          klass.has_grid_attachment name.to_sym, :path => ":name/:id"
        else
          ctype = scope.content_type_as_const(type)
          klass.key name.to_sym, ctype
          klass.include_errors_from name.to_sym if ctype.instance_methods.include?('valid?')
          ctype.apply(klass, scope, name) if ctype.respond_to?('apply')
        end
      end
      
      private
      
      def normalize_name
        # TODO: find something more robust to convert label to name
        self.name = self.label.underscore.gsub(' ', '_') if self.name.blank? && self.label
        self.name.downcase! if self.name
      end

    end
  end
end