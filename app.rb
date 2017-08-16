require 'cuba'
require 'cuba/render'
require 'erb'

FileUtils.mkdir_p '/var/tmp/tasks', verbose: true

Cuba.plugin Cuba::Render

Cuba.define do
  on root do
    on get do
      render 'main'
    end
    on post do
      params = req.params
      Task.create params['name'], params['description']
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
    Dir["/var/tmp/tasks/*"].map do |task_file|
      new File.basename(task_file), File.read(task_file)
    end
  end

  def save
    File.write("/var/tmp/tasks/#{ name }", description.to_s)
  end
end
