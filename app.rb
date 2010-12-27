ROOT_PATH = File.expand_path(File.dirname(__FILE__))

require "cuba"
require "haml"
require "rdiscount"
require "json"
require "compass"
require "open-uri"
require "digest/md5"
require "shellwords"
require "redis"
require "ohm"
require "rack/static"
require "nokogiri"

require File.expand_path("lib/reference", ROOT_PATH)
require File.expand_path("lib/template", ROOT_PATH)

require File.expand_path("lib/try/session", ROOT_PATH)
require File.expand_path("lib/try/commands", ROOT_PATH)

Encoding.default_external = Encoding::UTF_8

module Kernel
private

  def documentation_path
    @documentation_path ||= ENV["REDIS_DOC"] || "redis-doc"
  end

  def commands
    @commands ||= Reference.new(JSON.parse(File.read(documentation_path + "/commands.json")))
  end

  def new_redis_connection
    Redis.connect(url: ENV["REDISTOGO_URL"])
  end

  def redis
    @redis ||= new_redis_connection
  end

  def redis_versions
    @redis_versions ||= redis.hgetall("versions")
  end

  def user
    @user ||= User[session[:user]]
  end

  def try_commands
    @try_commands ||= ::Try::Commands.new(commands)
  end

  def related_topics_for(command)
    # For now this is a quick and dirty way of figuring out related topics.

    path = "#{documentation_path}/topics/#{command.group}.md"

    return [] unless File.exist?(path)

    _, title = topic(path)

    [[title, "/topics/#{command.group}"]]
  end

  def related_commands_for(group)
    commands.select do |command|
      command.group == group
    end.sort_by(&:name)
  end

  def update_redis_versions
    tags = `git ls-remote -t https://github.com/antirez/redis.git`

    versions = tags.scan(%r{refs/tags/(v?(?:\d\.?)*\-(?:stable|rc\w+|alpha\w+))}).flatten.uniq

    stable, development = versions.partition { |v| v =~ /^v/ }

    redis.hmset(
      "versions",
      "stable", stable.sort.last,
      "development", development.sort.last
    )
  end

  def clean_version(version)
    version[/((?:\d\.?)+)/, 1]
  end

  def version_name(tag)
    tag[/v?(.*)/, 1].sub(/\-stable$/, "")
  end
end

Ohm.redis = redis

Cuba.use Rack::Static, urls: ["/images"], root: File.join(ROOT_PATH, "public")

Cuba.define do
  def render(path, locals = {})
    expanded = File.expand_path(path)
    if expanded.start_with?(ROOT_PATH)
      super(path, locals)
    elsif expanded.start_with?(documentation_path)
      data = super(path, locals)
      filter_session_examples(data)
    end
  end

  # Setup a new cli session for every <pre><code> with @cli
  def filter_session_examples(data)
    namespace = Digest::MD5.hexdigest(rand(2**32).to_s)
    data.gsub %r{<pre><code>(.*?)</code></pre>}m do |match|
      lines = $1.split(/\n+/m).map(&:strip)
      if lines.shift == "@cli"
        session = ::Try::Session.new(namespace)
        lines = lines.map { |line| Shellwords.shellwords line }
        render("views/example.haml", session: session, lines: lines)
      else
        match
      end
    end
  end

  def haml(template, locals = {})
    layout(partial(template, locals))
  end

  def partial(template, locals = {})
    render("views/#{template}.haml", locals)
  end

  def layout(content)
    partial("layout", content: content)
  end

  def topic(template)
    body = render(template)
    title = body[%r{<h1>(.+?)</h1>}, 1] # Nokogiri may be overkill

    return body, title
  end

  def gravatar_hash(email)
    Digest::MD5.hexdigest(email)
  end

  on get, path("") do
    res.write haml("home")
  end

  on get, path("buzz") do
    res.write haml("buzz")
  end

  %w[download community documentation].each do |topic|
    on get, path(topic) do
      @body, @title = topic("views/#{topic}.md")
      res.write haml("topics/name")
    end
  end

  on get, path("commands") do
    on segment do |name|
      @name = @title = name.upcase.gsub("-", " ")
      @command = commands[@name]
      @related_commands = related_commands_for(@command.group) - [@command]
      @related_topics = related_topics_for(@command)

      res.write haml("commands/name")
    end

    on default do
      @commands = commands
      @title = "Command reference"

      res.write haml("commands")
    end
  end

  on post, path("session"), path(/[0-9a-f]{32}/i) do |_, _, id|
    session = ::Try::Session.new(id)
    args = Shellwords.shellwords req.params["command"].to_s
    res.write session.run(args) if !args.empty?
  end

  on get, path("clients") do
    @clients = JSON.parse(File.read(documentation_path + "/clients.json"))

    @clients_by_language = @clients.group_by { |name, info| info["language"] }.sort_by { |name, _| name.downcase }

    res.write haml("clients")
  end

  on get, path("topics"), segment do |_, _, name|
    path = "/topics/#{name}.md"

    if File.exist?(File.join(documentation_path, path))
      @css = [:topics, name]
      @body, @title = topic(File.join(documentation_path, path))
      @related_commands = related_commands_for(name)

      res.write haml("topics/name")
    else
      res.status = 404
      res.write haml("404", path: path)
    end
  end

  on get, path(/\w+\.json/) do |_, file|
    res.headers["Cache-Control"] = "public, max-age=29030400" if req.query_string =~ /[0-9]{10}/
    res.headers["Content-Type"] = "application/json;charset=UTF-8"
    res.write File.read(documentation_path + "/#{file}")
  end

  on get, path("styles.css") do
    res.headers["Cache-Control"] = "public, max-age=29030400" if req.query_string =~ /[0-9]{10}/
    res.headers["Content-Type"] = "text/css; charset=utf-8"
    res.write render("views/styles.sass")
  end

  on get, path("app.js") do |_, file|
    res.headers["Cache-Control"] = "public, max-age=29030400" if req.query_string =~ /[0-9]{10}/
    res.headers["Content-Type"] = "text/javascript; charset=utf-8"
    res.write File.read("views/app.js")
  end

  on post, path("commits"), param("payload") do
    update_redis_versions
  end
end
