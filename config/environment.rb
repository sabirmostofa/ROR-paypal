# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
RubySdk::Application.initialize!
ActiveRecord::Migration.verbose = false
ActiveRecord::Migrator.migrate(File.join(Rails.root, 'db', 'migrate'))
