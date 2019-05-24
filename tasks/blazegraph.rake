require 'net/http'

rails_env = ENV['RAILS_ENV'] || 'test'
root_path = File.expand_path("../../", __FILE__)
app_root_path = root_path
app_root_path = Rails.root if defined?(Rails)
tmp_path = File.join(app_root_path, "/tmp")
log_path = File.join(app_root_path, "/log")


BLAZEGRAPH_HOME = ENV['BLAZEGRAPH_HOME'] || File.join(app_root_path, '/blazegraph')
BLAZEGRAPH_CONFIG_LOG4J = ENV['BLAZEGRAPH_CONFIG_LOG4J'] || File.join(app_root_path, "/config/triplestore_adapter/blazegraph/log4j.properties")
BLAZEGRAPH_CONFIG_DEFAULT = ENV['BLAZEGRAPH_CONFIG_DEFAULT'] || File.join(app_root_path, "/config/triplestore_adapter/blazegraph/blazegraph.properties")

BLAZEGRAPH_DOWNLOAD_URL = ENV['BLAZEGRAPH_DOWNLOAD'] || "https://sourceforge.net/projects/bigdata/files/latest/download"
BLAZEGRAPH_URL = ENV['BLAZEGRAPH_URL'] || 'http://localhost:9999/blazegraph'
BLAZEGRAPH_SPARQL = "#{BLAZEGRAPH_URL}/namespace/#{rails_env}/sparql"

namespace :triplestore_adapter do
  namespace :blazegraph do
    desc "Delete journal, download, and restart Blazegraph"
    task :reset do
      Rake::Task['triplestore_adapter:blazegraph:setup'].invoke
      sleep(2)
      Rake::Task['triplestore_adapter:blazegraph:clean'].invoke
      Rake::Task['triplestore_adapter:blazegraph:download'].invoke
      Rake::Task['triplestore_adapter:blazegraph:start'].invoke
      puts "Waiting for Blazegraph server to settle"
      sleep(5)
      Rake::Task['triplestore_adapter:blazegraph:build_namespace'].invoke
      puts "\n\n\nYay! Blazegraph should be ready to roll."
    end

    desc "Download Blazegraph if necessary"
    task :download do
      cached_jar = File.join(tmp_path, "blazegraph.jar")
      if File.exist?(cached_jar)
        puts "#{cached_jar} exists, skipping download."
      else
        uri = URI(BLAZEGRAPH_DOWNLOAD_URL)
        puts "Downloading Blazegraph from #{uri}, please wait."
        # wget properly handles redirects for an appropriate mirror
        dl = spawn "cd #{tmp_path} && wget #{uri} -O #{cached_jar}"
        Process.wait dl
      end
      puts "Copying #{cached_jar} to #{BLAZEGRAPH_HOME}/blazegraph.jar."
      cp = spawn "cp #{cached_jar} #{BLAZEGRAPH_HOME}/blazegraph.jar"
      Process.wait cp
    end

    desc "Delete existing journal file"
    task :clean do
      puts "Removing blazegraph journal(s) from #{BLAZEGRAPH_HOME}"
      FileUtils.rm_rf(Dir.glob("#{BLAZEGRAPH_HOME}/*.jnl"))
    end

    desc "Kill existing process(es) and restart Blazegraph"
    task :start do
      Rake::Task['triplestore_adapter:blazegraph:stop'].invoke

      puts "Starting Blazegraph server"
      pid = spawn "nohup java -server -Xmx4g -Dbigdata.propertyFile=#{File.expand_path(BLAZEGRAPH_CONFIG_DEFAULT)} -Dlog4j.configuration=file:#{File.expand_path(BLAZEGRAPH_CONFIG_LOG4J)} -jar #{BLAZEGRAPH_HOME}/blazegraph.jar > log/blazegraph.log 2>&1&"
      sleep(10)
      puts "Blazegraph started on PID #{pid}"
    end
    
    desc "Kill existing process(es)"
    task :stop do
      # finds existing blazegraph server processes and kills them
      puts "Stopping Blazegraph server"
      killer = spawn "ps aux | grep blazegraph.jar | grep -server | awk '{print $2}' | xargs kill"
      Process.wait killer
    end

    desc "Create (if needed) the rails_env Blazegraph namespace"
    task :build_namespace do
      puts "Building #{rails_env} namespace"
      post = spawn "curl -v -X POST -d 'com.bigdata.rdf.sail.namespace=#{rails_env}' --header 'Content-Type:text/plain' #{BLAZEGRAPH_URL}/namespace"
      Process.wait post
    end

    desc "Post some JSONLD from FILE env"
    task :post_rdf do
      post = spawn "curl -v -X POST --data-binary @#{File.expand_path(ENV['file'])} --header 'Content-Type:application/ld+json' #{BLAZEGRAPH_SPARQL}"
      Process.wait post
    end

    desc "Setup directories and configurations"
    task :setup do
      Dir.mkdir(log_path) unless File.exists?(log_path)
      Dir.mkdir(BLAZEGRAPH_HOME) unless File.exists?(BLAZEGRAPH_HOME)
      Dir.mkdir(tmp_path) unless File.exists?(tmp_path)

      src_configs = File.join(root_path, "/config/blazegraph")
      app_configs = File.join(app_root_path, "/config/triplestore_adapter/blazegraph")
      puts "Copying src configs (#{src_configs}) to app configs (#{app_configs})"

      # Create the directory structure if it doesn't exist
      FileUtils.mkdir_p(app_configs)

      # Copy files from the gem source configs to the Rails app configs
      Dir["#{src_configs}/*"].each do |src|
        dest_config = File.join(app_configs, File.basename(src))
        if File.exists?(dest_config)
          puts "Skipping copy, #{dest_config} exists."
        else
          puts "#{src} copied to #{app_configs}."
          FileUtils.cp(src, app_configs)
        end
      end
    end
  end
end
