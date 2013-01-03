namespace :comufy do

  desc "Register a tag with your application"
  task :register_tag, [:name, :tag] => :environment do |t, args|
    p Comufyrails.config.access_token
  end

end
