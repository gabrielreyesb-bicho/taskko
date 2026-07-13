class Category < ApplicationRecord
  has_many :tasks, dependent: :restrict_with_error

  before_validation :normalize_name

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  scope :ordered, -> { order(Arel.sql("lower(name) ASC")) }

  def self.find_or_create_by_name!(value)
    normalized = normalize_name_value(value)
    where("lower(name) = ?", normalized.downcase).first || create!(name: normalized)
  end

  def self.normalize_name_value(value)
    value.to_s.strip.presence || "Personal"
  end

  private

  def normalize_name
    self.name = name.to_s.strip if name.present?
  end
end
