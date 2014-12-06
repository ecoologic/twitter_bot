#!/usr/bin/env ruby

require 'oauth'
require 'yaml'
require 'ostruct'
require 'pry'

class Connector
  def call
    description
    get_pin
    write_access_config

    puts "Now you can run the bot typing bot.rb"
  end

  private
  attr_accessor :pin, :access_token

  def description
    puts "## Config Twitter Bot ##"
    puts "Configure which tweets to retweet through whitelist.txt and blacklist.txt\n"
  end

  def get_pin
    system "open #{oauth_request_token.authorize_url}"
    puts "We opened a browser page for you."
    puts "Please authorize the app and paste here the pin number you'll see (eg: 5478717)"
    self.access_token = oauth_request_token.get_access_token(oauth_verifier: gets.chomp)
  end

  def write_access_config
    File.open 'config/access.yml', 'w' do |file|
      yaml = { token: access_token.token, secret: access_token.secret }.to_yaml
      file.write(yaml)
    end
    # YAML.load_file 'config/access.yml'
  end

  def oauth_config
    @oauth_config ||= YAML.load_file('config/oauth.yml')
  end

  def consumer
    @consumer ||= OAuth::Consumer.new(
      oauth_config['key'],
      oauth_config['secret'],
      site:               'https://twitter.com',
      request_token_path: '/oauth/request_token',
      access_token_path:  '/oauth/access_token',
      authorize_path:     '/oauth/authorize'
    )
  end

  def oauth_request_token
    @oauth_request_token ||= consumer.get_request_token
  end
end

Connector.new.()
