# This file is copied to spec/ when you run 'rails generate rspec:install'
require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
# Prevent database truncation if the environment is production
if Rails.env.production?
  abort("The Rails environment is running in production mode!")
end
require "rspec/rails"
require "webmock/rspec"
require "view_component/test_helpers"

WebMock.disable_net_connect!(allow_localhost: true)

Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Rails.root.glob('spec/support/**/*.rb').sort.each { |f| require f }

if ENV["SMOKE_TEST"] == "true"
  ActiveRecord::Base.establish_connection adapter: :nulldb
else
  # Checks for pending migrations and applies them before tests are run.
  # If you are not using ActiveRecord, you can remove these lines.
  begin
    ActiveRecord::Migration.maintain_test_schema!
  rescue ActiveRecord::PendingMigrationError => e
    abort e.to_s.strip
  end
end

RSpec.configure do |config|
  config.include ViewComponent::TestHelpers, type: :component

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_paths = [Rails.root.join("spec/fixtures")]

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://rspec.info/features/6-0/rspec-rails
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.around(:each, type: :request) do |example|
    service = self.class.metadata[:service] || :claims

    host! service_host(service)
    example.run
    host! nil
  end

  config.around(:each, type: :system) do |example|
    service = self.class.metadata[:service] || :claims

    Capybara.app_host = "http://#{service_host(service)}"
    Capybara.asset_host = "http://#{service_host(service)}:#{ENV["PORT"]}"
    example.run
    Capybara.asset_host = nil
    Capybara.app_host = nil
  end

  config.around(:each, type: :system, smoke_test: true) do |example|
    service = self.class.metadata[:service] || :claims

    Capybara.app_host = "http://#{service_external_host(service)}"
    example.run
    Capybara.app_host = nil
  end

  config.include DfESignInUserHelper

  config.around(:each, type: :system, persona_sign_in: true) do |example|
    ClimateControl.modify SIGN_IN_METHOD: "persona" do
      Rails.application.reload_routes!
      example.run
    end

    ClimateControl.modify SIGN_IN_METHOD: "dfe-sign-in" do
      Rails.application.reload_routes!
    end
  end

  private

  def service_host(service)
    case service.to_s
    when "claims"
      ENV["CLAIMS_HOST"]
    when "placements"
      ENV["PLACEMENTS_HOST"]
    end
  end

  def service_external_host(service)
    case service.to_s
    when "claims"
      ENV["CLAIMS_EXTERNAL_HOST"]
    when "placements"
      ENV["PLACEMENTS_EXTERNAL_HOST"]
    end
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
