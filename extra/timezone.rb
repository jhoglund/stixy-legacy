require 'time'
[["A", "Alpha Time Zone Military UTC", " + 1 hour"],
["ACDT", "Australian Central Daylight Time Australia UTC", " + 10:30 hours"],
["ACST", "Australian Central Standard Time Australia UTC", " + 9:30 hours"],
["ADT", "Atlantic Daylight Time North America UTC", " - 3 hours"],
["AEDT", "Australian Eastern Daylight Time or Australian Eastern Summer Time Australia UTC", " + 11 hours"],
["AEST", "Australian Eastern Standard Time Australia UTC", " + 10 hours"],
["AKDT", "Alaska Daylight Time North America UTC", " - 8 hours"],
["AKST", "Alaska Standard Time North America UTC", " - 9 hours"],
["AST", "Atlantic Standard Time North America UTC", " - 4 hours"],
["AWDT", "Australian Western Daylight Time Australia UTC", " + 9 hours"],
["AWST", "Australian Western Standard Time Australia UTC", " + 8 hours"],
["B", "Bravo Time Zone Military UTC", " + 2 hours"],
["BST", "British Summer Time Europe UTC", " + 1 hour"],
["C", "Charlie Time Zone Military UTC", " + 3 hours"],
["CDT", "Central Daylight Time Australia UTC", " + 10:30 hours"],
["CDT", "Central Daylight Time North America UTC", " - 5 hours"],
["CEDT", "Central European Daylight Time Europe UTC", " + 2 hours"],
["CEST", "Central European Summer Time Europe UTC", " + 2 hours"],
["CET", "Central European Time Europe UTC", " + 1 hour"],
["CST", "Central Summer Time Australia UTC", " + 10:30 hours"],
["CST", "Central Standard Time Australia UTC", " + 9:30 hours"],
["CST", "Central Standard Time North America UTC", " - 6 hours"],
["CXT", "Christmas Island Time Australia UTC", " + 7 hours"],
["D", "Delta Time Zone Military UTC", " + 4 hours"],
["E", "Echo Time Zone Military UTC", " + 5 hours"],
["EDT", "Eastern Daylight Time Australia UTC", " + 11 hours"],
["EDT", "Eastern Daylight Time North America UTC", " - 4 hours"],
["EEDT", "Eastern European Daylight Time Europe UTC", " + 3 hours"],
["EEST", "Eastern European Summer Time Europe UTC", " + 3 hours"],
["EET", "Eastern European Time Europe UTC", " + 2 hours"],
["EST", "Eastern Summer Time Australia UTC", " + 11 hours"],
["EST", "Eastern Standard Time Australia UTC", " + 10 hours"],
["EST", "Eastern Standard Time North America UTC", " - 5 hours"],
["F", "Foxtrot Time Zone Military UTC", " + 6 hours"],
["G", "Golf Time Zone Military UTC", " + 7 hours"],
["GMT", "Greenwich Mean Time Europe UTC", " + 0 hour"],
["H", "Hotel Time Zone Military UTC", " + 8 hours"],
["HAA", "Heure Avancée de l'Atlantique North America UTC", " - 3 hours"],
["HAC", "Heure Avancée du Centre North America UTC", " - 5 hours"],
["HADT", "Hawaii-Aleutian Daylight Time North America UTC", " - 9 hours"],
["HAE", "Heure Avancée de l'Est North America UTC", " - 4 hours"],
["HAP", "Heure Avancée du Pacifique North America UTC", " - 7 hours"],
["HAR", "Heure Avancée des Rocheuses North America UTC", " - 6 hours"],
["HAST", "Hawaii-Aleutian Standard Time North America UTC", " - 10 hours"],
["HAT", "Heure Avancée de Terre-Neuve North America UTC", " - 2:30 hours"],
["HAY", "Heure Avancée du Yukon North America UTC", " - 8 hours"],
["HNA", "Heure Normale de l'Atlantique North America UTC", " - 4 hours"],
["HNC", "Heure Normale du Centre North America UTC", " - 6 hours"],
["HNE", "Heure Normale de l'Est North America UTC", " - 5 hours"],
["HNP", "Heure Normale du Pacifique North America UTC", " - 8 hours"],
["HNR", "Heure Normale des Rocheuses North America UTC", " - 7 hours"],
["HNT", "Heure Normale de Terre-Neuve North America UTC", " - 3:30 hours"],
["HNY", "Heure Normale du Yukon North America UTC", " - 9 hours"],
["I", "India Time Zone Military UTC", " + 9 hours"],
["IST", "Irish Summer Time Europe UTC", " + 1 hour"],
["K", "Kilo Time Zone Military UTC", " + 10 hours"],
["L", "Lima Time Zone Military UTC", " + 11 hours"],
["M", "Mike Time Zone Military UTC", " + 12 hours"],
["MDT", "Mountain Daylight Time North America UTC", " - 6 hours"],
["MESZ", "Mitteleuroäische Sommerzeit Europe UTC", " + 2 hours"],
["MEZ", "Mitteleuropäische Zeit Europe UTC", " + 1 hour"],
["MSD", "Moscow Daylight Time Europe UTC", " + 4 hours"],
["MSK", "Moscow Standard Time Europe UTC", " + 3 hours"],
["MST", "Mountain Standard Time North America UTC", " - 7 hours"],
["N", "November Time Zone Military UTC", " - 1 hour"],
["NDT", "Newfoundland Daylight Time North America UTC", " - 2:30 hours"],
["NFT", "Norfolk (Island) Time Australia UTC", " + 11:30 hours"],
["NST", "Newfoundland Standard Time North America UTC", " - 3:30 hours"],
["O", "Oscar Time Zone Military UTC", " - 2 hours"],
["P", "Papa Time Zone Military UTC", " - 3 hours"],
["PDT", "Pacific Daylight Time North America UTC", " - 7 hours"],
["PST", "Pacific Standard Time North America UTC", " - 8 hours"],
["Q", "Quebec Time Zone Military UTC", " - 4 hours"],
["R", "Romeo Time Zone Military UTC", " - 5 hours"],
["S", "Sierra Time Zone Military UTC", " - 6 hours"],
["T", "Tango Time Zone Military UTC", " - 7 hours"],
["U", "Uniform Time Zone Military UTC", " - 8 hours"],
["UTC", "Coordinated Universal Time Europe UTC", " + 0 hour"],
["V", "Victor Time Zone Military UTC", " - 9 hours"],
["W", "Whiskey Time Zone Military UTC", " - 10 hours"],
["WDT", "Western Daylight Time Australia UTC", " + 9 hours"],
["WEDT", "Western European Daylight Time Europe UTC", " + 1 hour"],
["WEST", "Western European Summer Time Europe UTC", " + 1 hour"],
["WET", "Western European Time Europe UTC", " + 0 hour"],
["WST", "Western Summer Time Australia UTC", " + 9 hours"],
["WST", "Western Standard Time Australia UTC", " + 8 hours"],
["X", "X-ray Time Zone Military UTC", " - 11 hours"],
["Y", "Yankee Time Zone Military UTC", " - 12 hours"],
["Z", "Zulu Time Zone Military UTC", " + 0 hour"]].each do |zone|
  offset = Time.zone_offset(zone[0])
  if offset
    p "#{zone[1]}: #{Time.zone_offset(zone[0])/(60*60)} = #{zone[2]}"
  else
    #p "Not supported: #{zone[1]}"
  end
end