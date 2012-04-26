module Octopart
  class Part < Base

    class << self

      # Find's a part for a given uid and returns an Octopart::Part
      #
      # uid - An Octopart part id
      #
      # Examples
      #
      #   part = Octopart::Part.find('39619421')
      def find(uid)
        response = JSON.parse(self.get('parts/get', uid: uid))
        self.build(response)
      end

      # Search for parts that match the given query and returns an Array of 
      # Octopart::Part
      #
      # query   - A search term
      # options - A set of options (default: {})
      #           :start         - Ordinal position of first result. First position is 0.
      #                            Default is 0. Maximum is 1000.
      #           :limit         - Number of results to return. Default is 10. Maximum is 100.
      #           :filters       - JSON encoded list of (fieldname,values) pairs
      #           :rangedfilters - JSON encoded list of (fieldname, min/max values) pairs,
      #                            using null as wildcard.
      #           :sortby        - JSON encoded list of (fieldname,sort-order) pairs. Default is
      #                            [["score","desc"]]
      #
      # Examples
      #
      #   parts = Octopart::Part.search('resistor', limit: 10)
      def search(query, options = {})
        params = options.merge(q: query)
        response = JSON.parse(self.get('parts/search', params))
        parts = []
        response['results'].each do |part|
          parts << part['item']
        end
        self.build(parts)
      end

      # Matches a manufacturer and manufacturer part number to an Octopart part UID
      #
      # manufacturer - Manufacturer name (eg. Texas Instruments)
      # mpn          - Manufacturer part number
      #
      # Examples
      #
      #   uid = Octopart::Part.match('texas instruments', 'SN74LS240N')
      #
      #   part = Octopart::Part.find(uid)
      def match(manufacturer, mpn)
        params = { manufacturer_name: manufacturer, mpn: mpn }
        response = JSON.parse(self.get('parts/match', params))
        case response.length
        when 1
          response.first.first
        end
      end

      # Matches a list of part numbers to an Array of Octopart::Part
      def bom(options = nil)
        
      end

      def build(object)
        if object.is_a?(Array)
          parts = []
          object.each do |obj|
            parts << self.build_single(obj)
          end
          parts
        elsif object.is_a?(Hash)
          self.build_single(object)
        else
          raise "What is this? I don't even..."
        end
      end

      def build_single(object)
        object = Hashie::Mash.new(object)
        part = self.new
        part.replace(object)
        part
      end

    end

  end
end
