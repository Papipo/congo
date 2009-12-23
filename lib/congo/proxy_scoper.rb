module Congo
  class ProxyScoper
    
    include MongoMapper::Document

    acts_as_congo_scoper
    
    ## keys
    key :ext_type, String
    key :ext_id, Integer
    
    ## validations
    validates_true_for :ext,
      :logic => lambda { Congo::ProxyScoper.find_by_ext_id_and_ext_type(ext_id, ext_type).nil? },
      :message => lambda { I18n.t('congo.errors.messages.taken') }
    
  end
end