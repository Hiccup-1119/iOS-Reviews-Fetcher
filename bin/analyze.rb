$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))

require 'optparse'
require 'json'
require 'ios_reviews_fetcher/analysis'

options = {in: nil, window_days: 30}

parser = OptionParser.new do |opts|
  opts.banner = 'Usage: analyze.rb --in reviews.json [--window_days 30]'
  opts.on('--in FILE', String, 'Input JSON file (from fetch.rb)') {|v| options[:in] = v}
  opts.on('--window_days N', Integer, 'Days window for velocity(default : 30)'){|v| options[:window_days] = v}
end

begin
  parser.parse!
  raise OptionParser::MissingArgument, '--in is required' unless options[:in]
rescue OptionParser::ParseError => e
  warn e.message
  puts parser
  exit 1
end

reviews = JSON.parse(File.read(options[:in]), symbolize_names: true)
per_version = IosReviewsFetcher::Analysis.per_version_star_counts(reviews)
rpd = IosReviewsFetcher::Analysis.reviews_per_day(reviews, window_days: options[:window_days])

puts '=== Per-Version Star Counts ==='
per_version.keys.sort.each do |ver|
  counts = per_version[ver]
  line = (1..5).map { |s| "#{s}★=#{counts[s]}" }.join('  ')
  puts "#{ver.ljust(12)} #{line}"
end

puts
puts "Estimated Reviews/Day (last #{options[:window_days]} days): #{rpd}"

