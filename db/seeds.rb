# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create(
  password: 'ee552bc651470a3cbd7a165c7469a3bae3d58fc82f6b1ebfc39615713b290bd92b45bb7e01e4a66b66b30e3add44197dde61938300eece99dd1473e0549a6c9e', password_confirmation: 'ee552bc651470a3cbd7a165c7469a3bae3d58fc82f6b1ebfc39615713b290bd92b45bb7e01e4a66b66b30e3add44197dde61938300eece99dd1473e0549a6c9e',
  first_name: 'Alexander',
  type: 'admin',
  phone: '+79520865216'
)
