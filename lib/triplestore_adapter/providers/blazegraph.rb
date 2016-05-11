require 'rdf/blazegraph'
require 'sparql/client'
require 'rdf'
require 'uri'

require 'pry'

module TriplestoreAdapter::Providers
  class Blazegraph
    attr_reader :url, :client

    def initialize(url)
      @http = Net::HTTP::Persistent.new(self.class)
      @url = url
      @uri = URI.parse(@url.to_s)
      @client = RDF::Blazegraph::RestClient.new(@uri)
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

    def clear_statements
      @client.clear_statements
    end

    def build_namespace(namespace)
      request = Net::HTTP::Post.new("#{build_url}/blazegraph/namespace")
      request['Content-Type'] = 'text/plain'
      request.body = "com.bigdata.rdf.sail.namespace=#{namespace}"
      @http.request(@uri, request)
    end

    def delete_namespace(namespace)
      request = Net::HTTP::Delete.new("#{build_url}/blazegraph/namespace/#{namespace}}")
      @http.request(@uri, request)
    end

    private
    def build_url
      port = ":#{@uri.port}" if @uri.port != 80
      "#{@uri.scheme}://#{@uri.host}#{port}"
    end
  end
end
