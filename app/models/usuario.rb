class Usuario < ApplicationRecord
  self.table_name = "usuarios"

  belongs_to :curso, optional: true
  belongs_to :departamento, optional: true
  has_many :matriculas, dependent: :destroy
  has_many :turmas, through: :matriculas
  has_many :respostas, dependent: :destroy

  attr_reader :password
  attr_accessor :password_confirmation, :validating_password_rules

  validates :email, presence: true

  # Custom password hashing using bcrypt to work with existing 'senha_hash' column
  def authenticate(unencrypted_password)
    return false if senha_hash.blank?
    BCrypt::Password.new(self.senha_hash) == unencrypted_password
  rescue BCrypt::Errors::InvalidHash
    false
  end

  def password=(unencrypted_password)
    @password = unencrypted_password
    self.senha_hash = BCrypt::Password.create(unencrypted_password) if unencrypted_password.present?
  end

  validate :password_security_rules, if: :validating_password_rules

  def pode_gerenciar_turma?(turma)
    departamento_id == turma.departamento_id
  end

  # Helpers to generate tokens
  def generate_setup_token!
    self.setup_token = SecureRandom.hex(20)
    self.setup_token_sent_at = Time.current
    self.setup_token_used = false
    save!
  end

  def generate_reset_token!
    self.reset_token = SecureRandom.hex(20)
    self.reset_token_sent_at = Time.current
    self.reset_token_used = false
    save!
  end

  private

  def password_security_rules
    return handle_missing_passwords if password.blank? || password_confirmation.blank?

    check_password_match
    check_password_length
    check_password_numbers
    check_password_lowercase
  end

  def handle_missing_passwords
    errors.add(:password, "Preencha todos os campos obrigatórios")
  end

  def check_password_match
    errors.add(:password, "As senhas não coincidem") if password != password_confirmation
  end

  def check_password_length
    errors.add(:password, "Senha deve ter no mínimo 6 caracteres") if password.length < 6
  end

  def check_password_numbers
    errors.add(:password, "A senha deve conter pelo menos um número") unless password.match(/\d/)
  end

  def check_password_lowercase
    errors.add(:password, "A senha deve conter apenas letras minúsculas") if password.match(/[A-Z]/)
  end
end
