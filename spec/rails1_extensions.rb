require File.expand_path("../spec_helper", __FILE__)

gem 'actionpack', '1.13.6'
require 'action_controller'
require 'action_view'
require 'ostruct'

configuration = OpenStruct.new
configuration.frameworks = [:action_controller, :action_view]
Palmade::AssetPackager::Helpers.use(:RailsHelper, configuration)
Palmade::AssetPackager::Helpers::RailsHelper.add_configuration_options(configuration)

describe "ActionController" do
  context "with AssetPackager extensions" do

    it "should have new configuration options" do
      ActionController::Base.should respond_to(:asset_version)
      ActionController::Base.should respond_to(:asset_skip_relative_url_root)
    end

    it "should have correct default configuration values" do
      ActionController::Base.asset_version.should == 0
      ActionController::Base.asset_skip_relative_url_root.should == false
    end

    it "should have new methods attached" do
      instance = ActionController::Base.new
      methods = [ :javascript_include,
                  :stylesheet_include,
                  :asset_include ]
      methods.each do |meth|
        ActionController::Base.should respond_to(meth)
        instance.should respond_to(meth)
      end
    end

  end
end

describe "ActionView" do
  context "with AssetPackager extensions" do

    it "should have new methods attached" do
      instance = ActionView::Base.new
      methods = [ :javascript_include,
                  :stylesheet_include,
                  :javascript_tags,
                  :stylesheet_tags ]
      methods.each do |meth|
        instance.should respond_to(meth)
      end
    end

    it "should render individual javascripts" do
      test_view = ActionView::Base.new(nil, {}, ActionController::Base.new)
      test_view.controller = ActionController::Base.new

      test_view.javascript_include('base')
      test_view.javascript_tags
    end

  end
end
