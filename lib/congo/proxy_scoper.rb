module Congo
  class ProxyScoper
    
    include MongoMapper::Document

    acts_as_congo_scoper
    
    key :ext_type, String
    key :ext_id, String
    
  end
end