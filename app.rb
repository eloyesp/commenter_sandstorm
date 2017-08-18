$stdout.sync
require 'cuba'
require 'cuba/render'
require 'erb'
require 'json'

FileUtils.mkdir_p '/var/tmp/tasks', verbose: true

Cuba.plugin Cuba::Render

def publish_site session_id
  return $public_id if $public_id
  if false && File.exist?('/var/public_id')
    $public_id = File.read '/var/public_id'
  else
    warn "publishing"
    FileUtils.mkdir_p '/var/www'
    File.write '/var/www/index.html', 'Texto'
    File.write '/var/www/commenter.js', File.read('/commenter.js')
    $public_id = `bin/getPublicId #{ session_id }`.lines[2].chomp
    File.write '/var/public_id', $public_id
  end
end

Cuba.define do
  on root do
    on get do
      publish_site(req.get_header('HTTP_X_SANDSTORM_SESSION_ID'))
      render 'main'
    end
    on post do
      params = req.params
      Task.create params['name'], params['description']
      res.redirect '/'
    end
  end

  on 'api' do
    Comments.add req.params['body']
    res.write 'ok'
  end
end

class Comments
  COMMENT_FILE = '/var/www/messages.json'

  def self.all
    if File.exist? COMMENT_FILE
      JSON.parse File.read(COMMENT_FILE)
    else
      []
    end
  end

  def self.add body
    File.write COMMENT_FILE, (all << body).to_json
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
