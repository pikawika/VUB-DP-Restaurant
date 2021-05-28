/*Single loadable file for the Restaurant assignment.

The GitHub repository for this project is available at: https://github.com/pikawika/VUB-DP-Restaurant.
    It will be made public once the deadline of the assignment has passed to ensure it isn't fraudulently used by colleague students.

The created code was tested on an incremental basis through the interpreter.
   - The README.md file contains these test queries used in the interpreter.
      - The readme is best read through a markdown editor or directly on Github but a copy of the README file is provided as a huge comment at the bottom of this file.
   - Some predicates were made to make testing easy through a "one line" query.

Testing performed:
   - Testing SMS INBOX:
      - Simple unifaction tests.
   - Testing the DCG:
      - Helpfull testing predicates available under: TESTING NLP SYSTEM
      - Done through manually validating the extracted arguments of both the supplied sms inbox as well as a supplamentory inbox.
	  - Some extra tests for testing individual components of the grammar such as date extraction.

Some things were assumed:
   - Since the text messages are said to be processed no operations such as downcase_atom (lowercase transformation) are done.
   - Since we could make the NLP portion endlessly big, it is made so that only the examples and very minor extra's are accepted.
      - These extra's are tested via is_extra_processed_sms_inbox.
   - Since I'm no expert in linguistics the naming for different parts of sentences might be odd.
      - It is also possible to make weird sentences such as "book I can a table for 2" due to both being just labelled verb.
   - No constraint needed for "Booking takes place at least a day before" (confirmed by Homer).
   - For the following sentence: "preferably for the standard menu at 7 o'clock"
      - 7 o'clock is 7 pm since the restaurant is not open in the morning.
      - "preferable" is concerning the standard menu, not the time since it is situated before the menu. Thus menu also has the option to be "preferred".


KNOWN BUGS:
   - Table does not check double assign.

STUDENT INFO:
    - Name: Bontinck Lennert
    - Student ID: 568702
    - Affiliation: VUB - Master Computer Science: AI 
*/

/* 
##################################################################
#                         LIBRARY IMPORTS                        #
##################################################################

The following code will import the required libraries:
        - lists: used since it's seen as the default library for basic lists operation. 
            The used documentation can be found here: https://www.swi-prolog.org/pldoc/man?section=lists.
        - clpfd: used since it's seen as the default library for Constraint Logic Programming with Finite Domains 
            The used documentation can be found here: https://www.swi-prolog.org/pldoc/man?section=summary-lib-clpfd.
*/

:- use_module( 	[library(lists),
				library(clpfd)] ).


/* 
##################################################################
#                        GLOBAL PREDICATES                       #
##################################################################

Some global queries to ensure uniformity.
*/

/* Allows to represent menu as integer */
is_menu(1, standard) .
is_menu(2, theatre) .

/* 
##################################################################
#                            SMS INBOX                           #
##################################################################

The following code provides the pre-processed SMS inbox so that it can be easily used for testing purposes.
*/

/* Succeeds when its argument represents the pre-processed sms inbox provided by the assignment. */
is_processed_sms_inbox( [[table,for,2,at,20,':',00,on,18,march],
						[please,can,we,have,a,table,for,3,for,the,theatre,menu,on,march,18,th],
						[we,would,like,a,table,for,5,preferably,at,8,pm,on,18,'/',03],
						[can,i,book,a,table,at,9,pm,for,2,people,on,the,18,th,of,march,for,the,standard,menu,please],
						[reserve,us,a,table,on,march,18,for,a,party,of,4,for,the,standard,menu],
						[9,people,on,18,th,of,march],
						[book,6,of,us,in,on,18,march,at,20,':',00],
						[reservation,for,7,on,march,18,preferably,for,standard,menu,at,7,oclock]] ) .

/* Succeeds when its argument represents the extra pre-processed sms inbox provided by myself to demonstrate generality. */
is_extra_processed_sms_inbox( [[table,for,2,at,20,':',00,on,the,first,of,march],
								[hi,can,i,book,a,place,for,2, persons,on,the,first,of,march]] ) .


