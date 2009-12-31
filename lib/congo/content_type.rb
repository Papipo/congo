module Congo
  class ContentType
    include MongoMapper::Document
    include Validation
    include Migration
  
    ## keys
    key :embedded, Boolean, :default => false
    key :name, String
    key :collection_name, String
    key :slug, String
    key :description, String
    key :scope_type, String
    key :scope_id, ObjectId
    
    ## associations
    belongs_to :scope, :polymorphic => true
    many :metadata_keys, :class_name => 'Congo::Metadata::Key', :dependent => :destroy
    many :metadata_validations, :class_name => 'Congo::Metadata::Validation', :dependent => :destroy
    many :metadata_associations, :class_name => 'Congo::Metadata::Association', :dependent => :destroy
    
    ## callbacks
    before_validation :make_names_clean
    before_destroy :destroy_contents
  
    ## methods 
    
    def to_const
      klass = Class.new
      if self.embedded?
        klass.send(:include, MongoMapper::EmbeddedDocument)
      else
        klass.send(:include, MongoMapper::Document)
        klass.timestamps!
        set_collection_name(klass)
        apply_scope(klass)
      end
      
      klass.class_eval <<-EOV
        def content_type
          @content_type ||= self.class.content_type
        end
        
        def self.content_type
          Congo::ContentType.find('#{self._id}')
        end
      EOV
      
      apply_metadata(klass)
      apply_migration(klass)
      klass
    end
  
    private
            
    def set_collection_name(klass)
      klass.set_collection_name self.send(:mongodb_collection_name)
    end
    
    def mongodb_collection_name
      "#{scope_type}_#{scope_id}_#{name.tableize}" # maybe just name.tableize is enough
    end
  
    def apply_scope(klass)
      foreign_key = scope_type.underscore.gsub('/', '_').foreign_key
      association_name = scope_type.demodulize.underscore
      
      klass.key foreign_key, ObjectId
      klass.belongs_to association_name, :class_name => scope_type, :foreign_key => foreign_key
      klass.validates_presence_of association_name
    end
          
    def apply_metadata(klass)
      %w[metadata_keys metadata_associations metadata_validations].each do |association|
        self.send(association).each { |meta| meta.apply(klass, scope) }
      end
    end
    
    def destroy_contents
      MongoMapper.database.collection(self.send(:mongodb_collection_name)).drop
    end
    
    def make_names_clean
      if self.collection_name
        self.collection_name = self.collection_name.strip.gsub(/\s+/, ' ')
        self.name = self.collection_name if self.name.blank?
      end
      
      self.name = self.name.strip.classify.gsub(/\s+/, '_').camelize if self.name
      self.slug = slugify_name(self.collection_name) if self.collection_name
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