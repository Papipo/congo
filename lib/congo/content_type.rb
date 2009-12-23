module Congo
  class ContentType
    include MongoMapper::Document
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
    many :nested_keys, :class_name => 'Congo::Key', :dependent => :destroy
    many :nested_validations, :class_name => 'Congo::Validation', :dependent => :destroy
    many :nested_associations, :class_name => 'Congo::Association', :dependent => :destroy
    
    ## validations 
    validates_format_of :name, 
      :with => /^[a-zA-Z][\w\s]*$/, 
      :message => lambda { I18n.t('congo.errors.messages.invalid') }
      
    validates_presence_of :name, :scope, 
      :message => lambda { I18n.t('congo.errors.messages.empty') }
      
    validates_true_for :name,
      :logic => :check_uniqueness_of_name,
      :message => lambda { I18n.t('congo.errors.messages.taken') }
      
    validates_true_for :name,
      :key => :allowed_name,
      :logic => :check_allowed_name,
      :message => lambda { I18n.t('congo.errors.messages.exclusion') }
      
    validates_true_for :nested_keys, 
      :logic => :validate_nested_keys, 
      :message => lambda { I18n.t('congo.errors.messages.invalid') }
        
    validates_true_for :collection_name, 
      :logic => lambda { name.present? }, 
      :message => lambda { I18n.t('congo.errors.messages.empty') }
    
    validates_true_for :collection_name,
      :key => :unique_collection_name,
      :logic => :check_uniqueness_of_collection_name,
      :message => lambda { I18n.t('congo.errors.messages.taken') }
      
    validates_true_for :collection_name,
      :key => :allowed_allowed_name,
      :logic => :check_allowed_name,
      :message => lambda { I18n.t('congo.errors.messages.exclusion') }

    ## callbacks
    before_validation :make_names_clean
  
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
          key.errors.add(:name, I18n.t('activerecord.errors.messages.taken'))
          found_errors = true
        else
          duplicates[key.name] = key
        end
      end
      !found_errors
    end
    
    def check_uniqueness_of(attribute, value)
      type = self.class.first(:conditions => { :scope_type => scope_type, :scope_id => scope_id, attribute => value })
      type.nil? || (type && type == self)
    end
    
    def check_uniqueness_of_name
      check_uniqueness_of(:name, name)
    end
    
    def check_uniqueness_of_collection_name
      collection_name.blank? || (collection_name.present? && check_uniqueness_of(:slug, slug))
    end
    
    def check_allowed_name
      return true if name.blank? || scope.nil?
      methods = scope.is_a?(Congo::ProxyScoper) ? scope.ext_type.constantize.instance_methods : scope.methods
      !(methods.include?(name.tableize.to_s) || (slug.present? && methods.include?(slug)))
    end
    
    def set_collection_name(klass)
      klass.set_collection_name "#{scope_type}_#{scope_id}_#{name.tableize}" # maybe just name.tableize is enough
    end
  
    def apply_scope(klass)
      foreign_key = scope_type.underscore.gsub('/', '_').foreign_key
      association_name = scope_type.demodulize.underscore
      
      klass.key foreign_key, ObjectId
      klass.belongs_to association_name, :class_name => scope_type, :foreign_key => foreign_key
      klass.validates_presence_of association_name
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