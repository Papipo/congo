module Congo
  module Types
  
    class Email < String
    
      def self.apply(klass, scope, name)
        klass.class_eval do
          validates_format_of name.to_sym, 
            :with => /\A[\w\._%-]+@[\w\.-]+\.[a-zA-Z]{2,4}\z/,
            :message => lambda { I18n.t('congo.errors.messages.invalid') }
        end
      end
      
    end
    
    class Text < String
    end
    
    class Date < Date
      
      def self.apply(klass, scope, name)
        klass.class_eval <<-EOV
          
          def localized_#{name}
            if self.#{name}
              self.#{name}.strftime(I18n.t('congo.date.formats.default'))
            else
              nil
            end
          end
          
          def localized_#{name}=(value)
            self.#{name} = value
          end
          
        EOV
      end
      
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