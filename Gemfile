source 'http://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }
git_source(:cashloans) { |repo| "git@gitlab.infra.b-pl.pro:cash/#{repo}.git" }


# Specify your gem's dependencies in lead.gemspec
gemspec

gem 'rake', '~> 10.0'
gem 'rspec', '~> 3.0'
gem 'cash-rubocop', cashloans: 'cash-rubocop', tag: '2.1.2'
