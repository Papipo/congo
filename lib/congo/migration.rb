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
        klass.key :_version, Integer, :default => version
        
        klass.class_eval <<-EOV
          def initialize_with_version(attrs={}, from_database = false)
            initialize_without_version(attrs, from_database)
                        
            self.migrate!
          end
          
          alias_method_chain :initialize, :version
        
          def out_dated?
            self._version < content_type.version
          end
        
          def migrate!
            content_type.send(:migrate!, self)
          end
          
          protected
          
          def rename_key(old_key_name, new_key_name)
            @_mongo_doc ||= self.class.collection.find({ '_id' => self._id }).first
            @_mongo_doc[new_key_name] = @_mongo_doc[old_key_name]
            
            @_mongo_doc.delete(old_key_name)
          end
          
          def drop_key(key_name)
            @_mongo_doc ||= self.class.collection.find({ '_id' => self._id }).first
            @_mongo_doc.delete(key_name)
            self.send(:keys).delete(key_name) rescue nil
          end
        EOV
      end
      
      def migrate!(content)
        return false unless content.out_dated?
        
        doc = content.class.collection.find({ '_id' => content._id }).first
        content.instance_variable_set '@_mongo_doc', doc
        
        migrations.each do |migration|
          if doc['_version'] < migration.version
            # logger.debug "running migration #{migration.version} / #{migration.inspect}"
            
            migration.tasks.each do |task|
              # logger.debug "...running task #{task['action']}"
              
              case task['action'].to_sym
                when :rename
                  content.send(:rename_key, task['previous'], task['next'])
                when :drop
                  content.send(:drop_key, task['previous'])
                else
                  # unknown action
              end
            end
            doc['_version'] = migration.version
            # logger.debug "finishing migration (#{content.version}) / #{doc.inspect}"
            # puts "finishing migration (#{migration.version}) / #{doc.inspect}"
          end
        end
        content.class.collection.save(doc)
                
        content.attributes = doc
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
            
            # check for potential validations relative to the modified key
            metadata_validations.each do |validation|
              validation.key = current['name'] if validation.key == previous['name']
            end
          end
        end

        # dropped keys ?
        (previous_ids - current_ids).each do |key_id|
          previous = metadata_keys.previous.detect { |k| k['_id'] == key_id }
          migration.tasks << { :action => 'drop', :previous => previous['name'] }
          
          # check for potential validations relative to the dropped key
          metadata_validations.delete_if { |v| v.key == previous['name'] }
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