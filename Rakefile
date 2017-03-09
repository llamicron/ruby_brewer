require 'git'
require 'launchy'
require 'rdoc/task'

task default: %w[test]

# Unit testing
# You can specify a specific test case to use
# Ex: rake test['brewer']
task :test, [:tc] do |t, tc|
  if tc.to_a.any?
    ruby "tests/tc_#{tc.to_a[0]}.rb"
  else
    ruby "tests/ts_all.rb"
  end
end

# Opens code coverage in your browser
# This may be a bit shaky. Only tested on Mac.
# TODO: test on windows
# You can just open 'coverage/index.html' in your browser.
task :coverage do
  Launchy.open(Dir.pwd + '/coverage/index.html')
end

# Generate or update documentation
# Generates in `doc/`
RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = 'doc/'
  rdoc.rdoc_files.include("**/*.rb")
end

# Opens documentation.
task :docs do
  Launchy.open(Dir.pwd + '/doc/index.html')
end

# Clears coverage report
task :clear_coverage do
  rm_rf('coverage/')
end

# Adaptibrew tasks
# Clear, Clone, and Refresh
task :adaptibrew, [:method] do |t, method|
  case method.to_a.first
  when 'clear'
    rm_rf 'adaptibrew/'
  when 'clone'
    Git.clone('https://github.com/adaptiman/adaptibrew.git', 'adaptibrew')
  when 'refresh'
    rm_rf 'adaptibrew/'
    Git.clone('https://github.com/adaptiman/adaptibrew.git', 'adaptibrew')
  end
end
