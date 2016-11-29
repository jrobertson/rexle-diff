Gem::Specification.new do |s|
  s.name = 'rexle-diff'
  s.version = '0.6.0'
  s.summary = 'Compares XML and returns the latest XML with changes identified by datetime stamps in the attributes.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/rexle-diff.rb']
  s.add_runtime_dependency('rexle', '~> 1.4', '>=1.4.1')
  s.add_runtime_dependency('fuzzy_match', '~> 2.1', '>=2.1.0')
  s.signing_key = '../privatekeys/rexle-diff.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@r0bertson.co.uk'
  s.homepage = 'https://github.com/jrobertson/rexle-diff'
end
