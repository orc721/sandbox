require 'punkmaker'


sheet = Pixelart::Spritesheet.read( '../generative-orc-721/docs/diyapes/spritesheet.png',
                                    '../generative-orc-721/diyapes/meta.csv',
                                    width: 24,
                                    height: 24 )


recs = read_csv( "./diyapes/diyapes.csv" )
puts "   #{recs.size} record(s)"


######
# variant 1 - classic

composite = ImageComposite.new( 10, 10 )


base = sheet.find_by( name: 'Ape' )

recs.each do |rec|
   ape = Image.new( 24, 24 )

   ape.compose!( base )    unless rec['type'].empty?

   accessories = rec['accessories'].split( '/' )
   accessories.each do |name|
      img = sheet.find_by( name: name )
      ape.compose!( img )
   end

   composite << ape  
end

composite.save( "./tmp/diyapes.png" )
composite.zoom(4).save( "./tmp/diyapes@4x.png" )


######
# variant 2 - gold(en)


composite = ImageComposite.new( 10, 10 )

GOLD = '#ffd700'
base = Punk::Ape.make( GOLD )

recs.each do |rec|
   ape = Image.new( 24, 24 )

   ape.compose!( base )    unless rec['type'].empty?

   accessories = rec['accessories'].split( '/' )
   accessories.each do |name|
      img = sheet.find_by( name: name )
      ape.compose!( img )
   end

   composite << ape  
end

composite.save( "./tmp/diyapes-gold.png" )
composite.zoom(4).save( "./tmp/diyapes-gold@4x.png" )



######
# variant 3 - (deep) pink

composite = ImageComposite.new( 10, 10 )

DEEP_PINK      =  '#ff1493'
base = Punk::Ape.make( DEEP_PINK )

recs.each do |rec|
   ape = Image.new( 24, 24 )

   ape.compose!( base )    unless rec['type'].empty?

   accessories = rec['accessories'].split( '/' )
   accessories.each do |name|
      img = sheet.find_by( name: name )
      ape.compose!( img )
   end

   composite << ape  
end

composite.save( "./tmp/diyapes-pink.png" )
composite.zoom(4).save( "./tmp/diyapes-pink@4x.png" )



######
# variant 4 - classic ("natural")

composite = ImageComposite.new( 10, 10 )

base = Image.read( './diyapes/ape-natural.png')

recs.each do |rec|
   ape = Image.new( 24, 24 )

   ape.compose!( base )    unless rec['type'].empty?

   accessories = rec['accessories'].split( '/' )
   accessories.each do |name|
      img = sheet.find_by( name: name )
      ape.compose!( img )
   end

   composite << ape  
end

composite.save( "./tmp/diyapes-ii.png" )
composite.zoom(4).save( "./tmp/diyapes-ii@4x.png" )



######
# variant 5 - (bitcoin) orange-pilled

composite = ImageComposite.new( 10, 10 )

BITCOIN_ORANGE = '#f7931a'
base = Punk::Ape.make( BITCOIN_ORANGE )
background = Image.read( './diyapes/bitcoin-pattern.png')


recs.each do |rec|
   ape = Image.new( 24, 24 )

   ape.compose!( background )
   ape.compose!( base )    unless rec['type'].empty?

   accessories = rec['accessories'].split( '/' )
   accessories.each do |name|
      img = sheet.find_by( name: name )
      ape.compose!( img )
   end

   composite << ape  
end

composite.save( "./tmp/diyapes-bitcoin.png" )
composite.zoom(4).save( "./tmp/diyapes-bitcoin@4x.png" )



puts "bye"
