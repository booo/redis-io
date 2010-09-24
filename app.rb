require "cuba"
require "haml"
require "rdiscount"
require "json"
require "compass"
require "open-uri"
require "digest/md5"
require "redis"

ROOT_PATH = File.expand_path(File.dirname(__FILE__))

require File.expand_path("reference", ROOT_PATH)

Encoding.default_external = Encoding::UTF_8

class Tilt::SassTemplate
  OPTIONS = Compass.sass_engine_options
  OPTIONS.merge!(style: :compact, line_comments: false)
  OPTIONS[:load_paths] << File.expand_path("views")

  def prepare
    @engine = ::Sass::Engine.new(data, sass_options.merge(OPTIONS))
  end
end

def redis
  $redis ||= Redis.connect(url: ENV["REDISTOGO_URL"])
end

class RedisTemplate < Tilt::RDiscountTemplate
  SECTIONS = {
    "complexity"  => "Time complexity",
    "description" => "Description",
    "examples"    => "Examples",
    "return"      => "Return value",
  }

  REPLY_TYPES = {
    "nil"         => "Null multi-bulk reply",
    "status"      => "Status code reply",
    "integer"     => "Integer reply",
    "bulk"        => "Bulk reply",
    "multi-bulk"  => "Multi-bulk reply"
  }

  def sections(source)
    source.gsub(/^\@(\w+)$/) do
      title = SECTIONS[$1]
      "#{title}\n---"
    end
  end

  def autolink_commands(source)
    source.gsub(/\B`([A-Z]+)`\B/) do
      name = $1
      command = commands[name]

      if command
        "[#{name}](/commands/#{name.downcase})"
      else
        name
      end
    end
  end

  def reply_types(source)
    source.gsub(/@(#{REPLY_TYPES.keys.join("|")})\-reply/) do
      type = $1
      "[#{REPLY_TYPES[type]}](/protocol##{type}-reply)"
    end
  end

  def preprocess(data)
    data = sections(data)
    data = autolink_commands(data)
    data = reply_types(data)
    data
  end

  def prepare
    @data = preprocess(@data)
    super
  end
end

Tilt.register "md", RedisTemplate

def commands
  $commands ||= Reference.new(JSON.parse(File.read("redis-doc/commands.json")))
end

Cuba.define do
  def render(path, locals = {})
    return unless File.expand_path(path).start_with?(ROOT_PATH)
    super(path, locals)
  end

  def haml(template, locals = {})
    layout render("views/#{template}.haml", locals)
  end

  def layout(content)
    render "views/layout.haml", content: content
  end

  on get, path("styles.css") do
    res.headers["Cache-Control"] = "public, max-age=29030400" if req.query_string =~ /[0-9]{10}/
    res.headers["Content-Type"] = "text/css; charset=utf-8"
    res.write render("views/styles.sass")
  end

  on get, path("") do
    json = redis.get("commits")

    @commits = json ? JSON.parse(json)["commits"] : []

    res.write haml("home")
  end

  on get, path("commands") do
    on segment do |name|
      @name = @title = name.upcase
      @command = commands[@name]

      res.write haml("commands/name")
    end

    on default do
      @commands = commands
      @title = "Command reference"

      res.write haml("commands")
    end
  end

  on get, path("clients") do
    @clients = JSON.parse(File.read("redis-doc/clients.json"))

    @clients_by_language = @clients.group_by { |name, info| info["language"] }.sort_by { |name, _| name.downcase }

    res.write haml("clients")
  end

  on get, path("topics") do
    on segment do |name|
      @name = name
      res.write haml("topics/name")
    end
  end

  on post do
    on path("commits"), param(:payload) do
      if redis.setnx("commits:refresh", 1)
        redis.pipelined do
          redis.set("commits", open("http://github.com/api/v2/json/commits/list/antirez/redis/master").read)
          redis.expire("commits:refresh", 90)
        end
      end
    end
  end
end
