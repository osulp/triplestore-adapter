require 'spec_helper'

describe TriplestoreAdapter::Triplestore do
  let(:client) { TriplestoreAdapter::Client.new(provider_name, url) }
  let(:url) { "http://localhost:9999/blazegraph/namespace/test/sparql" }
  let(:provider_name) { "blazegraph" }

  let(:rdf_url) { 'http://opaquenamespace.org/ns/genus/Aphrodite' }
  let(:statements) do
    [
      RDF::Statement(RDF::URI('http://blah.blah/blah'), RDF::Vocab::DC.title, 'blah'),
      RDF::Statement(RDF::URI('http://blah.blah/blah'), RDF::Vocab::DC.relation, RDF::Node.new)
    ]
  end

  subject { described_class.new(client) }

  it 'initializes the triplestore ' do
    expect(subject.client).to eq(client)
  end

  context "with an existing RDF::Graph" do
    let(:graph) { RDF::Graph.new.insert(*statements) }
    it "should store the graph" do
      result = subject.store(graph)
      expect(result).to eq(graph)
    end
  end

  context "with a valid URI" do
    before :each do
      subject.fetch(rdf_url)
    end
    it "should return a graph" do
      graph = subject.fetch(rdf_url)
      expect(graph).to be_an_instance_of(RDF::Graph)
      expect(graph.to_a.size).to be > 0
    end
    it "should delete the graph" do
      expect(subject.delete(rdf_url)).to be_truthy
    end
    it "should return a cached graph" do
      g = subject.send(:fetch_and_cache_graph, rdf_url)
      expect(g).to be_an_instance_of(RDF::Graph)
    end
  end

  context "with an invalid URI" do
    let(:rdf_url) { 'http://localhost:9999/bogusns/thisshouldntwork' }
    it "should raise an exception" do
      expect { subject.fetch(rdf_url) }.to raise_exception(TriplestoreAdapter::TriplestoreException)
    end
    it "should return true for nonexistent RDF delete" do
      expect(subject.delete(rdf_url)).to be_truthy
    end
  end

  context "with mocked RDF::Graph or class methods " do
    let(:graph) { RDF::Graph.new.insert(*statements) }
    before do
      allow(subject.client).to receive(:insert).and_raise("boo")
      allow(subject.client).to receive(:delete).and_raise("boo")
    end
    it "should raise an exception when trying to fetch" do
      allow(subject).to receive(:fetch_cached_graph).with(rdf_url).and_raise("boo")
      expect { subject.fetch(rdf_url) }.to raise_exception(TriplestoreAdapter::TriplestoreException)
    end
    it "should raise an exception when trying to store" do
      expect { subject.store(graph) }.to raise_exception(TriplestoreAdapter::TriplestoreException)
    end
    it "should raise an exception when trying to delete" do
      expect { subject.delete(rdf_url) }.to raise_exception(TriplestoreAdapter::TriplestoreException)
    end
    describe "and malfunctioning triplestore" do
      before do
        allow(subject).to receive(:store).and_raise(TriplestoreAdapter::TriplestoreException, "boo")
      end
      it "should return the graph loaded from the source" do
        # call a private class method to test scenario wherein the triplestore
        # cache is malfunctioning and the source RDF is loaded
        g = subject.send(:fetch_and_cache_graph, rdf_url)
        expect(g).to be_an_instance_of(RDF::Graph)
      end
    end
  end
end
