# == Schema Information
#
# Table name: taggings
#
#  id               :integer          not null, primary key
#  shortened_url_id :integer          not null
#  tag_topic_id     :integer          not null
#

class Tagging < ActiveRecord::Base
  belongs_to :topic,
    class_name: :TagTopic,
    primary_key: :id,
    foreign_key: :tag_topic_id

  belongs_to :url,
    class_name: :ShortenedUrl,
    primary_key: :id,
    foreign_key: :shortened_url_id
end
