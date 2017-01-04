require "rake/testtask"

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*_test.rb']
  puts t.inspect
end
desc "Run tests"
task :default => :test