/* 
##################################################################
#                           NLP SYSTEM                           #
##################################################################

The following code implements the Definite Clause Grammars (DCGs).
DCGs are a facility in Prolog which makes it easy to define languages according to grammar rules.

In our system the accepted grammers consist of a few majour parts which can be in different orders:
   - introduction description: introductory part of sentence. (e.g. "we would like to order a table")
   - amount_description: part of sentence that specifies the amount of people. (e.g. "for 2 people")
   - time_description: part of sentence that specifies the time of the reservation, can be non-specified. (e.g. "8 pm")
   - date_description: part of sentence that specifies the date of the reservation. (e.g. "first of march")
   - menu_description: part of sentence that specifies the preffered menu, can be non-specified. (e.g. "for the standard menu")
   - ending_description: ending part of sentence. (e.g. "thank you")

A reservation request is a natural language sentence having the above parts from wich the following following arguments can be extracted:
   - Date: day of reservation - [Day, Month] - both integer
   - Time: time of reservation - [Hour, Minute, Preference] - Hour and Minute are integers or _ and Preference is a constant being either fixed, preferred or unspecified
   - Amount: number of people - integer
   - Menu: chosen menu - [Menu, Preference] - Menu is a constant being either standard, theatre or _ and Preference is also a constant being either fixed, preferred or unspecified
*/

reservation_request([Date, Time, Amount, Menu]) --> sentence([Date, Time, Amount, Menu] ) . 

/* The following sentences include all parts, alternatives where optional parts are left out are below.
    The alternatives are handled separately as allowing empty values for sentence parts would cause some of the following sentences to be equal and thus produce multiple true values in some cases. */
sentence([Date, Time, Amount, Menu]) --> 
	introduction_description,
	amount_description(Amount),
	time_description(Time),
	date_description(Date),
	menu_description(Menu),
	ending_description .

sentence([Date, Time, Amount, Menu]) --> 
	introduction_description,
	amount_description(Amount),
	menu_description(Menu),
	date_description(Date),
	time_description(Time),
	ending_description .

sentence([Date, Time, Amount, Menu]) --> 
	introduction_description,
	time_description(Time),
	amount_description(Amount),
	date_description(Date),
	menu_description(Menu),
	ending_description .

sentence([Date, Time, Amount, Menu]) --> 
	introduction_description,
	date_description(Date),
	time_description(Time),
	amount_description(Amount),
	menu_description(Menu),
	ending_description .

sentence([Date, Time, Amount, Menu]) --> 
	introduction_description,
	amount_description(Amount),
	date_description(Date),
	menu_description(Menu),
	time_description(Time),
	ending_description .


/* The following sentences include all parts except menu description. */
sentence([Date, Time, Amount, Menu]) --> 
	introduction_description,
	amount_description(Amount),
	time_description(Time),
	date_description(Date),
	no_menu_description(Menu),
	ending_description .

sentence([Date, Time, Amount, Menu]) --> 
	introduction_description,
	amount_description(Amount),
	date_description(Date),
	time_description(Time),
	no_menu_description(Menu),
	ending_description .

sentence([Date, Time, Amount, Menu]) --> 
	introduction_description,
	time_description(Time),
	amount_description(Amount),
	date_description(Date),
	no_menu_description(Menu),
	ending_description .

sentence([Date, Time, Amount, Menu]) -->
	introduction_description,
	date_description(Date),
	time_description(Time),
	amount_description(Amount),
	no_menu_description(Menu),
	ending_description .


/* The following sentences include all parts except time description. */
sentence([Date, Time, Amount, Menu]) --> 
	introduction_description,
	amount_description(Amount),
	date_description(Date),
	menu_description(Menu),
	no_time_description(Time),
	ending_description .

