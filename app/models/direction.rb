class Direction

  require 'open-uri'
  require 'json'
  attr_accessor :start, :destination

  def return_directions
    url = URI.encode("http://maps.googleapis.com/maps/api/geocode/json?address=#{self.start}&sensor=false")
    url_string_data = open(url).read
    url_json_data = JSON.parse(url_string_data)

    latitude = url_json_data['results'].first['geometry']['location']['lat']
    longitude = url_json_data['results'].first['geometry']['location']['lng']

    start_coordinates = [latitude, longitude]

    url = URI.encode("http://maps.googleapis.com/maps/api/geocode/json?address=#{self.destination}&sensor=false")
    url_string_data = open(url).read
    url_json_data = JSON.parse(url_string_data)

    latitude = url_json_data['results'].first['geometry']['location']['lat']
    longitude = url_json_data['results'].first['geometry']['location']['lng']

    destination_coordinates = [latitude, longitude]

    departure_time = Time.now.to_i

    url = URI.encode("http://maps.googleapis.com/maps/api/directions/json?origin=#{start_coordinates.first},#{start_coordinates.last}&destination=#{destination_coordinates.first},#{destination_coordinates.last}&sensor=false&mode=transit&departure_time=#{departure_time}&alternatives=true")
    url_string_data = open(url).read
    url_json_data = JSON.parse(url_string_data)

    routes_info_hash = Array.new
    url_json_data['routes'].each do |route|
      route_info_hash = Hash.new
      # route_info_hash['departure_time'] = route['legs'].first['departure_time']['text']
      route_info_hash['start_address'] = route['legs'].first['start_address']
      route_info_hash['distance'] = route['legs'].first['distance']['text']
      route_info_hash['duration'] = route['legs'].first['duration']['text']
      # route_info_hash['arrival_time'] = route['legs'].first['arrival_time']['text']
      route_info_hash['end_address'] = route['legs'].first['end_address']
      route_info_hash['route'] = Array.new
      route['legs'].first['steps'].each do |step|
        step_info = Hash.new
        step_info['distance'] = step['distance']['text']
        step_info['duration'] = step['duration']['text']
        step_info['instruction'] = step['html_instructions']
        route_info_hash['route'] << step_info
      end
      routes_info_hash << route_info_hash
    end
    return routes_info_hash
  end
end

# TEST 1
# direction = Direction.new
# direction.start = 'Merchandise Mart Chicago'
# direction.destination = 'Chicago OTC'
# puts direction.return_directions

# TEST 2
# direction = Direction.new
# direction.start = 'Chicago'
# direction.destination = 'Denver'
# puts direction.return_directions
