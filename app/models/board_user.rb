class BoardUser < ApplicationRecord
  # Associations
  belongs_to :board
  belongs_to :user
  belongs_to :created_by, class_name: 'User'

  # Validations
  validates :board, presence: true
  validates :user, presence: true
  validates :created_by, presence: true
  validates :user_id, uniqueness: { scope: :board_id }

  # Callbacks
  before_create :set_defaults

  # Scopes
  scope :active, -> { where(status: 1) }
  scope :recent_visits, -> { order(visited_on: :desc) }

  # Instance methods
  def active?
    status == 1
  end

  def mark_visited
    update(visited_on: Time.current)
  end

  def days_since_visit
    return nil unless visited_on
    ((Time.current - visited_on) / 1.day).to_i
  end

  private

  def set_defaults
    self.status ||= 1
    self.visited_on ||= Time.current
  end
end 