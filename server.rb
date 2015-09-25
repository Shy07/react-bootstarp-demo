
require 'webrick'
require 'json'

port = ENV['PORT'].nil? ? 3000 : ENV['PORT'].to_i

puts "Server started: http://localhost:#{port}/"

root = File.expand_path './'
server = WEBrick::HTTPServer.new Port: port, DocumentRoot: root

json =<<__TEXT__
[
    {
        "time": "1443161204904"
    },
    {
        "text": "hello world",
        "time": "1443161204904",
        "sender": "Shy07",
        "color": "0"
    }
]
__TEXT__

$messages = JSON.parse json
server.mount_proc '/messages.json' do |req, res|
  if req.request_method == 'POST'
    message = {}
    req.query.each do |key, value|
      message[key] = value.force_encoding 'UTF-8'
    end
    $messages[0]['time'] = message['time']
    $messages << message
  end
  res['Content-Type'] = 'application/json'
  res['Cache-Control'] = 'no-cache'
  res.body = JSON.generate $messages
end

trap('INT') { server.shutdown }

server.start
