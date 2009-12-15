require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'Associations' do
  
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