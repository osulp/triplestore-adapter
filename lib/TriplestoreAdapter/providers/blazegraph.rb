require 'rdf/blazegraph'
require 'sparql/client'
require 'rdf'

module TriplestoreAdapter::Providers
  class Blazegraph
    attr_reader :url, :client

    def initialize(url)
      @url = url
      @client = RDF::Blazegraph::RestClient.new(URI(@url.to_s))
    end

    def insert(statements)
      @client.insert(statements)
    end

    def delete(statements)
      @client.delete(statements)
    end

    def get_statements(subject: nil)
      @client.get_statements(subject: RDF::URI(subject))
    end
  end
end
