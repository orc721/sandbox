require 'punkmaker'
require 'punks'


recs = read_csv( "./diyapes/diyapes.csv" )
puts "   #{recs.size} record(s)"


######
# variant 1 - classic

composite = ImageComposite.new( 10, 10 )

recs.each do |rec|
   ape = Image.new( 24, 24 )

   ape.compose!( Punk::Ape.make  )    unless rec['type'].empty?

   accessories = rec['accessories'].split( '/' )
   accessories.each do |name|
      img = Punk::Sheet.find_by( name: name, gender: 'm', size: 'l' )
      ape.compose!( img )
   end

   composite << ape  
end

composite.save( "./tmp/diyapes.png" )
composite.zoom(4).save( "./tmp/diyapes@4x.png" )


######
# variant 2 - gold(en)

GOLD          =  '#ffd700'

composite = ImageComposite.new( 10, 10 )

recs.each do |rec|
   ape = Image.new( 24, 24 )

   ape.compose!( Punk::Ape.make( GOLD )  )    unless rec['type'].empty?

   accessories = rec['accessories'].split( '/' )
   accessories.each do |name|
      img = Punk::Sheet.find_by( name: name, gender: 'm', size: 'l' )
      ape.compose!( img )
   end

   composite << ape  
end

composite.save( "./tmp/diyapes-gold.png" )
composite.zoom(4).save( "./tmp/diyapes-gold@4x.png" )



######
# variant 3 - (deep) pink

DEEPPINK      =  '#ff1493'

composite = ImageComposite.new( 10, 10 )

recs.each do |rec|
   ape = Image.new( 24, 24 )

   ape.compose!( Punk::Ape.make( DEEPPINK )  )    unless rec['type'].empty?

   accessories = rec['accessories'].split( '/' )
   accessories.each do |name|
      img = Punk::Sheet.find_by( name: name, gender: 'm', size: 'l' )
      ape.compose!( img )
   end

   composite << ape  
end

composite.save( "./tmp/diyapes-pink.png" )
composite.zoom(4).save( "./tmp/diyapes-pink@4x.png" )



######
# variant 4 - classic ("natural")

composite = ImageComposite.new( 10, 10 )

recs.each do |rec|
   ape = Image.new( 24, 24 )

   ape.compose!( Image.read( './diyapes/ape-natural.png')  )    unless rec['type'].empty?

   accessories = rec['accessories'].split( '/' )
   accessories.each do |name|
      img = Punk::Sheet.find_by( name: name, gender: 'm', size: 'l' )
      ape.compose!( img )
   end

   composite << ape  
end

composite.save( "./tmp/diyapes-ii.png" )
composite.zoom(4).save( "./tmp/diyapes-ii@4x.png" )



puts "bye"
