https://quizlet.com/44660684/intermediate-ruby-flash-cards/
https://www.wisdomjobs.com/e-university/ruby-on-rails-interview-questions.html
https://www.youtube.com/watch?v=wjEeLjGkBeA
http://www.rubyfleebie.com/ruby-is-dynamically-and-strongly-typed/
https://stackoverflow.com/questions/40707860/ruby-finding-the-third-greatest-value-in-an-array-need-help-understanding-me
______________________________________________________________________

Action Mailer:
1) https://launchschool.com/blog/handling-emails-in-rails

2) SMTP(Simple Mail Transfer Protocol)

3) 
Mailers are really just another way to render a view. 
Instead of rendering a view and sending it over the HTTP protocol, they are just sending it out through the email protocols instead. Due to this, it makes sense to just have your controller tell the Mailer to send an email when a user is successfully created.

______________________________________________________________________

Associations:
habm, HABM, has_and_belongs_to_many

______________________________________________________________________

(N+1) queries problem:

Consider the following code, which finds 10 clients and prints their postcodes:

clients = Client.limit(10)
 clients.each do |client|
  puts client.address.postcode
end


The same example can related to tracking
accounts = Account.limit(10)
accounts.each do |account|
  puts account.hubs.pluck(:name)
end

accounts = Account.includes(:hubs).limit(10) #SELECT `accounts`.* FROM `accounts` LIMIT 10
                                             #SELECT `hubs`.* FROM `hubs` WHERE `hubs`.`account_id` IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
accounts.each do |account|
  puts account.hubs.pluck(:name)
end
  


This code executes 1 (to find 10 clients) + 10 (one per each client to load the address) = 11 queries in total.

hubs = Hub.limit(10)     #SELECT  `hubs`.* FROM `hubs` LIMIT 10
hubs.each do |hub|
	puts hub.account.name  #SELECT  `accounts`.* FROM `accounts` WHERE `accounts`.`id` = 5 LIMIT 1 => "Meghana"
                         #SELECT  `accounts`.* FROM `accounts` WHERE `accounts`.`id` = 3 LIMIT 1 => "SRS"
end

            This below one is "Eager Loading"

hubs=Hub.includes(:account).limit(10) #SELECT  `hubs`.* FROM `hubs` LIMIT 10
                                      #SELECT `accounts`.* FROM `accounts` WHERE `accounts`.`id` IN (5, 3, 1)
hubs.each do |hub|
  puts hub.account.name
end
#Here Hub's code rewriting to "eager load accounts"

(using includes is 'eager loading', i think)
______________________________________________________________________

eager loading to reduce the number of database queries needed for data retrieval.

                preload

Account.preload(:hubs).class
# No SQL Query is loading

Account.preload(:hubs).to_a.class
#Account Load (0.5ms)  SELECT `accounts`.* FROM `accounts`
#Hub Load (0.1ms)  SELECT `hubs`.* FROM `hubs` WHERE `hubs`.`account_id` IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27)


- when "LEFT OUTER JOIN" will come????
- may be when we are using references - it may come


              No change in preload includes, except that references we can use in - includes case.
Account.preload(:hubs)
Account.preload(:hubs).where("hubs.name='First Hub'") #hubs name -- Crash
   (or)
Account.preload(:hubs).where(hubs: {name: 'First Hub'}) #hubs name -- Crash
Account.preload(:hubs).where("accounts.name='TrackinGo'") #accounts name
Account.preload(:hubs).where("name='Trackingo'") #Automaticaly will take from accounts table only

Account.includes(:hubs)
Account.includes(:hubs).where("hubs.name='First Hub'") #Hubs name -- Crash
Account.includes(:hubs).where("accounts.name='TrackinGo'") #accounts name
Account.includes(:hubs).where("name=?", "Trackingo") #Automaticaly will take from accounts table only
Account.includes(:hubs).references(:hubs).where('hubs.name = "First Hub"') #As querying with other table, defenetly need to mention table name also. Other wise ambiguous will come. 


