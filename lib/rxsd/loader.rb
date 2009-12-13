# RXSD resource loader 
#
# Copyright (C) 2009 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

require 'uri' # use uri to parse sources

module RXSD

# loads resources from uris
class Loader

 # loads and return text resource from specified source uri
 def self.load(source_uri)
    Logger.info "loading resource from uri #{source_uri}" 
    data = nil
    uri = URI.parse(source_uri)
    if uri.scheme == "file"
       data = File.read_all uri.path
    # elsif FIXME support other uri types
    end

    return data

    rescue URI::InvalidURIError
       raise Exceptions::InvalidResourceUri
 end

end # class loader
end # module RXSD
