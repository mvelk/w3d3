
namespace :pruning do
  desc "Purge stale entries from ShortenedUrl table"
  task purge_old_urls: :environment do
    puts "Purging old Shortened URLs"
    ShortenedUrl.purge_old_urls
  end
end
