Gem::Specification.new do |s|
  s.name = 'rexle-diff'
  s.version = '0.2.0'
  s.summary = 'rexle-diff'
  s.authors = ['James Robertson']
  s.files = Dir['lib/**/*.rb']
  s.add_runtime_dependency('rexle', '~> 1.2', '>=1.2.23')
  s.signing_key = '../privatekeys/rexle-diff.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@r0bertson.co.uk'
  s.homepage = 'https://github.com/jrobertson/rexle-diff'
end
