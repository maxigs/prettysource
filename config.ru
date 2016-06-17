require 'rest-client'
require 'pretty-xml'

class PrettysourceApp
  def call(env)
    request = Rack::Request.new(env)
    
    if request.params['url']
      source_response = RestClient.get(request.params['url'])
      
      if source_response.code == 200
        output = PrettyXML.write(source_response.body)
      
        [200, {'Content-Type'=>'text/xml'}, StringIO.new(output)]
      else
        [400, {'Content-Type'=>'text/plain'}, StringIO.new("Could not open #{ request.params['url'] }\n#{ source_response.inspect }")]
      end
    else
      [404, {'Content-Type'=>'text/plain'}, StringIO.new("?url=xxx Parameter missing!")]
    end
  end
end

run PrettysourceApp.new
