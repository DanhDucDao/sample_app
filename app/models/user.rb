class User < ApplicationRecord
  VALID_EMAIL_REGEX = Settings.validations.regrex.mail.freeze
  attr_accessor :remember_token, :activation_token

  before_save{to_down_case email}
  before_create :create_activation_digest

  validates :name, presence: true,
                    length: {maximum: Settings.validations.length.name_max}
  validates :email, presence: true,
                    length: {maximum: Settings.validations.length.mail_max},
                    format: {with: VALID_EMAIL_REGEX},
                    uniqueness: true
  has_secure_password

  validates :password, presence: true,
                    length: {minimum: Settings.validations.length.password_min},
                    allow_nil: true

  scope :ordered_by_name, ->{order :name}
  scope :activated, ->{where activated: true}

  def remember
    @remember_token = User.new_token
    update_attribute :remember_digest, User.digest(@remember_token)
  end

  def forget
    update_attribute :remember_digest, nil
  end

  def authenticated? attribute, token
    digest = send("#{attribute}_digest")
    return false if digest.blank?

    BCrypt::Password.new(digest).is_password?(token)
  end

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost: cost
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def activate
    update_columns activated: true, activated_at: Time.zone.now
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  private

  def to_down_case str
    str.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest activation_token
  end
end
