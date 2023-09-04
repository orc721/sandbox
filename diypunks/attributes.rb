###
#  prepare (generate) attributes


require 'cocos'

mints = read_csv( "../generative-orc-721/diypunks/mint.csv")
mints = mints[0,721]   ## cut-off overflow for now (max. 721)
puts "  #{mints.size} record(s)"



meta = read_csv( "../generative-orc-721/diypunks/meta.csv")

## note: MUST sort meta records by id!!!
##          do NOT assume / expected sorted records!!!!
meta = meta.sort do |l,r|
                   l['id'].to_i(10) <=> r['id'].to_i(10)
                 end

puts "  #{meta.size} record(s)"
pp meta


recs = []

mints.each_with_index do |rec,i|
   num = rec['num']
   g  =  rec['g'].strip.split( %r{[ ,;/_-]+} ).map {|v| v.to_i(10) }

   base = []
   attributes = []
   background = []

   g.each do |value|
       attribute  = meta[value]
       if attribute.nil?
         puts "!! ERROR - no meta record found g no. #{value}; sorry"
         exit 1
       end

       if [0,1,2,3,4,5,6,7,8,9].include?(value)
         base << attribute['name']  # note: in theory more than once base possible?
       elsif [58,59].include?( value )
         background << attribute['name']
       else
         attributes << attribute['name']
       end
    end
    recs << [i.to_s, 
             base.join(' / '),
             attributes.join( ' / '),
             background.join( ' / ' ),
            ]
end

pp recs

headers = ['id', 'type', 'accessories', 'background'] 
buf = ''
buf << headers.join( ', ' )
buf << "\n"
recs.each do |values|
    buf << values.join( ', ' )
    buf << "\n"
end

puts buf
write_text( "./tmp/diypunks.csv", buf )

puts "bye"
