require 'sinatra/base'
require 'sinatra/respond_with'
require 'sinatra/json'
require 'time'
require 'json'

class Api < Sinatra::Base
  register Sinatra::RespondWith

  before do
    headers 'Access-Control-Allow-Origin' => '*',
      'Access-Control-Allow-Methods' => %w{ GET },
      'Access-Control-Allow-Headers' => %w{ Content-Type }
  end

  get '/xml_server/:doc' do
    doc  = params[:doc]
    sent = params[:s]

    respond_to do |f|
      f.xml { get_file(doc, sent) }
    end
  end

  get '/comments/:doc' do
    doc = params[:doc]
    json = File.read(File.join(DATA_PATH, 'comments', "#{doc}.json"))
    respond_to do |f|
      f.json { json }
    end
  end

  post '/comments/:doc' do
    res = JSON.parse(request.body.read)
    date = Time.utc(*Time.now.to_a).iso8601(3)
    user = "Robert"
    res['created_at'] = date
    res['updated_at'] = date
    res['user'] = user

    json(res)
  end

  get '/smyth/:doc' do
    File.read(File.join(DATA_PATH, 'smyth', params[:doc]))
  end

  post '/xml_server/:doc' do
    doc  = params[:doc]
    sent = params[:s]

    respond_to do |f|
      f.xml do
        if post_file(doc, sent, request.body.read)
          content_type :xml
          respond_with(200)
        end
      end
    end
  end

  options '/xml_server/:doc' do
  end

  DATA_PATH = File.expand_path("../../../data", __FILE__)

  def current_file(doc, sent)
    "#{DATA_PATH}/#{doc}.#{sent}.xml"
  end

  def get_file(doc, sent)
    File.read(current_file(doc, sent))
  end

  def post_file(doc, sent, xml)
    File.open(current_file(doc, sent), 'w')	do |f|
      f.puts(xml)
    end
    # Should do some error handling here
    true
  end
end
