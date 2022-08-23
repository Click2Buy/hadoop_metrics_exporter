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



#METHODS
def underscore name
  name.gsub(/::/, '/').gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').gsub(/([a-z\d])([A-Z])/,'\1_\2').tr("-", "_").downcase
end

#VARIABLES
configuration   = YAML.load_file('conf/exporter.yml')
bind            = configuration['exporter']['bind'] || '0.0.0.0'
port            = configuration['exporter']['port'] || 7629
interval        = configuration['exporter']['interval'] || 60
verbose         = configuration['exporter']['verbose'] || false
components      = configuration['components'] || []
default_metrics =  YAML.load_file('metrics/metrics.yml')
values          = {}
# bind is the address, on which the webserver will listen
# port is the port that will provide the /metrics route
server = PrometheusExporter::Server::WebServer.new bind: bind , port: port , verbose: verbose
server.start
#Instance a client and metrics to collect 
client =  PrometheusExporter::LocalClient.new(collector: server.collector)

# Filter and keep metrics to fill
metrics = default_metrics.select {|k, v| components.keys.include? k}
components.each do |component|
  if component.last['include']
    metrics[component.first].select!{|k, v| component.last['include'].include? k}
  end
end

#Instanciate metrics
metrics.each do |component|
  component_name  = component.first
  component.last.each do |metric| 
    metric_name     = metric.first
    formatted_key   = underscore(metric_name)
    values["#{component_name}_#{formatted_key}"]  = client.register( metrics[component_name][metric_name]['metricType'].to_sym, "#{component_name}_#{formatted_key}", metrics[component_name][metric_name]['desc']) 
  end
end

#Set metrics
while true

  components.each do |component|
    name = component.first
    uri = URI(component.last['url'])

    Net::HTTP.start(uri.host, uri.port,
    :use_ssl => uri.scheme == 'https', 
    :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
      request = Net::HTTP::Get.new uri.request_uri
      
      if component.last['basic_auth']
        request.basic_auth component.last['basic_auth']['username'], component.last['basic_auth']['password']
      end

      response      = http.request request # Net::HTTPResponse object
      result        = JSON.parse(response.body)
      if name == 'yarn'
        result['clusterMetrics'].select{|k, v| metrics[name].keys.include? k}.each do |metric|
          formatted_key          = underscore( metric.first )
          values["#{name}_#{formatted_key}"].observe( metric.last )
        end
      else 
        result["beans"].map{ |obj| obj.select{ |k,v| metrics[name].keys.include? k}}.reject(&:empty?).reduce( Hash.new, :merge ).each do |metric|
          formatted_key          = underscore( metric.first )
          values["#{name}_#{formatted_key}"].observe( metric.last )
        end
      end
    end
  end
  
  sleep interval

end