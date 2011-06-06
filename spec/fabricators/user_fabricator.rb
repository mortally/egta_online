Fabricator(:user) do
<<<<<<< HEAD
  email "test@test.com"
  password "stuff1"
=======
  email {Fabricate.sequence(:email, 1) {|i| "test#{i}@test.com"}}
  password {Fabricate.sequence(:password, 1) {|i| "password#{i}" }}
  secret_key "srgegta"
>>>>>>> 52a977c464ee1d04c82319c2128b5b9d08d5bac0
end