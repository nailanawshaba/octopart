module Octopart
  class Part < Base

    class << self

      # Public: Find's a part for a given uid and returns an Octopart::Part or
      # an Array of Octopart::Part if multipled UIDs are given.
      #
      # args - Either a single Octopart UID, or multiple
      #
      # Examples
      #
      #   part = Octopart::Part.find('39619421')
      #
      #   parts = Octopart::Part.find(39619421, 29035751, 31119928)
      def find(*args)
        case args.length
        when 0
          raise ArgumentError.new("Please specify atleast 1 uid")
        when 1
          response = JSON.parse(self.get('parts/get', uid: args.first))
        else
          response = JSON.parse(self.get('parts/get_multi', uids: args.to_json))
        end
        self.build(response)
      end

      # Public: Search for parts that match the given query and returns an Array of 
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
        parts = response['results'].map { |part| part['item'] }
        self.build(parts)
      end

      # Public: Matches a manufacturer and manufacturer part number to an Octopart part UID
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

      # Public: Matches a list of part numbers to an Array of Octopart::Part
      #
      # lines - Either a single line or an array of lines
      #
      # Examples
      #
      #   Octopart::Part.bom(mpn: 'SN74LS240N')
      #
      #   Octopart::Part.bom([{mpn: 'SN74LS240N'}, {mpn: 'ATMEGA328P-PU'}])
      def bom(lines)
        lines = [lines] unless lines.is_a?(Array)
        response = JSON.parse(self.get('bom/match', lines: lines.to_json))
        response['results'].map { |line| self.build(line['items']) }
      end

      # Internal: Converts a Hash or an Array of Hash into an Octopart::Part or
      # an Array of Octopart::Part
      def build(object)
        if object.is_a?(Array)
          object.map { |obj| self.build(obj) }
        elsif object.is_a?(Hash)
          object.delete('__class__')
          object = Hashie::Mash.new(object)
          self.new.tap { |p| p.replace(object) }
        else
          raise "What is this? I don't even..."
        end
      end

    end

  end
end
