require 'spec_helper'

describe TriplestoreAdapter::Providers::Blazegraph do
  let(:url) { "http://localhost:9999/blazegraph/namespace/test/sparql" }
  subject { described_class.new(url) }

  it 'builds a namespace' do
    expect(subject.build_namespace('test2')).to be_truthy
  end

  it 'deletes a namespace' do
    subject.build_namespace('test2')
    expect(subject.delete_namespace('test2')).to be_truthy
  end
end
