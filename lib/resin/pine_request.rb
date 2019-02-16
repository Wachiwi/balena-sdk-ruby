require 'resin/request'
require 'json'

module Resin
  class PineRequest < Request
    def initalize
      super()

      @options.merge!(
          base_uri: @settings.get('pine_endpoint')
      )
    end

    def parse(req)
      JSON.parse(req.body)
    end
  end
end