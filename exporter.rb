# REQUIREMENTS
require 'prometheus_exporter'
require 'prometheus_exporter/server'
# client allows instrumentation to send info to server
require 'prometheus_exporter/client'
require 'prometheus_exporter/instrumentation'
require 'net/http'
require 'openssl'
require 'json'
require 'yaml'


#VARIABLES
configuration   = YAML.load_file('conf/exporter.yml')
bind            = configuration['exporter']['bind'] || '0.0.0.0'
port            = configuration['exporter']['port'] || 12346
interval        = configuration['exporter']['bind'] || 60
verbose         = configuration['exporter']['verbose'] || false
components      = configuration['components'] || []

# bind is the address, on which the webserver will listen
# port is the port that will provide the /metrics route
server = PrometheusExporter::Server::WebServer.new bind: bind , port: port , verbose: verbose
server.start
#Instance a client and metrics to collect 
client =  PrometheusExporter::LocalClient.new(collector: server.collector)


while true

    components.each do |component|

      component

    end

    sleep interval.to_i

end