module Congo
  module Types
    class Email < String
      alias_method :email, :to_s
      include Validatable
      
      validates_format_of :email, 
        :with => /\A[\w\._%-]+@[\w\.-]+\.[a-zA-Z]{2,4}\z/,
        :message => lambda { I18n.t('congo.errors.messages.invalid') }
      
      def self.to_mongo(obj)
        obj.to_s
      end
      
      def self.from_mongo(value)
        value.kind_of?(String) ? new(value) : value
      end
    end
    
    class Text < String
    end
  end
end