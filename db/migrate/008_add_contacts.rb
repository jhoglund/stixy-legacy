class AddContacts < ActiveRecord::Migration
  def self.up
    [ ["jonas@swatdesign.com", "maria_distner@swatdesign.com"], 
      ["jonas@swatdesign.com", "adam_block@swatdesign.com"],
      ["jonas@swatdesign.com", "anders_ottoson@swatdesign.com"],
      ["jonas@swatdesign.com", "peter_ekman@swatdesign.com"],
      ["jonas@swatdesign.com", "ann_distner@swatdesign.com"],
      ["jonas@swatdesign.com", "agneta_distner@swatdesign.com"]
    ].each do |relation|
      u = User.find_by_login(relation[0])
      c = User.find_by_login(relation[1])
      u.contacts << c if u and c
      u.save
    end
	end
end