class Website
  
  acts_as_congo_scoper
  
  attr_accessor :id, :title
  
  def initialize(id, title)
    self.id, self.title = id, title
  end
  
end

class Account 
  
  include MongoMapper::Document
  
  acts_as_congo_scoper
  
  key :email, String
  
end