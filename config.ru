require 'rest-client'
require 'pretty-xml'

class XmlTemplate
  def initialize(xml)
    @xml = xml
  end
  
  def to_s
    <<-HTML
    <html>
      <meta charset="UTF-8">
      <title>Prettysource</title>
      <link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.4.0/styles/default.min.css">
      <script src="//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.4.0/highlight.min.js"></script>
      <body>
        <pre>
          <code class="xml">
            #{ CGI.escapeHTML(@xml) }
          </code>
        </pre>
      </body>
      <script>hljs.initHighlightingOnLoad();</script>
    </html>
    HTML
  end
end

class PrettysourceApp
  def call(env)
    request = Rack::Request.new(env)
    
    if request.params['url']
      source_response = RestClient.get(request.params['url'])
      
      if source_response.code == 200
        output = PrettyXML.write(source_response.body)
      
        [200, {
          'Content-Type'=>'text/html',
          'Access-Control-Allow-Origin' => "*"
          }, [XmlTemplate.new(output).to_s]]
      else
        [400, {'Content-Type'=>'text/html'}, StringIO.new("Could not open #{ request.params['url'] }\n#{ source_response.inspect }")]
      end
    else
      [404, {'Content-Type'=>'text/html'}, StringIO.new("?url=xxx Parameter missing!")]
    end
  end
end

run PrettysourceApp.new
