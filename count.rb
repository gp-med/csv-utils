#! /usr/bin/ruby
# coding: utf-8

source = ARGV[0]
header = 1
header = ARGV[1].to_i if ARGV.length > 1

puts "Reading file: #{source}"

csv = File.readlines source

hdrline = csv.shift if header == 1

csvlen = csv.length

puts "File contains #{csvlen.to_s} rows except for the header."
