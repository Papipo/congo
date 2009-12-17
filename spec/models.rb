class Website
  
  acts_as_congo_scoper
  
  attr_accessor :id, :title
  
  def initialize(id, title)
    self.id, self.title = id, title
  end
  
  def method_missing(method, *args)
    if method.to_s == 'foo'
      "Hello foo !" 
    else
      super
    end
  end
end

class Account 
  
  include MongoMapper::Document
  
  acts_as_congo_scoper
  
  key :email, String
  
end