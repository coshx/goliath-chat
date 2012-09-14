require 'goliath'
require 'tilt'
require 'json'
require 'haml'
require 'pry'
require 'pry-nav'

class Chat
  attr_accessor :clients

  def initialize
    @clients = []
    @most_recent_message = ""
  end

  def fiber
    @fiber ||= Fiber.new {
      loop do
        response = @most_recent_message
        @most_recent_message = ""
        Fiber.yield response
      end
    }
  end

  def send(message)
     @most_recent_message = message
  end

end

class ReadMessages < Goliath::API
  def response(env)
    $chat.clients << env
    if !$running
      fiber = $chat.fiber
      EM.add_periodic_timer(0.1) do
        data = fiber.resume
        # must have two \n at the end
        if data.length > 0
          puts "Sending: #{data}"
          $chat.clients.each do |c|
            c.stream_send("data: #{data.to_json}\n\n")
          end
        end
      end
      $running = true
    end
		streaming_response(200, {'Content-Type' => 'text/event-stream'})
  end
end

class WriteMessage < Goliath::API
  def response(env)
    [204, {}, "OK"]
  end
end

class Routes < Goliath::API
	# render templated files from ./views
	include Goliath::Rack::Templates

	# render static files from ./public
	use(
    Rack::Static,
		:root => Goliath::Application.app_path('public'),
		:urls => ['/javascripts'])
		# :urls => ['/favicon.ico', '/stylesheets', '/javascripts', '/images'])

  post '/chat', WriteMessage do
    $chat.send(params[:msg])
  end
	get '/chat', ReadMessages

	def response(env)
		[200, {}, haml(:index)]
	end
end

$chat = Chat.new
$running = false
