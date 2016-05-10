require "triplestore_adapter/exception"
require "triplestore_adapter/client"
require "triplestore_adapter/providers/blazegraph"
require "triplestore_adapter/triplestore"

module TriplestoreAdapter

  # Load this gems rake tasks·
  if defined?(Rails)
    ROOT_PATH = File.expand_path "../../", __FILE__
    module ::Rails
      class Application
        rake_tasks do
          Dir[File.join(ROOT_PATH, "/tasks/", "*.rake")].each do |f|
            load f
          end
        end

      end
    end
  end
end
