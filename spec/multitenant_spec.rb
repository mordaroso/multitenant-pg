require 'spec_helper'

class Company < ActiveRecord::Base
  has_many :users
end

class User < ActiveRecord::Base
  belongs_to :company
end

class Tenant < ActiveRecord::Base
  set_table_name 'public.tenants'

  after_create :setup_schema

  def setup_schema
    unless Multitenant::SchemaUtils.schema_exists?(schema_name)
      Multitenant::SchemaUtils.create_schema(schema_name)
      Multitenant::SchemaUtils.load_schema_into_schema(schema_name)
    end
  end
end

module Rails
end

describe Multitenant do
  before(:all) do
    load File.join(File.dirname(__FILE__), '/fixtures/db/schema.rb')
  end

  before(:each) do
    #ActiveRecord::Base.connection.schema_search_path = 'public'
    Rails.stub(:root).and_return(File.join(File.dirname(__FILE__), 'fixtures'))

    @tenant = Tenant.create(:name => 'foo', :schema_name => 'foo')
    @tenant2 = Tenant.create(:name => 'bar', :schema_name => 'bar')
  end

  after do
    Multitenant.current_tenant = nil;
    Multitenant::SchemaUtils.with_all_schemas do
      DatabaseCleaner.clean_with :truncation
    end
  end

  describe 'Multitenant.current_tenant' do
    before { Multitenant.current_tenant = :foo }
    it { Multitenant.current_tenant == :foo }
  end

  describe 'Multitenant.with_tenant block' do
    before do
      @executed = false
      Multitenant.with_tenant @tenant do
        Multitenant.current_tenant.should == @tenant
        @executed = true
      end
    end
    it 'clears current_tenant after block runs' do
      Multitenant.current_tenant.should == nil
    end
    it 'yields the block' do
      @executed.should == true
    end
  end

  describe 'Multitenant.with_tenant block with a previous tenant' do
    before do
      @previous = :whatever
      Multitenant.current_tenant = @previous
      @executed = false
      Multitenant.with_tenant @tenant do
        Multitenant.current_tenant.should == @tenant
        Multitenant::SchemaUtils.current_search_path.should == @tenant.schema_name
        @executed = true
      end
    end

    it 'resets current_tenant after block runs' do
      Multitenant.current_tenant.should == @previous
      #ActiveRecord::Base.connection.schema_search_path.should == 'public'
    end

    it 'yields the block' do
      @executed.should == true
    end
  end

  describe 'Multitenant.with_tenant block that raises error' do
    before do
      @executed = false
      expect {
        Multitenant.with_tenant @tenant do
          @executed = true
          raise 'expected error'
        end
        }.to raise_error('expected error')
      end

      it 'clears current_tenant after block runs' do
        Multitenant.current_tenant.should == nil
      end

      it 'yields the block' do
        @executed.should == true
      end
    end

    describe 'User.all when current_tenant is set' do
      before do
        Multitenant.with_tenant @tenant do
          Multitenant::SchemaUtils.current_search_path.should == @tenant.schema_name
          @company = Company.create!(:name => 'foo')
          @user = @company.users.create! :name => 'bob'
        end

        Multitenant.with_tenant @tenant2 do
          Multitenant::SchemaUtils.current_search_path.should == @tenant2.schema_name
          company = Company.create!(:name => 'bar')
          user = company.users.create! :name => 'frank'
        end

        Multitenant.with_tenant @tenant do
          Multitenant::SchemaUtils.current_search_path.should == @tenant.schema_name
          @users = User.all
        end
      end

      it { @users.length.should == 1 }

      it { @users.should == [@user] }
    end
  end