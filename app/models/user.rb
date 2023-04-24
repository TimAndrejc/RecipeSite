class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: [:google_oauth2, :facebook]
  has_many :recipes
  def self.from_google(u)
    create_with(uid: u[:uid], provider: 'google',
                password: Devise.friendly_token[0, 20]).find_or_create_by!(email: u[:email])
  end
  def self.from_omniauth(auth)
    user = User.where(email: auth.info.email).first
    user ||= User.create!(provider: auth.provider, uid: auth.uid,  email: auth.info.email, password: Devise.friendly_token[0, 20])
      user
  end
end
