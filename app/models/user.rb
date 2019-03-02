class User < ApplicationRecord
  #   データベースに登録する前にemailを文字の大小関わらず区別するために強制的にdowncaseする
  before_save { email.downcase! } # = self.email = email.downcase
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
  validates :password, presence: true, length: { minimum: 6 }
end
