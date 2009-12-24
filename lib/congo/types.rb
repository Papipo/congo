module Congo
  module Types
    class Email < String
      alias_method :email, :to_s
      include Validatable
      
      validates_format_of :email, :with => /\A[\w\._%-]+@[\w\.-]+\.[a-zA-Z]{2,4}\z/
    end
  end
end