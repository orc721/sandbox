# encoding: utf-8

require 'pp'



class Record


class Field
  attr_reader :key, :type
  attr_reader :index       ## note: zero-based position index (0,1,2,3,...)

  def initialize( key, index, type )
    @key    = key.to_sym  ## note: always symbol-ify (to_sym) key
    @index  = index
    @type   = type
  end
end  # class Field



class Base < Record

  def self.fields   ## note: use class instance variable (@fields and NOT @@fields)!!!! (derived classes get its own copy!!!)
    @fields ||= []
  end

  def self.keys
    @keys ||= fields.map {|field| field.key }.freeze
  end

  def self.index( key )   ## indef of key (0,1,2,etc.)
    ## note: returns nil now for unknown keys
    ##   use/raise IndexError or something - why? why not?
    @index_by_key ||= Hash[ keys.zip( (0...fields.size).to_a ) ].freeze
    @index_by_key[key]
  end



  def self.field( key, type )
    index = fields.size  ## auto-calc num(ber) / position index - always gets added at the end
    field = Field.new( key, index, type )
    fields << field

    define_field( field )  ## auto-add getter,setter,parse/typecast
  end

  def self.define_field( field )
    key    = field.key   ## note: always assumes a "cleaned-up" (symbol) name
    index  = field.index

    define_method( key ) do
      instance_variable_get( "@values" )[index]
    end
  end

  ## note: "skip" overloaded new Record.new (and use old_new version)
  def self.new( *args ) old_new( *args ); end



  attr_reader :values

  def initialize( *args )
    #####
    ##  todo/fix: add allow keyword init too
    ###  note:
    ###  if init( 1, {} )  assumes last {} is a kwargs!!!!!
    ##                     and NOT a "plain" arg in args!!!

    ## puts "[#{self.class.name}] Record::Base.initialize:"
    ## pp args

    ##
    ##  fix/todo: check that number of args are equal fields.size !!!
    ##            check types too :-)

    @values = args
    @values.freeze
    ## freeze self too - why? why not?
    self
  end


  def update( **kwargs )
    new_values = @values.dup   ## note: use dup NOT clone (will "undo" frozen state?)
    kwargs.each do |key,value|
       index = self.class.index( key )
       new_values[ index ] = value
    end
    self.class.new( *new_values )
  end

  ## todo/fix:
  ##   add eql?/==

end # class Base


  def self.build_class( class_name, **attributes )
    klass = Class.new( Base )
    attributes.each do |key, type|
       klass.field( key, type )
    end

    const_set( class_name, klass )   ## returns klass (plus sets global constant class name)
  end

  class << self
    alias_method :old_new, :new       # note: store "old" orginal version of new
    alias_method :new,     :build_class    # replace original version with create
  end
end # class Record




Record.build_class( :Account2,
                     balance:    Integer,
                     allowances: Hash )

pp Record::Account2
Account2 = Record::Account2
pp account1a  = Account2.new( 1, {} )

pp account1a.update( balance: 20 )
pp account1a.update( balance: 30 )


Record.new( :Account3,
               balance:    Integer,
               allowances: Hash )

pp Record::Account3
Account3 = Record::Account3
pp Account3.keys
pp Account3.fields
pp Account3.index( :balance )
pp Account3.index( :allowances )
pp account1a  = Account3.new( 1, {} )

pp account1a.update( balance: 20 )
pp account1a.update( balance: 30 )

pp account1b =  account1a.update( balance: 10, allowances: { '0xaa': 20 } )
pp account1b.allowances



__END__


class Account < Record::Base
  field :balance,    Integer
  field :allowances, Hash
end





pp Account
pp account1a  = Account.new( 1, {} )

pp account1a.update( balance: 20 ).class
pp account1a.update( balance: 30 ).class

account1b =  account1a.update( balance: 10 )
pp account1b
pp account1b.balance
pp account1b.allowances
pp account1b.values

pp account1b =  account1a.update( balance: 10, allowances: { '0xaa': 20 } )
pp account1b.allowances


pp account2 = Account.new( 2, {} )
pp account1a.is_a? Record
pp account1a.is_a? Record::Base
pp Account.ancestors
