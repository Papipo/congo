require File.expand_path(File.dirname(__FILE__) + '/functional_spec_helper')

describe 'List' do
  
  before(:all) do
    class Congo::ContentType
      include Congo::List
    end
  end
  
  before(:each) do
    Account.destroy_all
    Congo::ContentType.destroy_all
    
    @account = Account.create(:email => 'layne_stanley@acme.org')
  end
  
  it 'should increment item position once saved' do
    create_content_type  
    person = @account.developers.create :name => 'Layne Stanley', :bio => "That's great"
    person._position.should == 1
    person = @account.developers.create :name => 'Kurt Cobain', :bio => "Suicide #2"
    person._position.should == 2
  end
  
  it 'should decrement item position once deleted' do
    populate    
    @account.developers.first(:conditions => { :name => 'River Phoenix' }).destroy
    @account.developers.first(:conditions => { :name => 'Layne Stanley' })._position.should == 1
    @account.developers.first(:conditions => { :name => 'Kurt Cobain' })._position.should == 2
  end
  
  it 'should reorder all the items of a collection' do
    populate
    klass = @account.content_types.first.to_const
    klass.reorder_all(@account.developers.all(:order => 'name ASC').collect(&:_id))
    @account.developers.first(:conditions => { :name => 'River Phoenix' })._position.should == 3
    @account.developers.first(:conditions => { :name => 'Layne Stanley' })._position.should == 2
    @account.developers.first(:conditions => { :name => 'Kurt Cobain' })._position.should == 1
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
        { :name => 'bio', :type => 'Text' }
      ] } 
    
    @account.content_types.build(default_options.merge(options))
  end
  
  def populate
    create_content_type
    @account.developers.create :name => 'River Phoenix', :bio => "Life is good"
    @account.developers.create :name => 'Layne Stanley', :bio => "That's great"
    @account.developers.create :name => 'Kurt Cobain', :bio => "Suicide #2"
  end
  
end