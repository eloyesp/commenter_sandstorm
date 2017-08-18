$stdout.sync
require 'cuba'
require 'cuba/render'
require 'erb'

FileUtils.mkdir_p '/var/tmp/tasks', verbose: true

Cuba.plugin Cuba::Render

def publish_site session_id
  puts "publishing"
  FileUtils.mkdir_p '/var/www', verbose: true
  File.write '/var/www/index.html', 'Texto'
  p `bin/getPublicId #{ session_id }`
end

Cuba.define do
  on root do
    on get do
      render 'main'
    end
    on post do
      params = req.params
      if params['name'] == 'publish'
        warn "should publish"
        warn publish_site(req.get_header('HTTP_X_SANDSTORM_SESSION_ID'))
      else
        Task.create params['name'], params['description']
      end
      res.redirect '/'
    end
  end
end

class Task
  attr_reader :name, :description

  def initialize name, description
    @name = name
    @description = description
  end

  def self.create name, description
    new(name, description).save
  end

  def self.all
    Dir["/var/www/*"].map do |task_file|
      new File.basename(task_file), File.read(task_file)
    end
  end

  def save
    File.write("/var/www/#{ name }", description.to_s)
  end
end
