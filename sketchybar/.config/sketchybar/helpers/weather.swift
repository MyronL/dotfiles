import WeatherKit
import CoreLocation

let service = WeatherService.shared
let location = CLLocation(latitude: 37.3479, longitude: -122.0351)

let currentWeather = try await service.weather(for: location, including: .current)
let dailyForecast = try await service.weather(for: location, including: .daily)

let icon: String
let color: String
switch currentWeather.condition {
case .clear, .hot:
    icon = "󰖙"
    color = "yellow"
case .mostlyClear:
    icon = "󰖙"
    color = "yellow"
case .partlyCloudy:
    icon = "󰖐"
    color = "peach"
case .mostlyCloudy:
    icon = "󰖐"
    color = "overlay1"
case .cloudy:
    icon = "󰖞"
    color = "overlay1"
case .rain, .heavyRain, .freezingRain:
    icon = "󰖖"
    color = "blue"
case .drizzle, .freezingDrizzle:
    icon = "󰖖"
    color = "sapphire"
case .snow, .heavySnow, .flurries:
    icon = "󰖘"
    color = "sky"
case .sleet, .hail:
    icon = "󰖘"
    color = "sky"
case .thunderstorms, .strongStorms, .isolatedThunderstorms, .scatteredThunderstorms:
    icon = "󰖝"
    color = "mauve"
case .foggy, .haze, .smoky:
    icon = "󰖑"
    color = "overlay2"
case .windy, .breezy:
    icon = "󰖝"
    color = "teal"
case .blizzard, .blowingSnow:
    icon = "󰖘"
    color = "sky"
default:
    icon = "󰔏"
    color = "text"
}

let temp = Int(currentWeather.temperature.converted(to: .celsius).value)
let humidity = Int(currentWeather.humidity * 100)
let condition = "\(currentWeather.condition)".replacingOccurrences(of: "([a-z])([A-Z])", with: "$1 $2", options: .regularExpression).capitalized
let feelsLike = Int(currentWeather.apparentTemperature.converted(to: .celsius).value)

var highTemp = "—"
var lowTemp = "—"
if let today = dailyForecast.forecast.first {
    highTemp = "\(Int(today.highTemperature.converted(to: .celsius).value))°C"
    lowTemp = "\(Int(today.lowTemperature.converted(to: .celsius).value))°C"
}

print("\(icon)|\(temp)°C|\(color)|\(condition)|\(humidity)%|\(feelsLike)°C|\(highTemp)|\(lowTemp)")