sentence([Date, Time, Amount, Menu]) -->
	introduction_description,
	amount_description(Amount),
	menu_description(Menu),
	date_description(Date),
	no_time_description(Time),
	ending_description .

sentence([Date, Time, Amount, Menu]) --> 
	introduction_description,
	date_description(Date),
	amount_description(Amount),
	menu_description(Menu),
	no_time_description(Time),
	ending_description .

/* The following sentences include all parts except time and menu description. */
sentence([Date, Time, Amount, Menu]) --> 
	introduction_description,
	amount_description(Amount),
	date_description(Date),
	no_menu_description(Menu),
	no_time_description(Time),
	ending_description .

sentence([Date, Time, Amount, Menu]) -->
	introduction_description,
	date_description(Date),
	amount_description(Amount),
	no_menu_description(Menu),
	no_time_description(Time),
	ending_description .


/* 
----------------------------------------------
|       NLP SYSTEM: NUMBER RECOGNIZERS       |
----------------------------------------------
*/

/* Succeeds when the parameter is equal to the parsed positive integer. */
positive_integer(X) --> [X], {integer(X), X > 0} .

/* Succeeds when the parameter is equal to the parsed nonegative integer. */
nonnegative_integer(X) --> [X], {integer(X), X >= 0} .

/* 
----------------------------------------------
|        NLP SYSTEM: DATE RECOGNIZERS        |
----------------------------------------------
*/

/* Succeeds when the parameter (Date = [Day, Month]) is equal to the parsed textual date description. */
date_description([Day, Month]) --> [on], date([Day, Month]) .
date_description([Day, Month]) --> [on, the], date([Day, Month]) .

/* Succeeds when the parameter (Date = [Day, Month]) is equal to the parsed textual representation of a date (e.g. 23/12, 23 march, ...). */
date([Day, Month]) --> day(Day), month(Month) .
date([Day, Month]) --> month(Month), day(Day) .
date([Day, Month]) --> day(Day), [of], month(Month) .
date([Day, Month]) --> month(Month), day(Day), [th] .
date([Day, Month]) --> day(Day), ['/'], month(Month) .
date([Day, Month]) --> day(Day), [th, of], month(Month) .

/* Succeeds when a correct day integer (1 - 31) is parsed and equal to its parameter. */
day(Day) --> [Day], { integer(Day), Day >= 1, Day =< 31 } .

/* Succeeds when parsed textual day (e.g. first) is equal to the integer representation in the parameter (e.g. first as 1).
	Note: since no examples from the given message inbox had this, only a couple are provided as proof-of-concept. */
day(Day) --> [StringDay], { StringDay = first, Day = 1 } .
day(Day) --> [StringDay], { StringDay = second, Day = 2 } .
day(Day) --> [StringDay], { StringDay = third, Day = 3 } .

/* Succeeds when a correct month integer (1 - 12) is parsed and equal to its parameter. */
month(Month) --> [Month], { integer(Month), Month >= 1, Month =< 12 } .

/* Succeeds when parsed textual month (e.g. march) is equal to integer representation in parameter (e.g. 3) */
month(Month) --> [StringMonth], { StringMonth = january, Month = 1} .
month(Month) --> [StringMonth], { StringMonth = february, Month = 2} .
month(Month) --> [StringMonth], { StringMonth = march, Month = 3} .
month(Month) --> [StringMonth], { StringMonth = april, Month = 4} .
month(Month) --> [StringMonth], { StringMonth = may, Month = 5} .
month(Month) --> [StringMonth], { StringMonth = june, Month = 6} .
month(Month) --> [StringMonth], { StringMonth = july, Month = 7} .
month(Month) --> [StringMonth], { StringMonth = august, Month = 8} .
month(Month) --> [StringMonth], { StringMonth = september, Month = 9} .
month(Month) --> [StringMonth], { StringMonth = october, Month = 10} .
month(Month) --> [StringMonth], { StringMonth = november, Month = 11} .
month(Month) --> [StringMonth], { StringMonth = december, Month = 12} .


