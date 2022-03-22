class User < ApplicationRecord
  attr_accessor :remember_token
  VALID_EMAIL_REGEX = Settings.validations.regrex.mail.freeze

  before_save{to_down_case email}
  validates :name, presence: true,
                    length: {maximum: Settings.validations.length.name_max}
  validates :email, presence: true,
                    length: {maximum: Settings.validations.length.mail_max},
                    format: {with: VALID_EMAIL_REGEX},
                    uniqueness: true
  has_secure_password

  validates :password, presence: true,
                    length: {minimum: Settings.validations.length.password_min}

  def remember
    @remember_token = User.new_token
    update_attribute :remember_digest, User.digest(@remember_token)
  end

  def forget
    update_attribute :remember_digest, nil
  end

  def authenticated? remember_token
    return false if remember_digest.blank?

    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def self.digest string
    cost =  if ActiveModel::SecurePassword.min_cost
              BCrypt::Engine::MIN_COST
            else
              BCrypt::Engine.cost
            end
    BCrypt::Password.create string, cost: cost
  end

  def self.new_token
    SecureRandom.urlsafe_base64
  end

  private

  def to_down_case str
    str.downcase!
  end
end
