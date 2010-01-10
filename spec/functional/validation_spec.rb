require File.expand_path(File.dirname(__FILE__) + '/functional_spec_helper')

describe 'Validation' do
  
  before(:each) do
    Account.destroy_all
    Congo::ContentType.destroy_all
    
    @account = Account.create(:email => 'layne_stanley@acme.org')        
    
    create_content_type
  end
  
  it 'should be valid' do
    developer = build_developer
    developer.should be_valid
  end
  
  it 'should not valid if a key (String type) is not present' do
    developer = build_developer(:name => nil)
    developer.should_not be_valid
    developer.errors.on(:name).should_not be_empty    
  end
  
  it 'should not valid if a key (File type) is not present' do
    developer = build_developer(:picture => nil)
    developer.should_not be_valid
    developer.errors.on(:picture).should_not be_empty    
  end
  
  it 'should not valid if a key (Email type) is not present' do
    developer = build_developer(:email => nil)
    developer.should_not be_valid
    developer.errors.on(:email).should_not be_empty    
  end
  
  it 'should not valid if email has a wrong format' do
    developer = build_developer(:email => 'foo@foo')
    developer.should_not be_valid
    developer.errors.on(:email).should_not be_empty    
  end
  
  it 'should not valid if a key has a wrong format' do
    developer = build_developer(:blog_url => 'http:/foo.com')
    developer.should_not be_valid
    developer.errors.on(:blog_url).should_not be_empty    
  end
  
  def build_developer(options = {})
    @account.developers.create({
      :name => 'Layne Stanley', 
      :bio => 'foo bar',
      :picture => open_file('avatar.jpeg'),
      :blog_url => 'http://myblog.com',
      :email => 'layne.stanley@aic.com'
    }.merge(options))
  end
  
  def create_content_type(options = {})
    type = build_content_type
    type.save!
    type
  end
  
  def build_content_type(options = {})
    default_options = {
      :name => 'Developer',
      :embedded => false,
      :metadata_keys => [
        { :name => 'name', :type => 'String' },
        { :name => 'bio', :type => 'Text' },
        { :name => 'picture', :type => 'File' },
        { :name => 'blog_url', :type => 'String' },
        { :name => 'email', :type => 'Email' }
      ],
      :metadata_validations => [
        { :key => 'name', :type => 'presence_of' },
        { :key => 'email', :type => 'presence_of' },
        { :key => 'picture', :type => 'presence_of' },
        { :key => 'blog_url', :type => 'presence_of' },
        { :key => 'blog_url', :type => 'format_of', :argument => '^http:\/\/(.*)$' }
      ] }
    
    @account.content_types.build(default_options.merge(options))
  end
  
  def open_file(name)
    File.open(File.join(File.dirname(__FILE__), '..', 'assets', name))
  end
end