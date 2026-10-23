# The tenant. Every todo, category and tag belongs to exactly one, and
# acts_as_tenant keeps queries inside the current one.
class Workspace < ApplicationRecord
  has_many :users, dependent: :nullify
  has_many :todos, dependent: :delete_all
  has_many :categories, dependent: :delete_all
  has_many :tags, dependent: :delete_all

  normalizes :name, with: ->(name) { name.squish }

  validates :name, presence: true, length: { maximum: 60 }
  validates :slug, presence: true, uniqueness: true

  before_validation :set_slug
  # Again on save, because a record written with validate: false still
  # needs a slug to satisfy the database.
  before_save :set_slug

  def self.personal_for(name)
    new(name: "#{name.presence || 'My'} workspace")
  end

  private

  def set_slug
    self.slug ||= "#{name.to_s.parameterize.presence || 'workspace'}-#{SecureRandom.hex(4)}"
  end
end
