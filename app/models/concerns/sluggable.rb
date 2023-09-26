module Sluggable
  extend ActiveSupport::Concern

  # アルファベットがABCEFGHなのは、見た目に識別しやすくするため
  SLUG_CHARS = '123456789ABCEFGH'.freeze

  included do
    include FriendlyId
    friendly_id :slug, use: :slugged
    validates :slug, presence: true, uniqueness: true, on: :update
    after_create :save_slug
  end

  def save_slug
    return if slug.present?
    hash = hashids.encode(self.id)
    slug = [slug_prefix, *hash.scan(/.{4}/)].join('-')
    # Devise invitableと一緒に使うとエラーが出るのでsaveは使わない
    self.update_column(:slug, slug)
  end

  def hashids
    @hashids ||= Hashids.new(self.class.name, 12, SLUG_CHARS)
  end

  def slug_prefix
    @slug_prefix ||= self.class.name.split('::').take(2).map(&:first).join
  end
end
