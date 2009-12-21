module Congo
  class ContentType
    include MongoMapper::Document
    include Migration
  
    ## keys
    key :embedded, Boolean, :default => false
    key :name, String, :required => true
    key :collection_name, String
    key :slug, String
    key :description, String
    key :scope_type, String
    key :scope_id, ObjectId
    
    ## associations
    belongs_to :scope, :polymorphic => true
    many :nested_keys, :class_name => 'Congo::Key', :dependent => :destroy
    many :nested_validations, :class_name => 'Congo::Validation', :dependent => :destroy
    many :nested_associations, :class_name => 'Congo::Association', :dependent => :destroy
    
    ## validations 
    validates_format_of :name, :with => /^[a-zA-Z][\w\s]*$/
    validates_presence_of :scope
    validates_true_for :nested_keys, :logic => :validate_nested_keys, :message => 'invalid keys'
    validates_true_for :collection_name, :logic => lambda { name.present? }, :message => 'is required'
    # TODO: name must be unique !
    
    ## callbacks
    before_validation :make_names_clean
  
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
      apply_migration(klass)
      klass
    end
  
    private
    
    def make_names_clean
      if self.collection_name
        self.collection_name = self.collection_name.strip.gsub(/\s+/, ' ')
        self.name = self.collection_name if self.name.blank?
      end
      self.name = self.name.strip.classify.gsub(/\s+/, '_').camelize if self.name
      self.slug = slugify_name(self.collection_name) if self.collection_name
    end
    
    def validate_nested_keys
      return false if nested_keys.empty?
      
      # keys should be valid and unique 
      found_errors, duplicates = false, {}
      nested_keys.each do |key|
        found_errors ||= !key.valid?
        if duplicates.key?(key.name)
          key.errors.add(:name, 'should be unique')
          found_errors = true
        else
          duplicates[key.name] = key
        end
      end
      !found_errors
    end
    
    def set_collection_name(klass)
      klass.set_collection_name "#{scope_type}_#{scope_id}_#{name.tableize}" # maybe just name.tableize is enough
    end
  
    def apply_scope(klass)
      klass.key scope_type.foreign_key, ObjectId
      klass.belongs_to scope_type.downcase
      klass.validates_presence_of scope_type.downcase
    end
          
    def apply_metadata(klass)
      %w[nested_keys nested_associations nested_validations].each do |association|
        self.send(association).each { |meta| meta.apply(klass, scope) }
      end
    end
        
    def slugify_name(name)
      # replace accented chars with ther ascii equivalents
      s = ActiveSupport::Inflector.transliterate(name).to_s
      # Remove leading or trailing space
      s.strip!
      # Remove leading or trailing slash
      s.gsub! /(^[\/]+)|([\/]+$)/, ''
      # Turn unwanted chars into the seperator
      s.gsub!(/[^a-zA-Z0-9\-_\+\/]+/i, '_')
      s.downcase
    end
  end
end