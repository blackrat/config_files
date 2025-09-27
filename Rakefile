require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end

task default: :test

desc "Run tests with verbose output"
task :test_verbose do
  sh "find test -name '*_test.rb' -exec bundle exec ruby {} \\;"
end

desc "Run tests for a specific Ruby version (for local testing)"
task :test_ruby_version do
  ruby_version = ENV['RUBY_VERSION'] || RUBY_VERSION
  puts "Running tests with Ruby #{ruby_version}"
  Rake::Task[:test].invoke
end

desc "Clean up test artifacts"
task :clean do
  FileUtils.rm_rf('test/format_test')
  FileUtils.rm_rf('test/comprehensive')
  FileUtils.rm_rf('test/order_test')
end
