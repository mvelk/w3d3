# == Schema Information
#
# Table name: shortened_urls
#
#  id         :integer          not null, primary key
#  short_url  :string
#  long_url   :string           not null
#  user_id    :integer          not null
#  created_at :datetime
#  updated_at :datetime
#

require 'securerandom'

class ShortenedUrl < ActiveRecord::Base
  validates :short_url, :long_url, :user_id, presence: true
  validates :short_url, uniqueness: true
  validate :long_url_less_than_1024
  validate :recent_urls_less_than_5

  belongs_to :submitter,
    class_name: :User,
    primary_key: :id,
    foreign_key: :user_id

  has_many :visits,
    class_name: :Visit,
    primary_key: :id,
    foreign_key: :shortened_url_id

  has_many :visitors, proc { distinct },
    through: :visits,
    source: :user

  has_many :taggings,
    class_name: :Tagging,
    primary_key: :id,
    foreign_key: :shortened_url_id

  def self.random_code
    # make a random short_url
    short_url = nil
    loop do
      short_url = SecureRandom.urlsafe_base64
      break unless ShortenedUrl.exists?(short_url: short_url)
    end
    short_url
  end

  def self.create_for_user_and_long_url!(user, long_url)
    short_url = ShortenedUrl.random_code
    ShortenedUrl.create!(
      short_url: short_url,
      long_url: long_url,
      user_id: user.id
    )
  end

  def self.purge_old_urls
    # we want to select all URLS who do not have a visit within the last 10 minutes
    # then kill them dead!
    urls = ShortenedUrl.all
    urls.each do |url|
      url.destroy if url.num_recent_uniques == 0
    end

  end

  def num_clicks
    self.visits.count
  end

  def num_uniques
    # unique_visitors = Set.new
    # self.visits.each do |visit|
    #   unique_visitors << visit.user
    # end
    # unique_visitors.size
    # self.visits.select(:user_id).distinct.count
    self.visitors.count
  end

  def num_recent_uniques
    self.visits.select(:user_id).distinct.where(created_at: 10.minutes.ago..Time.now).count
  end

  def user_recent_submissions
    self.submitter.submitted_urls.where(created_at: 1.minutes.ago..Time.now).count
  end


  private

  def long_url_less_than_1024
    errors[:long_url_length] << "cannot exceed 1024" if long_url.length > 1024
  end

  def recent_urls_less_than_5
    if !self.submitter.premium && user_recent_submissions > 5
      errors[:url_submissions] << "cannot exceed 5 in one minute"
    end
  end

end
