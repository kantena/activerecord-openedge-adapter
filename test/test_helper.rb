def create_magasin
  mag = Magasin.new
  mag.codsoc = "ER"
  mag.codtab = "VER10"
  assert mag.save
  mag
end

def create_person (name)
  p = Person.new
  p.name = name
  assert p.save
  p
end

def create_pet (name)
  pet = Pet.new
  pet.badge ="A001"
  pet.name = name
  assert pet.save
  pet
end


def column(klass,name)
  klass.columns.each {|col| return col if col.name == name}
end