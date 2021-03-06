require "spec_helper"

describe BigbluebuttonRails::Generators::InstallGenerator do
  include GeneratorSpec::TestCase
  destination File.expand_path("../../../tmp", __FILE__)
  tests BigbluebuttonRails::Generators::InstallGenerator

  context "standard install" do
    before(:all) do
      prepare_destination
      run_generator
    end

    it "all files are properly created" do
      assert_migration "db/migrate/create_bigbluebutton_rails.rb"
      assert_file "config/locales/bigbluebutton_rails.en.yml"
      assert_file "public/stylesheets/bigbluebutton_rails.css"
      assert_file "public/javascripts/jquery.min.js"
      assert_file "public/images/loading.gif"
    end

    it "all files are properly destroyed" do
      run_generator %w(), :behavior => :revoke
      assert_no_migration "db/migrate/create_bigbluebutton_rails.rb"
      assert_no_file "config/locales/bigbluebutton_rails.en.yml"
      assert_no_file "public/stylesheets/bigbluebutton_rails.css"
      assert_no_file "public/javascripts/jquery.min.js"
      assert_no_file "public/images/loading.gif"
    end
  end

  context "setting migration-only" do
    before(:all) do
      prepare_destination
      run_generator %w{ --migration-only }
    end

    it "only the migration is created" do
      assert_migration "db/migrate/create_bigbluebutton_rails.rb"
      assert_no_file "config/locales/bigbluebutton_rails.en.yml"
      assert_no_file "public/stylesheets/bigbluebutton_rails.css"
      assert_no_file "public/javascripts/jquery.min.js"
      assert_no_file "public/images/loading.gif"
    end
  end

  context "migrating to version" do
    before { prepare_destination }

    ["0.0.4", "0.0.5"].each do |version|
      context "#{version}" do
        before { run_generator [ version ] }

        it "all files are properly created" do
          assert_migration "db/migrate/bigbluebutton_rails_to_#{version.gsub(".", "_")}.rb"
        end

        it "all files are properly destroyed" do
          run_generator [ version ], :behavior => :revoke
          assert_no_migration "db/migrate/bigbluebutton_rails_to_#{version.gsub(".", "_")}.rb"
        end
      end
    end
  end

end
