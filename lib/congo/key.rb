module Congo
  class Key
    include MongoMapper::EmbeddedDocument
  
    ## keys
    key :name, String, :required => true
    key :label, String
    key :type, String, :default => 'String', :required => true
    
    ## callbacks
    before_validation do
      # FIXME: find something more robust to convert label to name
      self.name = self.label.underscore.gsub(' ', '_') if self.name.blank? && self.label
      self.name.downcase! if self.name
    end
        
    def apply(klass, scope)
      klass.key name.to_sym, scope.content_type_as_const(type)
    end

  end
end