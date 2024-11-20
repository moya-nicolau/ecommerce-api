# frozen_string_literal: true

task routes: :environment do
  system('bundle exec rails routes')
end
