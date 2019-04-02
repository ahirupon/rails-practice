class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token
  #   データベースに登録する前にemailを文字の大小関わらず区別するために強制的にdowncaseする
  before_save :downcase_email # = self.email = email.downcase
  before_create :create_activation_digest
  # name属性を検索するため
  validates :name, presence: true, length: { maximum: 50 }
  #   メアドの正規表現
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.freeze
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    # 文字の大小関係ないよ(ununiquenessはtrue)rails generate migration add_index_to_users_email
                    uniqueness: { case_sensitive: false }
  # セキュアにハッシュ化したパスワードをデータベースのpassword_digest属性に保存できる。
  # 二つの仮想的な属性(passwordとpassword_confirmation)が使えるようになる、また存在性と値が一致するかどうかの
  # バリデーションも追加される。
  # authenticateメゾットが使えるようになる(引数の文字列がパスワードと一致するとUserオブジェクトを、そうでないとfalseを返す。)
  has_secure_password
  # 　パスワードの文字制限
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  # 渡された文字列のハッシュ値を返す
  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを返す
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  # 永続セッションのためにユーザーをデータベースに記憶する
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?

    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  # アカウントを有効にする
  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # 有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  private

  # メールアドレスをすべて小文字化
  def downcase_email
    email.downcase!
  end

  # 有効化トークンとダイジェストを作成および代入する
  def create_activation_digest
    self.activation_token  = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
