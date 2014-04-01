#! /usr/bin/ruby
# coding: utf-8

require 'csv'
require 'unicode_utils'
require 'rainbow'
require 'ruby-progressbar'

def validateMobile p
  phone = p.gsub /[^0-9+]/, ''
  phone.gsub! '+90', ''
  phone.gsub! /\b0/, ''
  phone.force_encoding 'utf-8'
  return '' if phone.nil? or phone === ""
  return phone if phone.length == 10 and phone[0] == '5'
  $err[:mob] << p
  return ''
end

def validateDOB d
  year = d.gsub(/[\s\/,-]/, '-')
  sply = year.split('-')
  return '' if year.nil? or year === "" or sply.length < 3
  if sply[-1].length < 4
    year = sply.reverse.join('-')
  end
  if sply[1].to_i > 12
    sply = year.split('-')
    year = [sply[2],sply[0],sply[1]].join('-')
  end
  if year.length == 8
    now = Date.today.year
    y1 = year[0..3].to_i
    y2 = year[4..7].to_i
    if y2 < now - 17 and y2 > now - 101
      year = year[4..7]+"-"+year[2..3]+"-"+year[0..1]
    else
      year = year[0..3]+"-"+year[4..5]+"-"+year[6..7]
    end
  end
  begin
    date = Date.parse year
    return date.strftime('%Y-%m-%d') if date < Date.today - (100 * 365.24)
  rescue
    $err[:dob] << d
    return ''
  end
end

def matchCity word, jarow
  dists = []
  cities = "Adana$Adıyaman$Afyonkarahisar$Ağrı$Amasya$Ankara$Antalya$Artvin$Aydın$Balıkesir$Bilecik$Bingöl$Bitlis$Bolu$Burdur$Bursa$Çanakkale$Çankırı$Çorum$Denizli$Diyarbakır$Edirne$Elazığ$Erzincan$Erzurum$Eskişehir$Gaziantep$Giresun$Gümüşhane$Hakkâri$Hatay$Isparta$Mersin$İstanbul$İzmir$Kars$Kastamonu$Kayseri$Kırklareli$Kırşehir$Kocaeli$Konya$Kütahya$Malatya$Manisa$Kahramanmaraş$Mardin$Muğla$Muş$Nevşehir$Niğde$Ordu$Rize$Sakarya$Samsun$Siirt$Sinop$Sivas$Tekirdağ$Tokat$Trabzon$Tunceli$Şanlıurfa$Uşak$Van$Yozgat$Zonguldak$Aksaray$Bayburt$Karaman$Kırıkkale$Batman$Şırnak$Bartın$Ardahan$Iğdır$Yalova$Karabük$Kilis$Osmaniye$Düzcei$Girne"
  cities = cities.split('$')
  cities.each do |c|
    dists << jarow.getDistance(word.downcase, c.downcase)
  end
  city = cities[dists.index dists.max]
  return city, dists.max
end

def checkFields csv, csvlen
  csv.each do |v|
    word = ''
    [13,14,15].each do |m|
      if v[m] != ''
        word = v[m]
        break
      end
    end
    word = word.force_encoding 'utf-8'
    #city = ''
    #if word.length > 2
    #  city, dist = matchCity word, jarow 
    #  puts city + '_' + word + ': ' + dist.to_s if dist > 0.71
    #end
  end
end
#checkFields csvo

def getIndexes names
  inds = []
  names.each do |n|
    ind = $hdr.index(n)
    if ind == nil
      puts 'error: '+n
    else
      inds << ind
    end
  end
  return inds
end

def getPrime fields, row
  output = ''
  getIndexes(fields).each do |f|
    if row[f].length > 0
      output = UnicodeUtils.titlecase(row[f].force_encoding('utf-8'),:tr)
      break
    end
  end
  return output
end

def getSignup fields, row
  output = ''
  getIndexes(fields).each do |f|
    if row[f].length > 0
      output = "1"
      break
    end
  end
  return output
end


source = ARGV[0]
target = 'target.csv'
target = ARGV[1]

def mergeFields 
  csvlen = $csv.length
  puts 'Processing: merging and mapping fields.'
  pb = ProgressBar.create :title=>'', :total=>csvlen, :format => '%e |%b>>%i| %p%% %t'

  $csv.each_with_index do |v, i|
    #break if i > 10
    o = []
    v.each_with_index do |vv,ii|
      vv = "" if vv.nil?
      if [7,9].include?(ii)
        if vv.nil? or vv == ""
          vv = vv.split(/\s/)[(7-ii)/2]
        end
        vv = "" if vv.nil?
        vv = UnicodeUtils.titlecase(vv,:tr).gsub(/^(\P{L}\S)/,'')
      elsif ii === 11
        vv = validateDOB vv
      elsif ii === 13
        vv = validateMobile vv
      end
      o << vv unless ii === 24
    end
    $out << o
    pb.increment
  end
end

$csv = CSV.read source
$out = []
$err = {:mob=>[],:dob=>[]}
$hdr = $csv.shift

mergeFields
CSV.open(target,'wb') do |line|
  line << $hdr[0..-2]
  puts 'Processing: writing to file.'
  pb = ProgressBar.create :title=>'', :total=>$csv.length, :format => '%e |%b>>%i| %p%% %t'
  $out.each_with_index do |o, i|
    line << o
    pb.increment
  end
end
CSV.open('mob_error.csv','wb') do |line|
  $err[:mob].each do |v|
    line << [v]
  end
end

CSV.open('dob_error.csv','wb') do |line|
  $err[:dob].each do |v|
    line << [v]
  end
end

puts "Operation completed: #{$out.length.to_s.foreground(:green)} lines parsed. Check #{target.foreground(:magenta)} for the result."
puts "phone_mobile field had #{$err[:mob].length.to_s.foreground(:red)} errors. Check #{'mob_error.csv'.foreground(:magenta)} for error report."
puts "date_of_birth field had #{$err[:dob].length.to_s.foreground(:red)} errors. Check #{'dob_error.csv'.foreground(:magenta)} for error report."

=begin
puts $inputcols.length 
puts $finalheader.length
$inputcols.length.times do |i|
  puts "#{$inputcols[i]} - #{$finalheader[i]}"
end
=end
