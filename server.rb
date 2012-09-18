#!/usr/bin/env ruby
$:<< '../lib' << 'lib'

require 'bundler/setup'
Bundler.require

require 'goliath/websocket'

class Routes < Goliath::WebSocket
	# render templated files from ./views
	include Goliath::Rack::Templates

	# render static files from ./public
	use(
    Rack::Static,
		:root => Goliath::Application.app_path('public'),
		:urls => ['/javascripts'])

  def on_open(env)
    env.logger.info("CHAT OPEN")
    env['subscription'] = env.channel.subscribe { |m| env.stream_send(m) }
  end

  def on_message(env, msg)
    env.logger.info("CHAT MESSAGE: #{msg}")
    env.channel << msg
  end

  def on_close(env)
    env.logger.info("CHAT CLOSED")
    env.channel.unsubscribe(env['subscription'])
  end

  def on_error(env, error)
    env.logger.error error
  end

  def response(env)
    if env['REQUEST_PATH'] == '/chat'
      super(env)
    else
      [200, {}, erb(:index)]
    end
  end
end
