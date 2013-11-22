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
      route_info_hash['start_address'] = route['legs'].first['start_address']
      route_info_hash['distance'] = route['legs'].first['distance']['text']
      route_info_hash['duration'] = route['legs'].first['duration']['text']
      route_info_hash['end_address'] = route['legs'].first['end_address']
      route_info_hash['route'] = Array.new
      route['legs'].first['steps'].each do |step|
        if step['travel_mode'] == 'WALKING'
          step_info = Hash.new
          step_info['travel_mode'] = step['travel_mode']
          step_info['distance'] = step['distance']['text']
          step_info['duration'] = step['duration']['text']
          step_info['instruction'] = step['html_instructions']
          route_info_hash['route'] << step_info
        elsif step['travel_mode'] == 'TRANSIT'
          if step['transit_details']['line']['vehicle']['type'] == 'BUS'
            step_info = Hash.new
            step_info['travel_mode'] = step['travel_mode']
            step_info['distance'] = step['distance']['text']
            step_info['duration'] = step['duration']['text']
            step_info['instruction'] = step['html_instructions']
            step_info['vehicle_type'] = step['transit_details']['line']['vehicle']['type']
            step_info['vehicle_short_name'] = step['transit_details']['line']['short_name']
            step_info['departure_stop_name'] = step['transit_details']['departure_stop']['name']
            step_info['departure_time'] = step['transit_details']['departure_time']['text']
            step_info['arrival_stop_name'] = step['transit_details']['arrival_stop']['name']
            step_info['arrival_time'] = step['transit_details']['arrival_time']['text']
            route_info_hash['route'] << step_info
          elsif step['transit_details']['line']['vehicle']['type'] == 'SUBWAY'
            step_info = Hash.new
            step_info['travel_mode'] = step['travel_mode']
            step_info['distance'] = step['distance']['text']
            step_info['duration'] = step['duration']['text']
            step_info['instruction'] = step['html_instructions']
            step_info['vehicle_type'] = step['transit_details']['line']['vehicle']['type']
            step_info['train_line'] = step['transit_details']['line']['name']
            step_info['train_line_color'] = step['transit_details']['line']['color']
            step_info['train_line_info'] = step['transit_details']['line']['url']
            step_info['departure_stop_name'] = step['transit_details']['departure_stop']['name']
            step_info['departure_time'] = step['transit_details']['departure_time']['text']
            step_info['arrival_stop_name'] = step['transit_details']['arrival_stop']['name']
            step_info['arrival_time'] = step['transit_details']['arrival_time']['text']
            route_info_hash['route'] << step_info
          end
        end
      end
      routes_info_hash << route_info_hash
    end
    return routes_info_hash
  end

  def accesccible?
    accessible_array = %w[Kimball, Kedzie, Francisco, Rockwell, Western, Damen, Montrose, Irving Park, Addison, Paulina, Southport, Belmont, Wellington, Diversey, Washington/Wells, Harold Washington Library-State/Van Buren, Clark/Lake, O’Hare, Rosemont, Cumberland, Harlem (O'Hare), Jefferson Park, Logan Square, Western (O’Hare), Jackson, UIC-Halsted, Illinois Medical District (Damen Entrance), Kedzie-Homan, Forest Park, Ashland/63rd, Cottage Grove, King Drive, Garfield, 51st, 47th, 43rd, Indiana, 35th-Bronzeville-IIT, Roosevelt, Clinton, Morgan, Ashland, California, Conservatory-Central Park Drive, Pulaski, Cicero, Laramie, Harlem/Lake (via Marion entrance), Midway, 35/Archer, Halsted, 54th/Cermak, Kostner, Central Park, 18th, Polk, Linden, Davis, Howard, Armitage, Sedgwick, Merchandise Mart, Loyola, Granville, Fullerton, Chicago, Grand, Lake, Cermak-Chinatown, Sox-35th, 63rd, 69th, 79th, , 87th, 95th/Dan Ryan, Oakton-Skokie, Dempster-Skokie]

    routes = self.return_directions
    counter = 0
    routes.each do |route|
        if route['vehicle_type'] = 'SUBWAY'
          if !(accessible_array.include?(route['arrival_stop_name']) && accessible_array.include?(route['arrival_stop_name']))
            routes.pop(counter)
          end
        end
        counter += 1
    end
    return routes
  end
end
