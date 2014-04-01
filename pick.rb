#! /usr/bin/ruby
# coding: utf-8

require 'csv'

source = ARGV[0]
target = 'email.csv'
target = ARGV[1]
fields = ARGV[2..-1]

$csv = CSV.read source
$out = []
$hdr = $csv.first
$fld = []
fields.each do |f|
  $fld << $hdr.index(f) if $hdr.index(f)
end

puts "Following columns are being picked:"
puts $fld.map{|f| $hdr[f]}.join(',')
puts

$csv.each_with_index do |v, i|
  lin = []
  $fld.each do |f|
    lin << v[f]
  end
  $out << lin
end

CSV.open(target,'wb') do |line|
  #puts 'Processing: writing to file.'
  $out.each_with_index do |o, i|
    line << o
  end
end

puts "Operation completed!"
