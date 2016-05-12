require 'spec_helper'

describe TriplestoreAdapter::Providers::Blazegraph do
  let(:url) { "http://localhost:9999/blazegraph/namespace/test/sparql" }
  let(:statements) do
    [
      RDF::Statement(RDF::URI('http://blah.blah.blah/blah'), RDF::Vocab::DC.title, "Blah"),
      RDF::Statement(RDF::URI('http://blah.blah.blah/blah'), RDF::Vocab::DC.relation, "Related to Blarg")
    ]
  end
  subject { described_class.new(url) }

  it 'builds a namespace' do
    expect(subject.build_namespace('test2')).to eq("http://localhost:9999/blazegraph/namespace/test2/sparql")
  end

  it 'deletes a namespace' do
    subject.build_namespace('test2')
    expect(subject.delete_namespace('test2')).to be_truthy
  end

  it 'inserts statements' do
    expect(subject.insert(statements)).to be_truthy
  end

  it 'deletes statements' do
    expect(subject.delete(statements)).to be_truthy
  end

  it 'gets statements' do
    subject.insert(statements)
    result = subject.get_statements(subject: statements.first.subject.to_s)
    graph = RDF::Graph.new << result
    statements.each do |s|
      expect(graph.has_statement?(s)).to be_truthy
    end
  end

  it 'clear statements' do
    expect(subject.clear_statements).to be_truthy
    result = subject.get_statements(subject: statements.first.subject.to_s)
    graph = RDF::Graph.new << result
    statements.each do |s|
      expect(graph.has_statement?(s)).to be_falsey
    end
  end
end
