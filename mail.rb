#! /usr/bin/ruby
# coding: utf-8

require 'csv'

source = ARGV[0]
target = 'email.csv'
target = ARGV[1]

$csv = CSV.read source
$out = []
$err = {:mob=>[],:dob=>[]}
$hdr = $csv.shift
$mcol = $hdr.index('email')

$csv.each_with_index do |v, i|
  $out << [v[$mcol]]
end

CSV.open(target,'wb') do |line|
  puts 'Processing: writing to file.'
  $out.each_with_index do |o, i|
    line << o
  end
end

puts "Operation completed!"