https://blog.bigbinary.com/2013/07/01/preload-vs-eager-load-vs-joins-vs-includes.html

http://blog.scoutapp.com/articles/2017/01/24/activerecord-includes-vs-joins-vs-preload-vs-eager_load-when-and-where
______________________________________________________________________

joins:
what exaclt joins doo
why

class Author
  has_many :books
end

class Book
  belongs_to :author
  scope :available, ->{where(available: true)}
  scope :unavailable, ->{where(available: [nil, false])}
end

Author has_many books
Book belongs_to author
To get -> Author having books
          Author having only available bookings
          Author having unavailable bookings

Author.joins(:books).where(books: {available: true})
Author.joins(:books).merge(books.available)


arr1 = BusBooking.where(travel_date: CommonUtils.get_current_date)
arr2 = BusBooking.joins(:bus_tickets).where(travel_date: CommonUtils.get_current_date)
  # Output is same, but query loading may differs
obj1 = arr1
obj2 = arr2

obj1.pluck(:api_booking_id)
obj2.pluck(:api_booking_id)

SQL Queries:
"SELECT `bus_bookings`.* FROM `bus_bookings` WHERE `bus_bookings`.`travel_date` = '2018-03-27'"
"SELECT `bus_bookings`.* FROM `bus_bookings` INNER JOIN `bus_tickets` ON `bus_tickets`.`api_booking_id` = `bus_bookings`.`id` WHERE `bus_bookings`.`travel_date` = '2018-03-27'"

Explain Queries:
id    select_type      table         type   possible_keys  key   key_len   ref   rows     Extra
'1',    'SIMPLE',   'bus_bookings',  'ALL',    NULL,       NULL,   NULL,   NULL, '7209',  'Using where'


'1',    'SIMPLE',    'bus_tickets',  'ALL',    NULL,       NULL,   NULL,   NULL,  '8779',  ''
'1',    'SIMPLE',    'bus_bookings', 'eq_ref', 'PRIMARY', 'PRIMARY', '4', 'ts_portals_new.bus_tickets.api_booking_id', '1', 'Using where'



BusBooking.joins(:bus_tickets).present? ==> true
Busticket.joins(:bus_booking).present? ==> true

BusBooking.where(id: [481, 482]).first.bus_tickets.present?  ----> 2 queries
BusTicket.joins(:bus_booking).where(bus_bookings: {id: [481, 482]}).present? ----> only 1query
BusBooking.joins(:bus_tickets).where(id: [481, 482]).present? ---> only 1 query

Iff only 'bus_booking' is there, but no 'bus_tickets'
BusBooking.where(id: 7272).joins(:bus_tickets).where(bus_tickets: {id: nil}).first
                        (or)
BusBooking.where(id: 7272).joins("INNER JOIN bus_tickets ON bus_tickets.api_booking_id=bus_bookings.id").where(bus_tickets: {id: nil}).first
=> nil
Means, if we use inner join, it will check with the associated columns and it will match(bus_booking id ---- with---- bus_tickets.api_booking_id)

Iff we use 'left outer join' - even no bus_tickets also, bus_booking will return
BusBooking.where(id: 7272).joins("LEFT OUTER JOIN bus_tickets ON bus_tickets.api_booking_id = bus_bookings.id").where(bus_tickets: {id: nil}).first
=> #..... renders bus_booking object

BusBooking.count
BusTicket.count
BusBooking.includes(:bus_tickets).count


                    ****Difference in only includes also more confusing
BusBooking.includes(:bus_tickets).where(id: 7272) #---> 2 queries
BusBooking.includes(:bus_tickets).where(bus_tickets: {id: 9154}) #----> big query, left outer join
______________________________________________________________________


Normal:
BusBooking.where(id: [481, 482])
SELECT `bus_bookings`.* FROM `bus_bookings` WHERE `bus_bookings`.`id` IN (481, 482)

