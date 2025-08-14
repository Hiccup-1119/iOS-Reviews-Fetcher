#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))

require 'optparse'
require 'json'
require 'ios_reviews_fetcher/fetcher'

options = {
  country: 'us',
  limit: 200,
  per_page: 50,
  out: nil,
  sleep: 1.2,
  lang: 'en-US'
}

parser = OptionParser.new do |opts|
  opts.banner = 'Usage: fetch.rb --app APP_ID --country CC [--limit N] [--per_page 50] [--sleep 1.2] [--out file.json]'
  opts.on('--app APP_ID', Integer, 'Numeric App ID (required)') { |v| options[:app_id] = v }
  opts.on('--country CC', String, '2-letter country code (default: us)') { |v| options[:country] = v }
  opts.on('--limit N', Integer, 'Max reviews to fetch (default: 200)') { |v| options[:limit] = v }
  opts.on('--per_page N', Integer, 'Page size (<=50, default: 50)') { |v| options[:per_page] = v }
  opts.on('--sleep S', Float, 'Base sleep between pages (default: 1.2)') { |v| options[:sleep] = v }
  opts.on('--lang L', String, 'Locale, e.g., en-US (default: en-US)') { |v| options[:lang] = v }
  opts.on('--out FILE', String, 'Write JSON to file (optional)') { |v| options[:out] = v }
end

begin
  parser.parse!
  raise OptionParser::MissingArgument, 'APP_ID is required' unless options[:app_id]
rescue OptionParser::ParseError => e
  warn e.message
  puts parser
  exit 1
end

fetcher = IosReviewsFetcher::Fetcher.new
reviews = fetcher.fetch_all(app_id: options[:app_id], country: options[:country],
                            limit: options[:limit], per_page: options[:per_page],
                            lang: options[:lang], base_sleep: options[:sleep])

if options[:out]
  File.write(options[:out], JSON.pretty_generate(reviews))
  puts "Wrote #{reviews.size} reviews to #{options[:out]}"
else
  puts JSON.pretty_generate(reviews)
end