module Congo
  class ContentType
    include MongoMapper::Document
  
    ## keys
    key :embedded, Boolean, :default => false
    key :name, String
    key :scope_type, String
    key :scope_id, ObjectId
    
    ## associations
    many :keys, :class_name => 'Congo::Key'
    many :validations, :class_name => 'Congo::Validation'
    many :associations, :class_name => 'Congo::Association'
    belongs_to :scope, :polymorphic => true
    
    ## validations 
    validates_presence_of :name, :scope
    validates_true_for :keys,
      :logic => lambda { !keys.empty? },
      :message => 'need keys'
  
    ## methods 
    
    def to_const
      klass = Class.new
      if self.embedded?
        klass.send(:include, MongoMapper::EmbeddedDocument)
      else
        klass.send(:include, MongoMapper::Document)
        set_collection_name(klass)
        apply_scope(klass)
      end
      apply_metadata(klass)
      klass
    end
  
    private
    
    def set_collection_name(klass)
      klass.set_collection_name "#{scope_type}_#{scope_id}_#{name.tableize}" # maybe just name.tableize is enough
    end
  
    def apply_scope(klass)
      klass.key scope_type.foreign_key, ObjectId
      klass.belongs_to scope_type.downcase
      klass.validates_presence_of scope_type.downcase
    end
  
    def apply_metadata(klass)
      %w[keys associations validations].each do |association|
        self.send(association).each { |meta| meta.apply(klass, scope) }
      end
    end
  end
end