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
    
    class Date < ::Date
      def self.to_mongo(value)
        date = self.parse_with_i18n(value.to_s)
        Time.utc(date[:year], date[:mon], date[:mday])
      end

      def self.from_mongo(value)
        value.to_date if value.present?
      end
      
      # Patch from http://gist.github.com/179712
      def self.parse_with_i18n(str)
        format ||= :default
        date = ::Date._strptime(str, I18n.t('congo.date.formats.default')) || self._parse(str)
        date[:year] += self.increment_year(date[:year].to_i) if date[:year]
        date
      end

      def self.increment_year(year)
        if year < 100
          year < 30 ? 2000 : 1900
        else
          0
        end
      end
    end
  end
end