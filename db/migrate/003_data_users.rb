class DataUsers < ActiveRecord::Migration
  def self.up
    anon = User.new(:login => "anonymous", :email => "guesst@stixy.com", :pwd => "password", :first_name => "Public", :last_name => "Guest")
		anon.roles << Role.find_by_name("Anonymous Role")
		anon.save_with_validation false
		admin = User.new(:login => "gbush@stixy.com", :email => "gbush@stixy.com", :pwd => "password", :first_name => "George", :last_name => "Bush")
		admin.roles << Role.find_by_name("Administrator Role")
		admin.save_with_validation false
		
		[ { :pwd => "password", :login => "jonas@swatdesign.com",             :first_name => "Jonas",      :last_name => "Höglund",    :email => "jonas@swatdesign.com"             , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "adam_block@swatdesign.com",        :first_name => nil,          :last_name => nil,          :email => "adam_block@swatdesign.com"        , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "magnus_fridh@swatdesign.com",      :first_name => "Magnus",     :last_name => "Fridh",      :email => "magnus_fridh@swatdesign.com"      , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "anna_ostergren@swatdesign.com",    :first_name => "Anna",       :last_name => "Östergren",  :email => "anna_ostergren@swatdesign.com"    , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "astrid_sjoberg@swatdesign.com",    :first_name => "Astrid",     :last_name => "Sjöberg",    :email => "astrid_sjoberg@swatdesign.com"    , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "agneta_distner@swatdesign.com",    :first_name => "Agneta",     :last_name => "Distner",    :email => "agneta_distner@swatdesign.com"    , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "bertil_heden@swatdesign.com",      :first_name => "Bertil",     :last_name => "Heden",      :email => "bertil_heden@swatdesign.com"      , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "claes_huber@swatdesign.com",       :first_name => "Claes",      :last_name => "Huber",      :email => "claes_huber@swatdesign.com"       , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "anna_henjer@swatdesign.com",       :first_name => "Anna",       :last_name => "Henjer",     :email => "anna_henjer@swatdesign.com"       , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "petra_isaksson@swatdesign.com",    :first_name => "Petra",      :last_name => "Isaksson",   :email => "petra_isaksson@swatdesign.com"    , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "drasko_markovic@swatdesign.com",   :first_name => "Drasko",     :last_name => "Markovic",   :email => "drasko_markovic@swatdesign.com"   , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "peter_ekman@swatdesign.com",       :first_name => "Peter",      :last_name => "Ekman",      :email => "peter_ekman@swatdesign.com"       , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "camilla_alteus@swatdesign.com",    :first_name => "Camilla",    :last_name => "Alteus",     :email => "camilla_alteus@swatdesign.com"    , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "annika_latinen@swatdesign.com",    :first_name => "Annika",     :last_name => "Latinen",    :email => "annika_latinen@swatdesign.com"    , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "elisabeth_dahlbom@swatdesign.com", :first_name => "Elisabeth",  :last_name => "Dahlbom",    :email => "elisabeth_dahlbom@swatdesign.com" , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "andreas_gronqvist@swatdesign.com", :first_name => "Andreas",    :last_name => "Grönqvist",  :email => "andreas_gronqvist@swatdesign.com" , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "georges_saab@swatdesign.com",      :first_name => "Georges",    :last_name => "Saab",       :email => "georges_saab@swatdesign.com"      , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "emma_inganas@swatdesign.com",      :first_name => "Emma",       :last_name => "Inganäs",    :email => "emma_inganas@swatdesign.com"      , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "gunnar_ostergren@swatdesign.com",  :first_name => "Gunnar",     :last_name => "Östergren",  :email => "gunnar_ostergren@swatdesign.com"  , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "roine_hoglund@swatdesign.com",     :first_name => "Roine",      :last_name => "Höglund",    :email => "roine_hoglund@swatdesign.com"     , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "ida_hoglund@swatdesign.com",       :first_name => "Ida",        :last_name => "Höglund",    :email => "ida_hoglund@swatdesign.com"       , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "henrik_hansson@swatdesign.com",    :first_name => "Henrik",     :last_name => "Hansson",    :email => "henrik_hansson@swatdesign.com"    , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "susan_falk@swatdesign.com",        :first_name => "Susan",      :last_name => "Falk",       :email => "susan_falk@swatdesign.com"        , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "marcus_wiman@swatdesign.com",      :first_name => "Marcus",     :last_name => "Wiman",      :email => "marcus_wiman@swatdesign.com"      , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "lina_ahlgren@swatdesign.com",      :first_name => "Lina",       :last_name => "Ahlgren",    :email => "lina_ahlgren@swatdesign.com"      , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "maria_distner@swatdesign.com",     :first_name => "Maria",      :last_name => "Distner",    :email => "maria_distner@swatdesign.com"     , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "jeff_mansson@swatdesign.com",      :first_name => "Jeff",       :last_name => "Månsson",    :email => "jeff_mansson@swatdesign.com"      , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "mathias_worbin@swatdesign.com",    :first_name => "Mathias",    :last_name => "Worbin",     :email => "mathias_worbin@swatdesign.com"    , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "matz_karlsson@swatdesign.com",     :first_name => "Matz",       :last_name => "Karlsson",   :email => "matz_karlsson@swatdesign.com"     , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "magnus_gustafsson@swatdesign.com", :first_name => "Magnus",     :last_name => "Gustafsson", :email => "magnus_gustafsson@swatdesign.com" , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "anders_ottoson@swatdesign.com",    :first_name => "Anders",     :last_name => "Ottoson",    :email => "anders_ottoson@swatdesign.com"    , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "patrick_baltatzis@swatdesign.com", :first_name => "Patrick",    :last_name => "Baltatzis",  :email => "patrick_baltatzis@swatdesign.com" , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "paul_broman@swatdesign.com",       :first_name => "Paul",       :last_name => "Broman",     :email => "paul_broman@swatdesign.com"       , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "majsan_myrvagn@swatdesign.com",    :first_name => "Majsan",     :last_name => "Myrvagn",    :email => "majsan_myrvagn@swatdesign.com"    , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "karin_lilja@swatdesign.com",       :first_name => "Karin",      :last_name => "Lilja",      :email => "karin_lilja@swatdesign.com"       , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "rebecka_lindberg@swatdesign.com",  :first_name => "Rebecka",    :last_name => "Lindberg",   :email => "rebecka_lindberg@swatdesign.com"  , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "mats_sjoholm@swatdesign.com",      :first_name => "Mats",       :last_name => "Sjöholm",    :email => "mats_sjoholm@swatdesign.com"      , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "stefan_fohlin@swatdesign.com",     :first_name => "Stefan",     :last_name => "Fohlin",     :email => "stefan_fohlin@swatdesign.com"     , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "conny_rikardsson@swatdesign.com",  :first_name => "Conny",      :last_name => "Rikardsson", :email => "conny_rikardsson@swatdesign.com"  , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "svante_selling@swatdesign.com",    :first_name => "Svante",     :last_name => "Selling",    :email => "svante_selling@swatdesign.com"    , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "svante_rodegard@swatdesign.com",   :first_name => "Svante",     :last_name => "Rödegård",   :email => "svante_rodegard@swatdesign.com"   , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "sara_torson@swatdesign.com",       :first_name => "Sara",       :last_name => "Torson",     :email => "sara_torson@swatdesign.com"       , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "tom_friesch@swatdesign.com",       :first_name => "Tom",        :last_name => "Friesch",    :email => "tom_friesch@swatdesign.com"       , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "stefan_jeppsson@swatdesign.com",   :first_name => "Stefan",     :last_name => "Jeppsson",   :email => "stefan_jeppsson@swatdesign.com"   , :created_by_id => admin.id, :updated_by_id => admin.id},
      { :pwd => "password", :login => "tomas_sjoberg@swatdesign.com",     :first_name => "Tomas",      :last_name => "Sjöberg",    :email => "tomas_sjoberg@swatdesign.com"     , :created_by_id => admin.id, :updated_by_id => admin.id}
		].each do |data|
		  u = User.new(data)
  		u.roles << Role.find_by_name("User Role")
  		u.save_with_validation(false)
	  end
	end
end