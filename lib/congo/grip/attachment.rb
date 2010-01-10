module Congo
  module Grip
    class Attachment
   
      attr_reader :name, :path, :content_type, :size, :body
   
      def initialize(attrs = {})
        @name = attrs[:name]
        @path = attrs[:path]
        @content_type = attrs[:content_type]
        @size = attrs[:size]
        @body = attrs[:body]
      end
      
      def to_s
        self.body
      end
            
    end
  end
end
    