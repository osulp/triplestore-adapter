require 'rdf'
require 'uri'

module TriplestoreAdapter
  class Client
    attr_reader :provider, :url

    def initialize(provider_name, url)
      raise TriplestoreAdapter::TriplestoreException.new("#{url} is not a valid URI") unless url =~ URI::DEFAULT_PARSER.regexp[:ABS_URI]
      @url = url

      klass = Object.const_get("TriplestoreAdapter::Providers::#{provider_name.capitalize}")
      @provider = klass.new(@url)
    end

    def insert(statements)
      raise TriplestoreAdapter::TriplestoreException.new("#{@provider.class.name} missing insert method.") unless @provider.respond_to?(:insert)
      @provider.insert(statements)
    end

    def delete(statements)
      raise TriplestoreAdapter::TriplestoreException.new("#{@provider.class.name} missing delete method.") unless @provider.respond_to?(:delete)
      @provider.delete(statements)
    end

    def get_statements(subject: nil)
      raise TriplestoreAdapter::TriplestoreException.new("#{@provider.class.name} missing get_statements method.") unless @provider.respond_to?(:get_statements)
      @provider.get_statements(subject: subject)
    end
  end
end