/* 
----------------------------------------------
|        NLP SYSTEM: TIME RECOGNIZERS        |
----------------------------------------------
*/

/* Succeeds when the parameter (Time = [Hour, Minute, Preference]) is equal to the parsed textual time description. */
time_description([Hour, Minute, fixed]) --> [at], time([Hour, Minute]) .
time_description([Hour, Minute, preferred]) --> preference, [at], time([Hour, Minute])  .
no_time_description([_, _, unspecified]) --> [] .

/* Succeeds when the parameter (Time = [Hour, Minute]) is equal to the parsed 24 hour time representation (e.g. 14:00). */
time([Hour, Minute]) --> hour(Hour), [':'], minute(Minute) .

/* Succeeds when the parameter (Time = [Hour, Minute]) is equal to the parsed am/pm time representation (e.g. 8 pm or 8 pm 30). */
time([Hour, Minute]) --> hour(Hour), [am], minute(Minute) .
time([Hour, 0]) --> hour(Hour), [am] .

time([Hour, Minute]) --> hour_pm(Hour), [pm], minute(Minute) .
time([Hour, 0]) --> hour_pm(Hour), [pm] .

/* Succeeds when the parameter (Time = [Hour, Minute]) is equal to the parsed oclock representation (e.g. 7 oclock).
	NOTE: assumption is made that oclock is in the pm notation as this is the only time the restaurant is open. */
time([Hour, Minute]) --> hour_pm(Hour), [oclock], minute(Minute) .
time([Hour, 0]) --> hour_pm(Hour), [oclock] .

/* Succeeds when the paramater (Hour) is equal to textual represenatation) */
hour(Hour) -->[Hour], {integer(Hour), Hour > 0, Hour =< 23} .
hour_pm(Hour) --> 
	[RawHour], {integer(RawHour),
	RawHour >= 1, RawHour =< 12,
	Hour is RawHour + 12} .

/* Succeeds when the paramater (Minute) is equal to parsed textual represenatation. (e.g. 00) */
minute(Minute) --> [Minute], {integer(Minute), Minute >= 0, Minute =< 60} .


/* 
----------------------------------------------
|       NLP SYSTEM: AMOUNT RECOGNIZERS       |
----------------------------------------------
*/

/* Succeeds when the parameter (Amount) is equal to the parsed textual amount description. */
amount_description(Amount) --> [for], amount(Amount) .
amount_description(Amount) --> [for], amount(Amount), humans .
amount_description(Amount) --> [for, a, party, of], amount(Amount) .
amount_description(Amount) --> [for, a, party, of], amount(Amount), humans .
amount_description(Amount) --> amount(Amount), humans .
amount_description(Amount) --> [book], amount(Amount), humans, [in] .

/* Succeeds when the parameter (Amount) is equal to the parsed textual representation of a positive integer representing the amount. */
amount(Amount) --> positive_integer(Amount) .


/* 
----------------------------------------------
|        NLP SYSTEM: MENU RECOGNIZERS        |
----------------------------------------------
*/

/* Succeeds when the parameter (Menu) is equal to the parsed textual menu description. */
menu_description([Menu, fixed]) --> [for], article, menu(Menu), [menu] .
menu_description([Menu, preferred]) --> preference, [for], article, menu(Menu), [menu] .

menu_description([Menu, fixed]) --> [for], menu(Menu), [menu] .
menu_description([Menu, preferred]) --> preference, [for], menu(Menu), [menu] .

no_menu_description([_, unspecified]) --> [] .

/* Succeeds when the parameter (Menu) is equal to the textual representation of an allowed menu.
	This abstraction makes it easier to add more menus down the line. */
menu(Menu) --> [Menu], {Menu = theatre} .
menu(Menu) --> [Menu], {Menu = standard} .

