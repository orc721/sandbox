require 'pp'



def type( class_name, *args )
  puts "define type #{class_name}:"
  pp args

  if args.size == 1 && args[0].is_a?( Class )
    klass = args[0]
    Kernel.const_set( class_name, klass )
  elsif args.size == 1 && args[0].is_a?( Hash )
    keys = args[0].keys
    klass = Struct.new( *keys )
    Kernel.const_set( class_name, klass )
  else
    raise ArgumentError.new( "Class or Hash expected")
  end
end


def define_function( method, signature )
  Object.send( :alias_method, "#{method}_unsafe", method )

  puts "define function #{method}:"
  pp signature

  define_method method do |*args|
    if args.size == 0
      call_inspect = "#{method}()"
    else
      args_inspect = args.map { |arg| arg.inspect }.join( ", " )
      call_inspect = "#{method}( #{args_inspect} )"
    end
    puts "calling #{call_inspect}..."

    __send__( "#{method}_unsafe", *args ).tap do |result|
      puts "returning:"
      pp result
    end
  end
end


def sig( *args )
  method    = args.pop   # remove last element (assume it's a method)
  signature = args
  define_function( method, signature )
end

def init( *args )
  sig( *args )
end

def entry( *args )
  sig( *args )
end



Nat = Integer
Money = Integer
KeyHash = String
Address = String




def Option( arg ) arg; end

_ = nil    ## predefine "global" underscore variable


def failwith( msg, *args )
  if args.size == 0
    msg_inspect = msg
  else
    args_inspect = args.map { |arg| arg.inspect }.join( ", " )
    msg_inspect  = "#{msg}: #{args_inspect}"
  end
  fail msg_inspect
end

class Current
  def self.amount=(value) @amount = value; end
  def self.amount()       @amount ||= 0; end

  def self.sender=(value) @sender = value; end
  def self.sender()       @sender ||= "0x0000"; end


  def self.failwith( *args)
    ## hack: todo - is there a better way to call "global" outer failwith function/method ???
    Object.send( :failwith, *args );
  end
end



class Integer
  def tz()  self; end   ## tezzies (cryptocurrency)
  def p()   self; end   ## p(ositive) integer number (0... only)
end


def is_nat( num )
  if num >=0
    num   ## a.k.a Some
  else
    nil   ## a.k.a None
  end
end


module Map
  def self.find( key, map )
    value = map[key]
    value
  end

  def self.add( key, value, map )
    map.merge( Hash[key,value] )
  end

  def self.remove( key, map )
    ## todo: check if there's better way??
    new_map = map.merge( {} )
    new_map.delete( key )
    new_map
  end
end

module BigMap
end



def Object.const_missing( name )
  puts "const_missing:"
  pp name
  if name.to_s.start_with?( "Map‹" )
    Map
  elsif name.to_s.start_with?( "BigMap‹" )
    BigMap
  else
    super
  end
end


def match( obj, matchers )
  ## pp obj
  ## pp matchers
  ## note: assume None/Some for now
  if obj
    matchers[:Some].call( obj )
  else
    ## none
    matchers[:None].call
  end
end
