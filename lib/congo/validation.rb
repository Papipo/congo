module Congo
  module Validation
    
    def self.included(model)
      model.class_eval do
        include InstanceMethods
        
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

        validates_true_for :metadata_keys, 
          :logic => :validate_metadata_keys, 
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
      end
    end
    
    module InstanceMethods
            
      private

      def validate_metadata_keys
        return false if metadata_keys.empty?

        # keys should be valid and unique 
        found_errors, duplicates = false, {}
        metadata_keys.each do |key|
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

    end
  end
end