/* 
----------------------------------------------
|     NLP SYSTEM: OTHER SENTENCE PARTS       |
----------------------------------------------

Since a message might contain a greeting and an ending, which don't contain any value, they can be handled pretty generally here.
Some other more general sentence parts are taken care of here as well.
*/

/* Succeeds when parsed text represent an introduction for the reservation, can be empty (e.g. we would like a table). */
introduction_description --> [] .
introduction_description --> greeting .
introduction_description --> gratitude .
introduction_description --> verb_description, noun_description .
introduction_description --> gratitude, verb_description, noun_description .
introduction_description --> greeting, verb_description, noun_description .
introduction_description --> greeting, gratitude, verb_description, noun_description .
introduction_description --> noun_description .

/* Succeeds when parsed text represent a verb part of a sentce (e.g. can we have). */
verb_description --> verb, pronoun, verb .
verb_description --> pronoun, verb .
verb_description --> verb, pronoun .

/* Succeeds when parsed text represent a noun part of a sentce (e.g. a table). */
noun_description --> article, noun .
noun_description --> noun .

/* Succeeds when parsed text represent an ending for the reservation, can be empty (e.g. thanks). */
ending_description --> [] .
ending_description --> gratitude .

/* Succeeds when parsed text represent a greeting */
greeting --> [hello] .
greeting --> [hi] .

/* Succeeds when parsed text represent a gratitude */
gratitude --> [please] .
gratitude --> [thanks] .
gratitude --> [thank, you] .

/* Succeeds when parsed text represent a pronoun */
pronoun --> [i] .
pronoun --> [we] .
pronoun --> [us] .

/* Succeeds when parsed text represent a verb (e.g. can, would, like) */
verb --> [can] .
verb --> [have] .
verb --> [would, like] .
verb --> [reserve] .
verb --> [book] .

/* Succeeds when parsed text represent an article (e.g. a, the) */
article --> [a] .
article --> [the] .

/* Succeeds when parsed text represent a noun (e.g. table, place) */
noun --> [table] .
noun --> [place] .
noun --> [spot] .
noun --> [reservation] .

/* Succeeds when parsed text represent a preference (e.g. preferably) */
preference --> [preferably] .
preference --> [prefering] .

/* Succeeds when parsed text represent a synonym for a group of humans (e.g. people, persons) */
humans --> [people] .
humans --> [persons] .
humans --> [person] .
humans --> [of, us] .


/* 
##################################################################
#                        TESTING NLP SYSTEM                      #
##################################################################

The code below is made available for easy testing of the NLP (DCG) system.
*/

test_dcg_sample_1(Result) :- is_processed_sms_inbox(List), nth1(1,List,Sample), reservation_request( Result, Sample, []) .
test_dcg_sample_2(Result) :- is_processed_sms_inbox(List), nth1(2,List,Sample), reservation_request( Result, Sample, []) .
test_dcg_sample_3(Result) :- is_processed_sms_inbox(List), nth1(3,List,Sample), reservation_request( Result, Sample, []) .
test_dcg_sample_4(Result) :- is_processed_sms_inbox(List), nth1(4,List,Sample), reservation_request( Result, Sample, []) .
test_dcg_sample_5(Result) :- is_processed_sms_inbox(List), nth1(5,List,Sample), reservation_request( Result, Sample, []) .
test_dcg_sample_6(Result) :- is_processed_sms_inbox(List), nth1(6,List,Sample), reservation_request( Result, Sample, []) .
test_dcg_sample_7(Result) :- is_processed_sms_inbox(List), nth1(7,List,Sample), reservation_request( Result, Sample, []) .
test_dcg_sample_8(Result) :- is_processed_sms_inbox(List), nth1(8,List,Sample), reservation_request( Result, Sample, []) .

test_dcg_sample_extra_1(Result) :- is_extra_processed_sms_inbox(List), nth1(1,List,Sample), reservation_request( Result, Sample, []) .
test_dcg_sample_extra_2(Result) :- is_extra_processed_sms_inbox(List), nth1(2,List,Sample), reservation_request( Result, Sample, []) .

