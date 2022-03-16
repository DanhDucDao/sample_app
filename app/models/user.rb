class User < ApplicationRecord
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

  private

  def to_down_case str
    str.downcase!
  end
end
