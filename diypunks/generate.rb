require 'punkmaker'


sheet = Pixelart::Spritesheet.read( '../generative-orc-721/diypunks/spritesheet.png',
                                    '../generative-orc-721/diypunks/meta.csv',
                                    width: 24,
                                    height: 24 )


recs = read_csv( "./diypunks/diypunks.csv" )
puts "   #{recs.size} record(s)"

######
# variant 1 - classic without background
#    grid = [30,25]   ## 30 cols x 25 rows = 750

composite = ImageComposite.new( 30, 25 )

recs.each do |rec|
   punk = Image.new( 24, 24 )

   bases = rec['type'].split( '/' )
   bases.each do |name|
      punk.compose!( sheet.find_by( name: name ) )
   end 
 
   accessories = rec['accessories'].split( '/' )
   accessories.each do |name|
      img = sheet.find_by( name: name )
      punk.compose!( img )
   end

   composite << punk  
end

composite.save( "./tmp/diypunks.png" )
# composite.zoom(4).save( "./tmp/diypunks@4x.png" )



######
# variant 2 - pepe
composite = ImageComposite.new( 30, 25 )

base = Image.read( './diypunks/pepe.png')

recs.each do |rec|
   punk = Image.new( 24, 24 )

   punk.compose!( base )  unless rec['type'].empty?

   accessories = rec['accessories'].split( '/' )
   accessories.each do |name|
      img = sheet.find_by( name: name )
      punk.compose!( img )
   end

   composite << punk  
end

composite.save( "./tmp/diypunks-pepe.png" )
# composite.zoom(4).save( "./tmp/diypunks-pepe@4x.png" )



puts "bye"
