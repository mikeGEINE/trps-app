# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

class BasicInteractor
  extend Dry::Initializer
  def self.inherited(klass)
    klass.include Dry::Monads[:maybe, :result, :try]
    klass.include Dry::Monads::Do.for(:call)
  end
  class << self
    # Instantiates and calls the service at once
    def call(*args, &block)
      new(*args).call(&block)
    end
    # Accepts both symbolized and stringified attributes
    def new(*args)
      args << args.pop.symbolize_keys if args.last.is_a?(Hash)
      super(*args)
    end
  end
  private
  def error_message(key, **attrs)
    I18n.t("interactors.#{self.class.name.underscore.tr('/', '.')}.errors.#{key}", attrs)
  end
  class Error < StandardError; end
end