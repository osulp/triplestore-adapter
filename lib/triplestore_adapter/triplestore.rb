include 'rdf/rdfxml'

module TriplestoreAdapter
  class Triplestore

    attr_reader :client

    ##
    # @param [Triplestore::Client] client
    def initialize(client)
      @client = client
    end

    ##
    # Fetch a graph of the url to the RDF, first attempting to fetch the graph
    # from the triplestore cache.
    #
    # @param [String] rdf_url
    # @return [RDF::Graph]
    def fetch(rdf_url, from_remote: nil)
      begin
        graph = fetch_cached_graph(rdf_url)

        if graph.nil? && !from_remote
          raise TriplestoreAdapter::TriplestoreException, "graph not found in cache. Skipping fetch from remote graph"
        elsif graph.nil?
          graph = fetch_and_cache_graph(rdf_url)
        end

        graph
      rescue => e
        raise TriplestoreAdapter::TriplestoreException, e.message
      end
    end

    ##
    # Store the graph in the triplestore cache
    #
    # @param [RDF::Graph] graph
    # @return [RDF::Graph]
    # @raise [Exception] if client fails to store the graph
    def store(graph)
      begin
        statements = graph.each_statement.to_a
        @client.insert(statements)
        graph
      rescue => e
        raise TriplestoreAdapter::TriplestoreException, "store graph in triplestore cache failed with exception: #{e.message}"
      end
    end

    ##
    # Delete the graph from the triplestore cache
    #
    # @param [String] rdf_url
    # @return [Boolean]
    def delete(rdf_url)
      begin
        graph = fetch_cached_graph(rdf_url)
        puts "[INFO] did not delete #{rdf_url}, it doesn't exist in the triplestore cache" if graph.nil?
        return true if graph.nil?

        statements = graph.each_statement.to_a
        @client.delete(statements)
        return true
      rescue => e
        raise TriplestoreAdapter::TriplestoreException, "delete #{rdf_url} from triplestore cache failed with exception: #{e.message}"
      end
    end

    ##
    # Delete all graphs from the triplestore cache
    #
    # @return [Boolean]
    def delete_all_statements
      begin
        @client.clear_statements
        return true
      rescue => e
        raise TriplestoreAdapter::TriplestoreException, "delete_all_statements from triplestore cache failed with exception: #{e.message}"
      end
    end
    private

    ##
    # Fetch the graph from the triplestore cache
    #
    # @private
    # @param [String] url
    # @return [RDF::Graph] if the graph is found in the cache
    # @return [nil] if the graph was not in the cache
    def fetch_cached_graph(rdf_url)
      statements = @client.get_statements(subject: rdf_url.to_s)
      if statements.count == 0
        puts "[INFO] fetch_cached_graph(#{rdf_url.to_s}) not found in triplestore cache (#{@client.url})"
        return nil
      end
      RDF::Graph.new.insert(*statements)
    end

    ##
    # Fetch the graph from the source URL, and cache it for future use
    #
    # @private
    # @param [String] url
    # @return [RDF::Graph] if a graph is found
    # @raise [Exception] if fetching the graph failed
    def fetch_and_cache_graph(rdf_url)
      begin
        graph = RDF::Graph.load(rdf_url)
        store(graph)
        graph
      rescue TriplestoreAdapter::TriplestoreException => tse
        puts "[ERROR] *****\n[ERROR] Unable to store graph in triplestore cache! Returning graph fetched from source.\n[ERROR] *****\n#{tse.message}"
        graph
      rescue => e
        raise TriplestoreAdapter::TriplestoreException, "fetch_and_cache_graph(#{rdf_url}) failed to load the graph with exception: #{e.message}"
      end
    end
  end
end

