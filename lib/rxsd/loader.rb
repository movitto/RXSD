# RXSD resource loader
#
# Copyright (C) 2010 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

require 'uri'      # use uri to parse sources
require 'net/http' # get http:// based resources

module RXSD

# loads resources from uris
class Loader

 # loads and return text resource from specified source uri
 def self.load(source_uri)
    Logger.info "loading resource from uri #{source_uri}"
    data = nil
    uri = URI.parse(source_uri)
    if uri.scheme == "file" || uri.scheme.nil?
       data = File.read_all uri.path
    elsif uri.scheme == "http"
       data = Net::HTTP.get_response(uri.host, uri.path).body
    # elsif FIXME support other uri types
    end

    return data

    rescue URI::InvalidURIError
       raise Exceptions::InvalidResourceUri
 end

end # class loader
end # module RXSD
