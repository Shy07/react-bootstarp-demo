#encoding: utf-8

$LOAD_PATH << "#{__FILE__}/../lib"

require 'sinatra'
require 'json'

set :public_folder, File.dirname(__FILE__)

HTML =<<__TEXT__
<!DOCTYPE html>
<html>
  <head>
    <title>Hello React!</title>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="Shy07">
    <link rel="stylesheet" href="http://cdn.bootcss.com/bootstrap/3.3.5/css/bootstrap.min.css" type="text/css" />
    <link rel="stylesheet" href="http://cdn.bootcss.com/font-awesome/4.4.0/css/font-awesome.min.css" type="text/css">
    <link rel="stylesheet" href="http://cdn.bootcss.com/startbootstrap-sb-admin-2/1.0.7/css/sb-admin-2.min.css" type="text/css">
    <link rel="stylesheet" href="css/chat-demo.css" type="text/css" />
  </head>
  <body>
    <div id="content" style="margin:8px auto;max-width:640px;" >
    </div>

    <script src="http://cdn.bootcss.com/react/0.13.3/react.min.js"></script>
    <script src="http://cdn.bootcss.com/jquery/2.1.4/jquery.min.js"></script>
    <script src="http://cdn.bootcss.com/bootstrap/3.3.5/js/bootstrap.min.js"></script>

    <script src="build/application.js" ></script>
  </body>
</html>
__TEXT__

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

get '/' do
  HTML
end

get '/messages.json' do
  headers 'Content-Type' => 'application/json'
  headers 'Cache-Control' => 'no-cache'
  JSON.generate $messages
end

post '/messages.json' do
  message = {}
  params.each do |key, value|
    message[key] = value.force_encoding 'UTF-8'
  end
  $messages[0]['time'] = message['time']
  $messages << message
end
