# frozen_string_literal: true

require 'dry/monads'

class AuthenticateUser < BasicInteractor

  def call(user_params)
    find_user(user_params[:email]).either(
      ->(user){user.valid_password?(user_params[:password]) ? Success(user) : Failure(:wrong_password) },
      ->(not_found){Failure(not_found)}
    )
  end

  private

  # def find_user(email)
  #   user = User.find_by(email: email)

  #   if user
  #     Success(user)
  #   else
  #     Failure(:user_not_found)
  #   end
  # end

  def find_user(email)
    Maybe(User.find_by(email: email))
      .to_result
      .or Failure(:user_not_found)
  end
end
