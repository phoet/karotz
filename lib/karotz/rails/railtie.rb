module Karotz
  module Rails
    class Railtie < ::Rails::Railtie
      rake_tasks do
        load 'karotz/rails/karotz.rake'
      end
    end
  end
end
