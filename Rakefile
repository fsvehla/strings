desc "Run tests"
task :test do
  spec_files = FileList["spec/**/*_spec.rb"]
  sh "bundle exec rspec -fn #{ spec_files }"
end

task :default => :test
