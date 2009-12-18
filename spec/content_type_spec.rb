require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'ContentType' do
  
  it 'should be valid' do
    build_content_type.should be_valid
  end
  
  it 'should not be valid without a name' do
    type = build_content_type(:name => nil)
    type.should_not be_valid
    type.errors.on(:name).should_not be_nil
  end
  
  it 'should not valid without keys' do
    type = build_content_type(:keys => [])
    type.should_not be_valid
    type.errors.on(:keys).should_not be_nil
  end
  
  it 'should not be valid without a scope' do
    type = build_content_type(:scope => nil)
    type.should_not be_valid
    type.errors.on(:scope).should_not be_nil
  end
  
  it 'should not be valid with 2 identical keys (same name)' do
    type = build_content_type(:keys => [ { :name => 'name' }, { :name => 'name' }, { :name => 'description' } ])
    type.should_not be_valid
    type.errors.on(:keys).should_not be_nil
    type.keys.first.should be_valid
    type.keys.last.should be_valid
    type.keys[1].errors.on(:name).should_not be_nil
  end
  
  it 'should be retrieved once saved' do
    type = build_content_type
    type.save.should be_true
    Congo::ContentType.first.keys.should_not be_empty
  end
  
  def build_content_type(options = {})
    default_options = {
      :name => 'Project', 
      :embedded => false,
      :keys => [
        { :name => 'name' },
        { :name => 'description' }
      ],
      :scope => Congo::ProxyScoper.new } 
      
    Congo::ContentType.new(default_options.merge(options))
  end
  
end
