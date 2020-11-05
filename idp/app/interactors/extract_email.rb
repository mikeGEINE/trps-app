# frozen_string_literal: true

require 'dry/monads'

class ExtractEmail < BasicInteractor

  def call(token)
    email = token.first["email"]
    email ? Success(email) : Failure(:no_email)
  end
end
