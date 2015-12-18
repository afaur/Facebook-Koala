require 'rufus-scheduler'
require 'koala'
require 'json'
require 'date'
require 'awesome_print'
require 'metainspector'

Koala.config.api_version = "v2.0"

def test_api

  # Get app id
  #app_id = ENV['API_KEY']

  # Get app secret
  #app_secret = ENV['SEC_KEY']

  # OAuth instance
  #@oauth = Koala::Facebook::OAuth.new(app_id, app_secret, '')

  # Read in the test api token
  oauth_access_token = ENV['TESTING_API_TOK']

  # Read in the test page id
  page_id = ENV['PAGE_ID']

  # Get a graph instance
  @graph = Koala::Facebook::API.new(oauth_access_token)

  # Get a page token using
  page_token = @graph.get_page_access_token(page_id)

  # Page to inspect
  b = MetaInspector.new(ENV['INSPECTION_PAGE'])

  # Set the title to the best determined title
  title = b.best_title

  # Set the desc to the description
  desc  = b.description

  # Check the first 18 characters of each link href to locate a special link
  special_link = b.links.all.reject { |h| h[0..18] != ENV['INSPECTION_LINK_START'] }

  # Get a page graph instance
  @page_graph = Koala::Facebook::API.new(page_token)

  # Get the feed for this fb page
  feed = @page_graph.get_connection('me', 'feed')

=begin
  @page_graph.put_connections(
    ENV['STT_PAGE_ID'], 'feed',
    :message => b.description,
    :picture => ENV['POST_PICTURE'],
    :link    => ENV['POST_LINK']
  )
=end

  # Debugging
  puts "#{ENV['PAGE_ID']} #{b.description}"

end

# Setup a scheduler to timer based operations
SCHEDULER = Rufus::Scheduler.new

# Run a command every 30 minutes
SCHEDULER.every '30m' do
  puts 'Running..'
  test_api
  puts 'Finished Running.'
end

# If control + c is hit halt program
Signal.trap("INT") do
  puts "\nHalting program."
  exit
end

# Run the test_api function right away
test_api

# Keep the process alive so that rufus will continue to run on a timer
sleep