test_dcg_sample_all() :- 
	test_dcg_sample_1( _ ),
   	test_dcg_sample_2( _ ),
   	test_dcg_sample_3( _ ),
   	test_dcg_sample_4( _ ),
   	test_dcg_sample_5( _ ),
   	test_dcg_sample_6( _ ),
   	test_dcg_sample_7( _ ),
   	test_dcg_sample_8( _ ),
   	test_dcg_sample_extra_1( _ ),
   	test_dcg_sample_extra_2( _ ) .

/* 
##################################################################
#                        CONSTRAINT SYSTEM                       #
##################################################################

The following code implements the CLP(FD), Constraint Logic Programming with Finite Domains, to perform the scheduling of the restaurant.
In Prolog one can think of the constraint system as part of the unifaction process.
Indeed, we associate a set of “allowed values” with each variable, and then any attempt to unify it with something “not allowed” will fail.
Doing this will "prune" the solution trees branches that are known to fail, due to the failed constraint, enhacing the execution speed.

A reservation is represented as [Id, Date, StartTime, Endtime, Amount, Menu, Table]:
   - Id: used to link reservation to original messsage - integer
   - Date: date for reservation - [Day, Month], both integer
   - StartTime: time the customer is expected to come - [Hour, Minute], both integer
   - EndTime: time the customer is expected to leave - [Hour, Minute], both integer
      - Note: this is in a way redundant but easy to have
   - Amount: number of people that have made a reservation - integer
   - Menu: menu for group - integer
   - Tables: assigned tables for group - [TableFor2, TableFor3, TableFor4], all boolean integers

The following concepts are constraint:
   - Time
      - Must be in opening hours
	  - Must be long enough for menu
   - Constraints for reservation tables
      - Tables must be able to seat all people

*/




/* 
----------------------------------------------
|                  CLP: Time                 |
----------------------------------------------

The below code is responsible for constraining the time variables of a reservation.
Remember that the restaurant (and kitchen) is open from 19:00 - 23:00.
The internal representation of a time variable is a list: [Hour, Minute], both being integers.
*/

/* Constraints for reservation time:
   - Must be in opening hours
   - Must be long enough for menu
 */
constrain_reservation_time([]) .

constrain_reservation_time([reservation(_, _, [StartHour, StartMinute], [EndHour, EndMinute], _, Menu, _) | OtherReservations]) :- 
	StartHour in 19..23,
	StartMinute in 0..60,
	EndHour in 19..23,
	EndMinute in 0..60,
	EndHour #>= StartHour,
	( EndHour #= 23 ) #==> ( EndMinute #= 0 ),
	( Menu #= 1 ) #==> ( EndHour - StartHour #= 2 ),
	( Menu #= 2 ) #==> ( EndHour - StartHour #= 1 ),
	( Menu in 1 .. 2 ) #==> ( StartMinute #= EndMinute ),
	constrain_reservation_time(OtherReservations) .

/* 
----------------------------------------------
|                 CLP: Tables                |
----------------------------------------------

The below code is responsible for constraining the table variables of a reservation.
Remember that there are three tables with different capicities.
The internal representation of a table variable is a list: [TableFor2, TableFor3, TableFor4], all boolean integers
*/

/* Constraints for reservation tables:
   - Amount of people must not exceed maximum capacity (9)
   - Tables must be able to seat all people
 */
constrain_reservation_table([]) .

constrain_reservation_table([reservation(_, _, _, _, Amount, _, [TableFor2, TableFor3, TableFor4]) | OtherReservations]) :- 
	Amount in 1..9,
	TableFor2 in 0..1,
	TableFor3 in 0..1,
	TableFor4 in 0..1,
	TotalSeatingCapacity #= 2*TableFor2 + 3*TableFor3 + 4*TableFor4,
	TotalSeatingCapacity #>= Amount,
	constrain_reservation_table(OtherReservations) .