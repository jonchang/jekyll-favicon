require 'test_helper'

describe Jekyll::Favicon do
  it 'should have a version number' do
    refute_nil Jekyll::Favicon::VERSION
  end

  it 'should have a config paramenter' do
    config = Jekyll::Favicon.config
    refute_empty config
    refute_empty config['source']
    refute_empty config['background']
    refute_empty config['path']
    refute_empty config['svg']
    refute_empty config['icons']
    refute_empty config['icons']['shared']
    refute_empty config['icons']['shared']['targets']
    refute_empty config['icons']['safari']
    refute_empty config['icons']['safari']['targets']
    refute_empty config['icons']['chrome']
    refute_empty config['icons']['chrome']['targets']
    refute_empty config['icons']['ie']
    refute_empty config['icons']['ie']['targets']
    refute_empty config['browserconfig']
    refute_empty config['webmanifest']
  end
end
