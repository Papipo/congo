require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'ContentType' do
  
  before(:each) do
    Account.destroy_all
    Congo::ProxyScoper.destroy_all
    Congo::ContentType.destroy_all
    
    @account = Account.create(:email => 'layne_stanley@acme.org')
  end
  
  it 'should be valid' do
    build_content_type.should be_valid
  end
  
  it 'should not be valid without a name' do
    type = build_content_type(:name => nil)
    type.should_not be_valid
    type.errors.on(:name).should_not be_nil
    type.errors.on(:collection_name).should_not be_nil
  end
  
  [' BlogPost      ', '  My   projects', 'active posts    '].each do |name|
    it "should be valid with name included leading or trailing spaces (#{name})" do
      type = build_content_type(:name => name)
      type.should be_valid
    end
  end
  
  ['42BlogPosts', '  !cool', 'Great!', 'Super-PRoject43'].each do |name|
    it "should not be valid with an invalid name (#{name})" do
      type = build_content_type(:name => name)
      type.should_not be_valid
      type.errors.on(:name).should_not be_nil
    end
  end
  
  it 'should be valid without a name if collection name is provided' do
    type = build_content_type(:name => nil, :collection_name => 'My projects')
    type.should be_valid
    type.name.should == "MyProject"
    type.slug.should == "my_projects"
  end
  
  it 'should not valid without keys' do
    type = build_content_type(:nested_keys => [])
    type.should_not be_valid
    type.errors.on(:nested_keys).should_not be_nil
  end
  
  it 'should not be valid without a scope' do
    type = build_content_type
    type.scope = nil
    type.should_not be_valid
    type.errors.on(:scope).should_not be_nil
  end
  
  it 'should not be valid with 2 identical keys (same name)' do
    type = build_content_type(:nested_keys => [ { :name => 'name' }, { :name => 'name' }, { :name => 'description' } ])
    type.should_not be_valid
    type.errors.on(:nested_keys).should_not be_nil
    type.nested_keys.first.should be_valid
    type.nested_keys.last.should be_valid
    type.nested_keys[1].errors.on(:name).should_not be_nil
  end
  
  it 'should be retrieved once saved' do
    type = build_content_type
    type.nested_keys.should_not be_empty
    type.save!.should be_true
    type.save!
    
    type = type.reload
    type.nested_keys.size.should == 2
    Congo::ContentType.first.nested_keys.size.should == 2    
  end
      
  def build_content_type(options = {})
    default_options = {
      :name => 'Project', 
      :embedded => false,
      :nested_keys => [
        { :name => 'name' },
        { :name => 'description' }
      ] } 
    
    @account.content_types.build(default_options.merge(options))
  end
  
end