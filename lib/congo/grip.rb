# Got from http://github.com/jnunemaker/grip/blob/master/lib/grip.rb
# Wait for jnunemaker to include it in the next release of Mongomapper
# Note:
#   we patched it to reflect the collection name within the path of the file.

require 'mongo/gridfs'
require 'mime/types'
require 'tempfile'

# if thumbnailable?
#   tmp = Tempfile.new("thumb_#{filename}")
#   MojoMagick::resize(uploaded_file.path, tmp.path, {:width => 50, :height => 40, :scale => '>'})
#   self.thumbnail = tmp.read      
# end

# open    : db, name, mode, options (:root, :metadata, :content_type)
# read    : db, name, length, offset
# unlink  : db, names
# list    : db, root collection
#
# GridStore.open(database, 'filename', 'w') { |f|
#   f.puts "Hello, world!"
# }

module Congo
  module Grip
    def self.included(base)
      base.extend Congo::Grip::ClassMethods
    end
  
    module ClassMethods
      def has_grid_attachment(name, options = {})
        configuration = { :path => ":class/:name/:id" }
        configuration.update(options) if options.is_a?(Hash)
        
        write_inheritable_attribute(:attachment_definitions, {}) if attachment_definitions.nil?
        attachment_definitions[name] = {}
      
        after_save :save_attachments
        before_destroy :destroy_attached_files
      
        key "#{name}_size".to_sym, Integer
        key "#{name}_path".to_sym, String
        key "#{name}_name".to_sym, String
        key "#{name}_content_type".to_sym, String
      
        define_method(name) do
          GridFS::GridStore.read(self.class.database, self["#{name}_path"])
        end
      
        define_method("#{name}=") do |file|
          self['_id']                  = Mongo::ObjectID.new if _id.blank?
          self["#{name}_size"]         = file.size rescue File.size(file)
          self["#{name}_name"]         = file.original_filename rescue File.basename(file.path)          
          self["#{name}_path"]         = configuration[:path].gsub(':class', self.class.to_s.underscore).gsub(':name', self.content_type.name.underscore).gsub(':id', _id.to_s)
          self["#{name}_content_type"] = file.content_type rescue MIME::Types.type_for(self["#{name}_name"]).to_s
          self.class.attachment_definitions[name] = file
        end
      end
    
      def attachment_definitions
        read_inheritable_attribute(:attachment_definitions)
      end
    end
  
    def save_attachments
      self.class.attachment_definitions.each do |attachment|
        name, file = attachment
      
        if (file.is_a?(File) || file.is_a?(Tempfile))
          GridFS::GridStore.open(self.class.database, self["#{name}_path"], 'w', :content_type => self["#{name}_content_type"]) do |f|
            f.write(file.read)
          end
        end
      end
    end
  
    def destroy_attached_files
      self.class.attachment_definitions.each do |name, attachment|
        GridFS::GridStore.unlink(self.class.database, self["#{name}_path"])
      end
    end
  end
end