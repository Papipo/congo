module Congo
  module Migration
    
    def self.included(model)
      model.class_eval do
        include InstanceMethods
        
        key :version, Integer, :default => 0
        
        many :migrations, :class_name => 'Congo::Migration::Migration', :dependent => :destroy
        
        before_save :increment_version_and_build_migration
      end
    end
    
    module InstanceMethods
            
      private
      
      def apply_migration(klass)
        klass.key :version, Integer, :default => version
        
        klass.class_eval <<-EOV
          def initialize_with_version(attrs={})
            initialize_without_version(attrs)
            self.version = content_type.version unless attrs['version']
            self.migrate!
          end
          
          alias_method_chain :initialize, :version
        
          def out_dated?
            self.version < content_type.version
          end
        
          def migrate!
            content_type.send(:migrate!, self)
          end

          def content_type
            @content_type ||= Congo::ContentType.find('#{self._id}')
          end
        EOV
      end
      
      def migrate!(content)
        return false unless content.out_dated?
        
        doc = content.class.collection.find({ '_id' => content._id }).first
        
        migrations.each do |migration|
          if doc['version'] < migration.version            
            # logger.debug "running migration #{migration.version} / #{migration.inspect}"
            
            migration.tasks.each do |task|
              # logger.debug "...running task #{task['action']}"
              case task['action'].to_sym
                when :rename
                  doc[task['next']] = doc[task['previous']]
                  doc.delete(task['previous'])
                when :drop
                  doc.delete(task['previous'])
                  content.send(:_keys).delete(task['previous']) rescue nil
                else
                  # unknown action
              end
            end
            doc['version'] = migration.version
            # logger.debug "finishing migration (#{content.version}) / #{doc.inspect}"
          end
        end
        content.class.collection.save(doc)
        content = content.reload
      end
      
      def increment_version_and_build_migration
        return if self.to_const.count == 0

        current_ids = metadata_keys.collect { |k| k['_id'] }.compact
        previous_ids = metadata_keys.previous.collect { |k| k['_id'] }.compact

        migration = Migration.new(:version => self.version + 1, :tasks => [])

        # renamed keys ?
        (previous_ids & current_ids).each do |key_id|
          current, previous = metadata_keys.find(key_id), metadata_keys.previous.detect { |k| k['_id'] == key_id }
          if previous['name'] != current['name']
            migration.tasks << { :action => 'rename', :previous => previous['name'], :next => current['name'] }
            
            # check for validation
            metadata_validations.each do |validation|
              validation.key = current['name'] if validation.key == previous['name']
            end
          end
        end

        # dropped keys ?
        (previous_ids - current_ids).each do |key_id|
          previous = metadata_keys.previous.detect { |k| k['_id'] == key_id }
          migration.tasks << { :action => 'drop', :previous => previous['name'] }
        end
        
        unless migration.empty?
          self.version += 1
          self.migrations << migration
          # logger.debug "incrementing version #{self.version}"
        end
      end
      
    end
    
    class Migration
      include MongoMapper::EmbeddedDocument
        
      ## keys
      key :version, Integer, :required => true
      key :tasks, Array, :required => true
      
      ## methods 
      
      def empty?
        self.tasks.empty?
      end
    end
    
  end
end