BusBooking.where(id: [481, 482]).first.bus_tickets
SELECT  `bus_bookings`.* FROM `bus_bookings` WHERE `bus_bookings`.`id` IN (481, 482)  ORDER BY `bus_bookings`.`id` ASC LIMIT 1
SELECT `bus_tickets`.* FROM `bus_tickets` WHERE `bus_tickets`.`api_booking_id` = 481

                    --------------
Joins:
BusBooking.joins(:bus_tickets).where(id: [481, 482])
SELECT `bus_bookings`.* FROM `bus_bookings` INNER JOIN `bus_tickets` ON `bus_tickets`.`api_booking_id` = `bus_bookings`.`id` WHERE `bus_bookings`.`id` IN (481, 482)

BusBooking.joins(:bus_tickets).where(id: [481, 482]).first.bus_tickets
SELECT  `bus_bookings`.* FROM `bus_bookings` INNER JOIN `bus_tickets` ON `bus_tickets`.`api_booking_id` = `bus_bookings`.`id` WHERE `bus_bookings`.`id` IN (481, 482)  ORDER BY `bus_bookings`.`id` ASC LIMIT 1
SELECT `bus_tickets`.* FROM `bus_tickets` WHERE `bus_tickets`.`api_booking_id` = 481

                    --------------
includes:
BusBooking.includes(:bus_tickets).where(id: [481, 482])
SELECT `bus_bookings`.* FROM `bus_bookings` WHERE `bus_bookings`.`id` IN (481, 482)
SELECT `bus_tickets`.* FROM `bus_tickets` WHERE `bus_tickets`.`api_booking_id` IN (481, 482)
BusBooking.includes(:bus_tickets).where(id: [481, 482]).first.bus_tickets
SELECT  `bus_bookings`.* FROM `bus_bookings` WHERE `bus_bookings`.`id` IN (481, 482)  ORDER BY `bus_bookings`.`id` ASC LIMIT 1
SELECT `bus_tickets`.* FROM `bus_tickets` WHERE `bus_tickets`.`api_booking_id` IN (481)
______________________________________________________________________



.........................................................................
a) inc = BusBooking.includes(:bus_tickets).where(id: 6950)

BusBooking Load (0.7ms)  SELECT `bus_bookings`.* FROM `bus_bookings` WHERE `bus_bookings`.`id` = 6950
BusTicket Load (18.9ms)  SELECT `bus_tickets`.* FROM `bus_tickets` WHERE `bus_tickets`.`api_booking_id` IN (6950)

inc.first.id
inc.first.bus_tickets # No Seperate Query

b) joi = BusBooking.joins(:bus_tickets).where(id: 6950) #Inner Join
BusBooking Load (4.0ms)  SELECT `bus_bookings`.* FROM `bus_bookings` INNER JOIN `bus_tickets` ON `bus_tickets`.`api_booking_id` = `bus_bookings`.`id` WHERE `bus_bookings`.`id` = 6950

joi.first.id

joi.first.bus_tickets #Seperate Query again
SELECT `bus_tickets`.* FROM `bus_tickets` WHERE `bus_tickets`.`api_booking_id` = 6950
.........................................................................



Duck Typing:

Means no data type is required
as everything is an object
Array.sum() => here sum is method using for class Array
here, ruby is more concerned about how object methods to get act on.
      but not on how objects how it behaves????


______________________________________________________________________

Constructors:
- only => class method => .new is ruby Constructors
- 

http://www.verygoodindicators.com/blog/2015/03/15/ruby-contructors/
______________________________________________________________________

App folder sturture:

https://www.engineyard.com/blog/keeping-your-rails-controllers-dry-with-services
______________________________________________________________________
        Module methods calling if we use Include and extends
class A
  include CommonUtils
end

class B
  extend CommonUtils
