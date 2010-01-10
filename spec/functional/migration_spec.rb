require File.expand_path(File.dirname(__FILE__) + '/functional_spec_helper')

describe 'ContentType' do
  
  before(:each) do
    Account.destroy_all
    Congo::ProxyScoper.destroy_all
    Congo::ContentType.destroy_all
    
    @account = Account.create(:email => 'layne_stanley@acme.org')
    @content_type = @account.content_types.create!({
      :name => 'Project', 
      :embedded => false,
      :metadata_keys => [
        { :name => 'name' },
        { :name => 'description' },
        { :name => 'date' }
      ]
    })    
    @content_type = @content_type.reload
  end
  
  it 'should create new record' do
    project = @account.projects.create(:name => 'Project #1', :description => 'bla bla')
    @account.projects.count.should == 1
    project.out_dated?.should be_false
    project.migrate!.should be_false
  end
  
  it 'should not create incremented migration since there are no documents in the collection' do
    (type = build_content_type).save
    type.version.should == 0
    type.migrations.should be_empty
    
    type = Congo::ContentType.first
    new_metadata_keys = [type.metadata_keys.pop, Congo::Metadata::Key.new({ :name => 'date' }), type.metadata_keys.pop]
    new_metadata_keys.last.name = 'title'
    type.metadata_keys = new_metadata_keys
    type.save
    type.version.should == 0
    type.migrations.should be_empty
  end
  
  it 'should create incremented migration once it has been updated AND there is at least one document in the collection' do
    (type = build_content_type).save
    @account.tasks.create(:name => 'foo', :description => 'bla bla')
    type.version.should == 0
    type.migrations.should be_empty
    
    type = @account.content_types.all[1]
    new_metadata_keys = [type.metadata_keys.pop, Congo::Metadata::Key.new({ :name => 'date' })]
    new_metadata_keys.first.name = 'a_description'
    type.metadata_keys = new_metadata_keys
    type.save
    type.version.should == 1
    type.migrations.size.should == 1
    type.migrations.first.tasks.size.should == 2
    
    type.migrations.first.tasks[0][:action].should == 'rename'
    type.migrations.first.tasks[0][:previous].should == 'description'
    type.migrations.first.tasks[0][:next].should == 'a_description'
    type.migrations.first.tasks[1][:action].should == 'drop'
    type.migrations.first.tasks[1][:previous].should == 'name'
    
    type = @account.content_types.all[1]
    new_metadata_keys = [type.metadata_keys.pop]
    type.metadata_keys = new_metadata_keys
    type.save
    type.version.should == 2
    type.migrations.size.should == 2
    type.migrations.last.tasks.size.should == 1
    type.migrations.last.tasks[0][:action].should == 'drop'
  end
  
  it 'should migrate smoothly (renaming and dropping columns)' do
    project = @account.projects.create(:name => 'Project #1', :description => 'bla bla', :date => '10/09/2009')
  
    # renaming and droppping keys
    new_keys = [@content_type.metadata_keys.first, @content_type.metadata_keys[1]]
    new_keys.first.name = 'title'
    @content_type.metadata_keys = new_keys
    @content_type.save
  
    @account = Account.first # we need a hard refresh :-)    
    project = @account.projects.first
    project.title.should == 'Project #1'
    project._version.should == 1
    lambda { project.name }.should_not raise_error
    lambda { project.date }.should raise_error
    
    another_project = @account.projects.create!(:title => 'Project #2', :description => 'bla bla')
    lambda { another_project.name }.should raise_error
    lambda { another_project.date }.should raise_error
  end
  
  it 'should run 2 pending migrations' do
    project = @account.projects.create(:name => 'Project #1', :description => 'bla bla', :date => '10/09/2009')
    
    new_keys = [@content_type.metadata_keys.first, @content_type.metadata_keys[1]]
    new_keys.first.name = 'title'
    @content_type.metadata_keys = new_keys
    @content_type.save
    
    @content_type = @content_type.reload # necessary
    
    new_keys = [@content_type.metadata_keys.first]
    new_keys.first.name = 'name'
    @content_type.metadata_keys = new_keys
    @content_type.save
    
    @account = Account.first # we need a hard refresh :-)    
    project = @account.projects.first # two pending migrations
        
    project._version.should == 2
    project.name.should == 'Project #1'
    lambda { project.title }.should raise_error
    lambda { project.description }.should raise_error
    lambda { project.date }.should raise_error
  end
  
  it 'should update validation if key name changes' do
    @account.projects.create(:name => 'Project #1', :description => 'bla bla', :date => '10/09/2009')
    
    @content_type.metadata_validations = [{ :key => 'name', :type => 'presence_of' }]
    @content_type.save
    
    new_keys = [@content_type.metadata_keys.first, @content_type.metadata_keys.last]
    new_keys.first.name = 'title'
    @content_type.metadata_keys = new_keys
    @content_type.save
    
    @content_type = Congo::ContentType.first # hard refresh
    @content_type.metadata_validations.first.key.should == 'title'
  end
  
  it 'should update validation if key is droppped' do
    @account.projects.create(:name => 'Project #1', :description => 'bla bla', :date => '10/09/2009')
    
    @content_type.metadata_validations = [{ :key => 'description', :type => 'presence_of' }]
    @content_type.save
    
    new_keys = [@content_type.metadata_keys.first, @content_type.metadata_keys.last]
    @content_type.metadata_keys = new_keys
    @content_type.save
    
    @content_type = Congo::ContentType.first # hard refresh
    @content_type.metadata_validations.should be_empty
  end
  
  def build_content_type(options = {})
    default_options = {
      :name => 'Task', 
      :embedded => false,
      :metadata_keys => [
        { :name => 'name' },
        { :name => 'description' }
      ] } 
    
    @account.content_types.build(default_options.merge(options))
  end
  
end