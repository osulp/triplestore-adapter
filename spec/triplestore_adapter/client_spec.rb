require 'spec_helper'

module TriplestoreAdapter::Providers
  class Spectestbogus
    def initialize(url)
    end
  end
end

describe TriplestoreAdapter::Client do
  let(:client) { TriplestoreAdapter::Client.new(provider_name, url) }
  let(:url) { "expect-failure-not-a-uri" }
  let(:provider_name) { "bogus-provider-name" }

  context 'with an invalid provider name' do
    let(:url) { "http://localhost:9999/blazegraph/namespace/test/sparql" }
    it 'fails to initialize the client' do
      expect{client}.to raise_error(NameError)
    end
  end

  context 'with an invalid url' do
    let(:provider_name) { "blazegraph" }
    it 'fails to initialize the client ' do
      expect{client}.to raise_error(TriplestoreAdapter::TriplestoreException, "#{url} is not a valid URI")
    end
  end

  context 'with a provider that does not respond to all methods' do
    let(:provider_name) { "spectestbogus" }
    let(:url) { "http://localhost:9999" }
    it 'fails to call insert' do
      expect{ client.insert([]) }.to raise_error(TriplestoreAdapter::TriplestoreException, "#{client.provider.class.name} missing insert method.")
    end
    it 'fails to call delete' do
      expect{ client.delete([]) }.to raise_error(TriplestoreAdapter::TriplestoreException, "#{client.provider.class.name} missing delete method.")
    end
    it 'fails to call get_statements' do
      expect{ client.get_statements(subject: "") }.to raise_error(TriplestoreAdapter::TriplestoreException, "#{client.provider.class.name} missing get_statements method.")
    end
  end

  context 'with a blazegraph type client' do
    let(:provider_name) { "blazegraph" }
    let(:url) { "http://localhost:9999/blazegraph/namespace/test/sparql" }
    it 'initializes a blazegraph provider' do
      expect(client.provider.class).to eq(TriplestoreAdapter::Providers::Blazegraph)
      expect(client.url).to eq(url)
    end

    context 'with a mocked provider returns' do
      it 'returns provider.insert' do
        allow(client.provider).to receive(:insert).and_return([])
        expect(client.insert([])).to eq([])
      end
      it 'returns provider.delete' do
        allow(client.provider).to receive(:delete).and_return([])
        expect(client.delete([])).to eq([])
      end
      it 'returns provider.get_statements' do
        allow(client.provider).to receive(:get_statements).with(subject: "").and_return([])
        expect(client.get_statements(subject: "")).to eq([])
      end
      it 'returns provider.clear_statements' do
        allow(client.provider).to receive(:clear_statements).and_return(true)
        expect(client.clear_statements()).not_to be_nil
      end
    end
  end
end