end
A.new.test
B.test
________________________________________________________________________

                            Block, Proc, Lambda

def block_test(&block)
  block.call
end

a) block_test {puts "Rubyy"}
Rubyy
=> nil

b) block_test
NoMethodError: undefined method 'call' for nil:NilClass

c) block_test("Rubyy")
ArgumentError: wrong number of arguments (1 for 0)

d) block_test{"Rubyy"}
"Rubyy"


def block_test_new
  yield
end
block_test_new{puts "Rubyy"}
Rubyy
=> nil


Proc.new{puts "Ruby"}
=> #<Proc:0x0000000b029cd8@(pry):36>

Proc.new{puts "Ruby"}.call
Ruby
=> nil


def proc_test(arg)
  arg.call
end
proc_test Proc.new{puts "Ruby"}
Ruby
=> nil



________________________________________________________________________
                        Puts, Print, p
puts "Ruby"
Ruby
=> nil

print "Ruby"
Ruby=> nil

p "Ruby"
"Ruby"
=> "Ruby"
________________________________________________________________________
Class Variable (vs) Instance Variable
http://maximomussini.com/posts/ruby-class-variables/
________________________________________________________________________


method overriding
class A
  def m1(x, y)
    puts "1st method"
  end
  def m1(x, y)
    puts "2nd method"
  end
end

a = A.new
a.m1(1, 2)


method overloading:
class A
  def m1(x, y)
    puts "1st method"
  end
  def m1(x, y, z)
    puts "2nd method"
  end
end
a = A.new
a.m1(1,2) #crash, #wrong number of arguments (given 2, expected 3) (ArgumentError)
a.m1(1,2,3)

Here, in method overloading also, in final method it will touch, based on the last method only we have to pass the arguments, other it will throw ArgumentError
This thing cab be achieved in ruby by bewlo example:

class A
  def m(*args)
    if args.length==1
      puts "my name is #{args[0]}"
    else
      puts "my name is #{args[0]} and age is #{args[1]}"
    end
  end
end

a = A.new
a.m(name) #This will work
a.m(name, age) #This will also work 
---------------------------------------------------------------------------------------
prepend, include, extend
https://codedecoder.wordpress.com/author/arunyadav4u/

Open this file:
/home/bitlasoft/Videos/Attend/prepend_include_extend.rb

mixin:
https://codedecoder.wordpress.com/2016/06/20/mixin-in-ruby-include-prepend-extend/
---------------------------------------------------------------------------------------
Connecting database without database.yml file
require 'active_record'

ActiveRecord::Base.establish_connection({
  adapter:  'sqlite3',
  database: 'db/test.sqlite3'
})
---------------------------------------------------------------------------------------
Named scopes/model scopes

class Profile
  scope :get_users, -> { where(user_type: 1) }
  scope :get_agents, -> { where(user_type: 2) }
end
Profile.get_users.get_agents ---> will get the query for combination of there 2 where queries 
---------------------------------------------------------------------------------------
ActiveRecord Merge

class BusBooking
  has_many :bus_tickets
end

class BusTicket
  belongs_to :bus_booking, foreign_key: :api_booking_id
  scope :get_ids_of_no_bus_bookings, -> { where("travel_date >= ? AND api_booking_id is null", CommonUtils.get_current_date-10) }
end
________________________________________________________________________

each (vs) map (vs) collect (vs) select (vs) pluck

To check the performance related

bb=BusBooking.where(id: [481, 482])
Benchmark.measure{bb.select(:id).collect(&:id)}
Benchmark.measure{bb.select(:id).map(&:id)}
Benchmark.measure{bb.pluck(:id)}

puts Benchmark.measure{BusBooking.where(id: [481, 482]).select(:id).collect(&:id)}
puts Benchmark.measure{BusBooking.where(id: [481, 482]).select(:id).map(&:id)}
puts Benchmark.measure{BusBooking.where(id: [481, 482]).pluck(:id)}
