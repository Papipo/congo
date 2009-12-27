module Congo
  module Metadata
    class Validation
      include MongoMapper::EmbeddedDocument
  
      key :type, String
      key :key, String
  
      validates_presence_of :key, 
        :message => lambda { I18n.t('congo.errors.messages.empty') }
        
      validates_inclusion_of :type, 
        :within => methods.grep(/^validates_/),
        :message => lambda { I18n.t('congo.errors.messages.inclusion') }
  
      def apply(klass, scope)
        klass.send("validates_#{type}", key, :message => type_to_i18n)
      end
      
      protected
      
      def type_to_i18n
        keyword = (case self.type
          when 'presence_of' then 'empty'
          when 'acceptance_of' then 'accepted'
          when 'associated' then 'invalid'
          when 'format_of' then 'invalid'
          when 'length_of' then 'wrong_length'
          when 'numericality_of' then 'not_a_number'
          else self.type.gsub('_of', '')
        end)
        I18n.t("congo.errors.messages.#{keyword}")
      end
    end
  end
end