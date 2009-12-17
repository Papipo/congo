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
  
  it 'should not break method_missing stuff from the scoper' do
    website = Website.new(42, 'My simple website')
    website.foo.should == 'Hello foo !'
    lambda {
      website.bar
    }.should raise_error
  end
  
  ## Create content types ##
  it 'should create a content type and use it straight from an AR object' do 
    website = Website.new(42, 'My simple website')
    
    lambda {
      create_blog_post_type(website)
    }.should change(Congo::ContentType, :count).by(1)
    
    website.blog_posts.count.should == 0
  end
  
  it 'should create a content type and use it straight from the MM document' do
    account = Account.create(:email => 'layne_stanley@acme.org')
    
    lambda {
      create_project_type(account)
    }.should change(Congo::ContentType, :count).by(1)
    
    account.projects.count.should == 0
  end
  
  ## Content type validation (own file ?) ##
  it 'should not create a content type if it does not have a name' do
    account = Account.create(:email => 'layne_stanley@acme.org')    
    lambda {
      content_type = account.content_types.create(:keys => [ { :name => 'Title' } ])
      content_type.errors.on(:name).should_not be_nil
    }.should_not change(Congo::ContentType, :count).by(1)
  end
  
  it 'should not create a content type if it does not have keys' do
    account = Account.create(:email => 'layne_stanley@acme.org')    
    lambda {
      content_type = account.content_types.create(:name => 'Project')
      content_type.errors.on(:keys).should_not be_nil
    }.should_not change(Congo::ContentType, :count).by(1)
  end
    
  ## Associations: add items, ...etc ##
  it 'should add items into an association' do
    account = Account.create(:email => 'layne_stanley@acme.org')
    create_project_type(account)
    
    account.projects.create!(:name => 'Congo', :description => 'bla bla')
    account.projects.count.should == 1
  end
  
  def create_blog_post_type(website)
    website.content_types.create!(:name => 'BlogPost', :embedded => false, :timestamps => true,
      :keys => [
        { :name => 'title' },
        { :name => 'body' },
        { :name => 'tags', :type => 'Array' }
      ])
  end
  
  def create_project_type(account)
    account.content_types.create!(:name => 'Project', :embedded => false,
      :keys => [
        { :name => 'name' },
        { :name => 'description' }
      ])
  end
  
end
