#! /usr/bin/ruby
# coding: utf-8

require 'csv'

source = ARGV[0]
target = "target.csv"
target = ARGV[1].split "."  if ARGV.length > 1
numseg = 10
numseg = ARGV[2].to_i if ARGV.length > 2
header = 1
header = ARGV[3].to_i if ARGV.length > 3

puts "Reading file: #{source}"

csv = CSV.read source

hdrline = csv.shift if header == 1

csvlen = csv.length

puts "File read."

seglen = (csvlen / numseg) + 1

curline = 0

numseg.times do |i|
  file = target[0]+"_"+i.to_s+'.'+target[1..-1].join(".")
  puts "Writing to #{file}..."
  CSV.open(file,"wb") do |output|
    output << hdrline if header == 1
    seglen.times do
      output << csv[curline].map{|x| x.gsub('"','').strip if x } if curline < csvlen
      curline += 1
    end
  end
end

puts "Operation completed!"
