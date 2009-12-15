require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'Scoper' do
  
  it 'should be used inside any AR models' do
    website = Website.new(42, 'My simple website')
    website.id.should == 42
    lambda {
      website.content_types.should be_empty
      website.content_types.should be_empty
    }.should change(Congo::ProxyScoper, :count).by(1)
    
    proxy = Congo::ProxyScoper.first
    proxy.ext_id.should == '42'
    proxy.ext_type.should == 'Website'
    
    another = Website.new(43, 'Another simple website')
    lambda {
      another.content_types.should be_empty
    }.should change(Congo::ProxyScoper, :count).by(1)
  end
  
  it 'should be used inside a MongoMapper document' do
    account = Account.create(:email => 'layne_stanley@acme.org')
    account.content_types.should be_empty
  end
  
end
