#!/usr/bin/env ruby

require "./app"
require "erb"

# Explicitly allow certain groups (don't allow "server", "connection" and
# "pubsub" commands by default).
ALLOW_GROUPS = %w(generic hash list set sorted_set string).freeze

# Override ALLOW_GROUPS for some commands.
ALLOW_COMMANDS = %w(ping echo info lastsave).freeze

# Explicitly deny some commands.
DENY_COMMANDS = %w(blpop brpop brpoplpush select move randomkey).freeze

def allowed_commands
  @allowed_commands ||= commands.select do |cmd|
    !DENY_COMMANDS.include?(cmd.name.downcase) &&
      (ALLOW_COMMANDS.include?(cmd.name.downcase) ||
       ALLOW_GROUPS.include?(cmd.group))
  end
end

def patterns
  @patterns ||= Hash[*allowed_commands.map do |cmd|
    args = cmd.arguments
    if args.empty?
      pattern = []
    elsif args[0].type == ["key"] && !args[0].multiple? &&
      args[1..-1].none? { |arg| arg.type.include?("key") }
      # Only namespace the first argument
      pattern = [:first]
    elsif args.all? { |arg| arg.type == ["key"] }
      # Namespace all arguments
      pattern = [:all]
    elsif args.all? { |arg| !arg.multiple? && !arg.optional? && arg.type.size == 1 }
      # Constant number of arguments can be zipped
      pattern = [:zip, args.map { |arg| :key if arg.type == ["key"] } ]
    elsif args.size == 1 && args[0].multiple? && args[0].type.include?("key")
      # Single variadic argument with key can be zipped
      pattern = [:zip, args[0].type.map { |type| :key if type == "key" } ]
    else
      # Non-standard
      pattern = [:custom]
    end

    [cmd.name.downcase, pattern]
  end.compact.flatten(1)]
end

by_group = allowed_commands.group_by(&:group).sort.map do |group,commands|
  lines = commands.sort_by(&:name).map do |cmd|
    %{"%s" => %s} % [cmd.name.downcase, patterns[cmd.name.downcase].inspect]
  end

  [group, lines]
end

def file
  __FILE__
end

template = <<-TPL
# This file is automatically generated by:
#   <%= file %>.
#
# Do not edit.
#

module Interactive
  COMMANDS = {
  <%- by_group.each do |group,commands| -%>
    # <%= group %>
    <%- commands.each do |command| -%>
    <%= command %>,
    <%- end %>
  <%- end -%>
  }.freeze
end

TPL

STDOUT.puts ERB.new(template, 0, "%<>-").result(binding)

