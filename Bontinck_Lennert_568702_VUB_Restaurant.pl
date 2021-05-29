/*Single loadable file for the Restaurant assignment.

The GitHub repository for this project is available at: https://github.com/pikawika/VUB-DP-Restaurant.
    To ensure it isn't fraudulently used by colleague students please send a request via email to join this repo.

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
   - The constraint system does not used the "preference" information extracted by the NLP
      - Thus all bounded menu's and times are seen as "fixed"
      - This causes a false since double booking occurs
   - It takes a long time to perform the scheduling on the provided set (when disabling the preffered entries from the given sms inbox due to above bug)
      - Goes instantly on custom extra SMS set
	  - Each individual case can be tested from provided set which does yield correct result -> see tests given as test_textual_output_sample_XXX methods (e.g. test_textual_output_sample_1)
   - ffc is used instead of an optimisation such as the wasted_space minimizer that is provided but non functional due to non ground error.

   --> All of these errors are related to the constraint system which works for the extra given samples. I hope this is taken into consideration when marking the other components of the system that do seem to work completely.

STUDENT INFO:
    - Name: Bontinck Lennert
    - Student ID: 568702
    - Affiliation: VUB - Master Computer Science: AI 
	- Email: lennert.bontinck@vub.be
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
#                       GENERAL PREDICATES                       #
##################################################################

Some global queries to ensure uniformity.
*/

/* Succeeds when the first parameter is the integer representation of the second parameter's menu term */
is_menu(1, standard) .
is_menu(2, theatre) .

/* Succeeds when the first parameter is the integer representation of the second parameter's preference term  */
is_preference(1, fixed) .
is_preference(2, preferred) .
is_preference(3, unspecified) .

/* Succeeds when first parameter (MinuteSinceMidnight) is equal to the passed minutes since midnight for the given second parameter ([Hour, Minute]) */
minutes_since_midnight(MinuteSinceMidnight, [Hour, Minute]) :-
	MinuteSinceMidnight #= Hour*60 + Minute,
	Hour in 0..23,
	Minute in 0..59,
	labeling( [ffc], [MinuteSinceMidnight, Hour, Minute] ) .

/* Succeeds when the first parameter is equal to the passed minutes since midnight for opening times  */
is_opening_time(Time) :- minutes_since_midnight(Time, [19, 00]) .
is_closing_time(Time) :- minutes_since_midnight(Time, [23, 00]) .

/* Succeds when the only parameter represents the time rounding. This is done for performance reasons.
	E.g. if set to 60 the constraint system will check that the times a mutiple of 60 and thus a time where the minutes is 0. */
is_time_rounding(60) .

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
is_extra_processed_sms_inbox( [[table,for,2,at,20,':',00,on,the,first,of,april],
								[hi,can,i,book,a,place,at,8,pm,for,4,persons,on,the,first,of,april,for,the,theatre,menu,please],
								[table,for,3,at,8,pm,on,the,first,of,april,for,the,standard,menu,please]] ) .


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
   - Time: time of reservation - [Hour, Minute, Preference] - Hour and Minute are integers or unbounded and Preference is an integer representing preference
   - Amount: number of people - integer
   - Menu: chosen menu - [Menu, Preference] - Menu is an integer representing the Menu and Preference is also an integer representing preference
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
time_description([Hour, Minute, Preference]) --> [at], time([Hour, Minute]), {is_preference(Preference, fixed)} .
time_description([Hour, Minute, Preference]) --> preference, [at], time([Hour, Minute]), {is_preference(Preference, preferred)} .
no_time_description([_Hour, _Minute, Preference]) --> [], {is_preference(Preference, unspecified)} .

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
menu_description([Menu, Preference]) --> [for], article, menu(Menu), [menu], {is_preference(Preference, fixed)} .
menu_description([Menu, Preference]) --> preference, [for], article, menu(Menu), [menu], {is_preference(Preference, preferred)} .

menu_description([Menu, Preference]) --> [for], menu(Menu), [menu], {is_preference(Preference, fixed)} .
menu_description([Menu, Preference]) --> preference, [for], menu(Menu), [menu], {is_preference(Preference, preferred)} .

/* If no menu is specified, the standard menu is presupposed but not fixed */
no_menu_description([Menu, Preference]) --> [], {is_menu(Menu, standard), is_preference(Preference, preferred)} .

/* Succeeds when the parameter (Menu) is equal to the textual representation of an allowed menu.
	This abstraction makes it easier to add more menus down the line. */
menu(Menu) --> [RawMenu], {RawMenu = theatre, is_menu(Menu, RawMenu)} .
menu(Menu) --> [RawMenu], {RawMenu = standard, is_menu(Menu, RawMenu) } .

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
test_dcg_sample_extra_3(Result) :- is_extra_processed_sms_inbox(List), nth1(3,List,Sample), reservation_request( Result, Sample, []) .

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
   	test_dcg_sample_extra_2( _ ),
   	test_dcg_sample_extra_3( _ ) .

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
   - Time: time the customer is expected to come and leave and its preference - [StartTime, EndTime, TimePreference] - StartTime and EndTime represented in minutes since midnight (integer), TimePreference as integer representation
   - Amount: number of people that have made a reservation - integer
   - Menu: menu for group and it's preference - [Menu, MenuPreference] - both integer representation of the categorical values
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
|                  CLP: Menu                 |
----------------------------------------------

The below code is responsible for constraining the menu variables of a reservation.
Remember that the restaurant has 2 menu's currently, standard and theatre, both represented as integers.
NOTE: these constraints are a bit dull and perhaps redundant.
*/

/* Constraints for menu:
   - Must be a legal menu
   - Only one menu must be chosen
 */
constrain_reservation_request_menu([], []) .

constrain_reservation_request_menu([reservation_request(_Id, _Date, _Time, _Amount, [Menu, _MenuPreference], _Tables) | OtherReservationRequests], [ Menu | OtherVariablesForLabeling]) :- 
	Menu in 1..2,
	is_menu(StandardMenu, standard),
	is_menu(TheatreMenu, theatre),
	( Menu #= StandardMenu ) #<==> ( StandardMenuChosen ),
	( Menu #= TheatreMenu ) #<==> ( TheatreMenuChosen ),
	StandardMenuChosen + TheatreMenuChosen #= 1,	
	constrain_reservation_request_menu(OtherReservationRequests, OtherVariablesForLabeling) .


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
   - Time must be rounded to specified rounding
   - Must be long enough for menu
 */
constrain_reservation_request_time([], []) .

constrain_reservation_request_time([reservation_request(_Id, _Date, [StartTime, EndTime, _TimePreference], _Amount, [Menu, _MenuPreference], _Tables) | OtherReservationRequests], [ StartTime, EndTime, Menu | OtherVariablesForLabeling]) :- 
	is_opening_time(OpeningTime),
	is_closing_time(ClosingTime),
	StartTime in OpeningTime..ClosingTime,
	EndTime in OpeningTime..ClosingTime,
	EndTime #>= StartTime,
	
	is_time_rounding(TimeRounding),
	StartTime mod TimeRounding #= 0,
	EndTime mod TimeRounding #= 0,

	is_menu(StandardMenu, standard),
	is_menu(TheatreMenu, theatre),
	( Menu #= StandardMenu ) #==> ( EndTime - StartTime #= 120 ),
	( Menu #= TheatreMenu ) #==> ( EndTime - StartTime #= 60 ),
	
	constrain_reservation_request_time(OtherReservationRequests, OtherVariablesForLabeling) .

/* 
----------------------------------------------
|                 CLP: Tables                |
----------------------------------------------

The below code is responsible for constraining the table variables of a reservation.
Remember that there are three tables with different capicities.
Remember, the internal representation of a table variable is a list: [TableFor2, TableFor3, TableFor4], all boolean integers
*/

/* Constraints for reservation tables:
   - Amount of people must not exceed maximum capacity (9)
   - Tables must be able to seat all people
 */
constrain_reservation_request_table([], []) .

constrain_reservation_request_table([reservation_request(_Id, _Date, _Time, Amount, _Menu, [TableFor2, TableFor3, TableFor4]) | OtherReservationRequests], [ Amount, TableFor2, TableFor3, TableFor4 | OtherVariablesForLabeling]) :- 
	Amount in 1..9,
	
	TableFor2 in 0..1,
	TableFor3 in 0..1,
	TableFor4 in 0..1,
	TotalSeatingCapacity #= 2*TableFor2 + 3*TableFor3 + 4*TableFor4,
	TotalSeatingCapacity #>= Amount,
	
	constrain_reservation_request_table(OtherReservationRequests, OtherVariablesForLabeling) .

/* 
----------------------------------------------
|             CLP: Double booking            |
----------------------------------------------

The below code is responsible for constraining double booking of a table.
A table is double booked if a reservation's date and time overlapses with another reservation's date and time that has the same table assigned.
Remember, the internal representation of a table variable is a list: [TableFor2, TableFor3, TableFor4], all boolean integers
*/

/* In order to prevent double booking a double iterative process is performed:
	- First loop (constrain_reservation_request_double_booking_iter):
		- Initiate second loop with "already processed" reservation untill then
	- Second loop (constrain_reservation_request_double_booking_syncer):
		- Check if there are reservation that are already processed that occur on overlapping time
		- If that is the case, constrain that tables can not be shared
 */
constrain_reservation_request_double_booking( ReservationRequestList, VariablesForLabeling ) :- constrain_reservation_request_double_booking_iter([], ReservationRequestList, VariablesForLabeling) .

constrain_reservation_request_double_booking_iter(_ProcessedReservationRequestList, [], []) .

constrain_reservation_request_double_booking_iter(ProcessedReservationRequestList, [reservation_request(_Id, [Day, Month], [StartTime, EndTime, _TimePreference], _Amount, _Menu, [TableFor2, TableFor3, TableFor4]) | OtherReservationRequests], [ Day, Month, StartTime, EndTime, TableFor2, TableFor3, TableFor4 | OtherVariablesForLabeling]) :- 
	constrain_reservation_request_double_booking_syncer(ProcessedReservationRequestList, reservation_request(_, [Day, Month], [StartTime, EndTime, _], _, _, [TableFor2, TableFor3, TableFor4])), 

	append(ProcessedReservationRequestList, [reservation_request(_, [Day, Month], [StartTime, EndTime, _], _, _, [TableFor2, TableFor3, TableFor4])], NewProcessedReservationRequestList),
	constrain_reservation_request_double_booking_iter(NewProcessedReservationRequestList, OtherReservationRequests, OtherVariablesForLabeling) .


constrain_reservation_request_double_booking_syncer([], _ReservationRequestToSync) .

constrain_reservation_request_double_booking_syncer([reservation_request(_, [Day, Month], [StartTime, EndTime, _], _, _, [TableFor2, TableFor3, TableFor4]) | OtherReservationRequests ], reservation_request(_, [DayOfSync, MonthOfSync], [StartTimeOfSync, EndTimeOfSync, _], _, _, [TableFor2OfSync, TableFor3OfSync, TableFor4OfSync])) :-
	( Month #= MonthOfSync ) #<==> EqualMonth,
	( Day #= DayOfSync ) #<==> EqualDay,
	( StartTime #>= StartTimeOfSync #/\ StartTime #< EndTimeOfSync ) #<==> StartTimeOverlap,
	( EndTime #> StartTimeOfSync #/\ EndTime #=< EndTimeOfSync ) #<==> EndTimeOverlap,
	( EqualMonth #/\ EqualDay #/\ (StartTimeOverlap #\/ EndTimeOverlap) ) #<==> Overlap,

	( Overlap #/\ TableFor2 #= 1 ) #==> ( TableFor2 #\= TableFor2OfSync),
	( Overlap #/\ TableFor3 #= 1 ) #==> ( TableFor3 #\= TableFor3OfSync),
	( Overlap #/\ TableFor4 #= 1 ) #==> ( TableFor4 #\= TableFor4OfSync),
	constrain_reservation_request_double_booking_syncer(OtherReservationRequests, reservation_request(_, [DayOfSync, MonthOfSync], [StartTimeOfSync, EndTimeOfSync, _], _, _, [TableFor2OfSync, TableFor3OfSync, TableFor4OfSync])).

/* 
##################################################################
#                        CONVERSION SYSTEM                       #
##################################################################

The below code is responsible for converting between different stages of the system.
*/

/* 
----------------------------------------------
|                  SMS TO NLP                |
----------------------------------------------

The code below is responsible for linking SLS and NLP representations.


*/

/* Links a list of SMS messages to a list of NLP representations. */
sms_to_nlp( [], [] ) .

sms_to_nlp( [Sms | SmsRest], [Nlp | NlpRest] ) :-
	reservation_request( Nlp, Sms, []),
	sms_to_nlp(SmsRest, NlpRest) .


/* 
----------------------------------------------
|                  NLP TO CLP                |
----------------------------------------------

The code below is responsible for linking NLP and CLP representations.
*/


/* Links a list of NLP representations to a list of CLP representations.
	Id is the nth0 element location of the input NlpList.
	The CLP representation needs a different time notation for ease of use (minutes since midnight), whilst the NLP representation used its time representation for ease of reading (24 hour representation). */
nlp_to_clp( NlpList, ClpList ) :- nlp_to_clp_iter(0, NlpList, ClpList) .

nlp_to_clp_iter(_Id, [], []) .

nlp_to_clp_iter( Id, [[[Day, Month], [StartHour, StartMinute, TimePreference], Amount, [Menu, MenuPreference]] | NlpRest], [reservation_request(Id, [Day, Month], [StartTime, _ClpEndTime, TimePreference], Amount, [Menu, MenuPreference], _ClpTables) | ClpRest] ) :-
	minutes_since_midnight(StartTime, [StartHour, StartMinute]) ,
	NewId is Id + 1,
	nlp_to_clp_iter(NewId, NlpRest, ClpRest) .

/* 
----------------------------------------------
|              CLP TO RESERVATIONS           |
----------------------------------------------

The code below is responsible for performing the labeling on the CLP representation.
*/

/* Performs labeling using FFC and all constraints for the input list which is a CLP representation */
clp_labeling(ClpList) :-
	constrain_reservation_request_menu(ClpList, VariablesForLabelingMenu),
	constrain_reservation_request_table(ClpList, VariablesForLabelingTable),
	constrain_reservation_request_time(ClpList,VariablesForLabelingTime),
	constrain_reservation_request_double_booking(ClpList, VariablesForLabelingDoubleBooking),
	append([VariablesForLabelingMenu, VariablesForLabelingTable, VariablesForLabelingTime, VariablesForLabelingDoubleBooking], Variables),
	wasted_space(ClpList, _Minimization),
	labeling( [ffc], Variables ) .

wasted_space([], _Minimization) .

wasted_space([reservation_request(_Id, _Date, _Time, Amount, _Menu, [TableFor2, TableFor3, TableFor4]) | ClpRest], Minimization) :-
	TotalSeatingCapacity #= 2*TableFor2 + 3*TableFor3 + 4*TableFor4,
	NewMinimization #= Minimization + (TotalSeatingCapacity - Amount),
	wasted_space(ClpRest, NewMinimization) .

/* 
----------------------------------------------
|    RESERVATION REQUESTS TO RESERVATIONS    |
----------------------------------------------

The code below is responsible for converting reservation requests to reservation, note that this does nothing more then changing the leading term.
*/

/* Converts reservation requests to reservation by changing leading term */
reservationrequests_to_reservation([], []) .

reservationrequests_to_reservation([reservation_request(Id, Date, Time, Amount, Menu, Tables) | OtherReservationRequests], [reservation(Id, Date, Time, Amount, Menu, Tables) | OtherReservations]) :-
	reservationrequests_to_reservation(OtherReservationRequests, OtherReservations) .

/* 
----------------------------------------------
|             SMS TO RESERVATIONS            |
----------------------------------------------

The code below is responsible for converting the initial SMS list to a list of reservations
*/

/* Unifies SMS inbox with the made reservations */
sms_to_reservations(Sms, Reservations) :-
	sms_to_nlp( Sms, Nlp ),
	nlp_to_clp( Nlp, ReservationRequests),
	clp_labeling(ReservationRequests),
	reservationrequests_to_reservation(ReservationRequests, Reservations).


/* 
----------------------------------------------
|            ALL RESERVATIONS TO DAY         |
e----------------------------------------------

The code below is responsible for converting a list of reservations to a list of reservations on a specific day.
*/

/* Unifies a list of reservations with reservations made on a particular day */
reservations_on_day([], [], _Date) .

reservations_on_day([reservation(Id, [Day, Month], Time, Amount, Menu, Tables) | OtherReservations], [reservation(Id, [Day, Month], Time, Amount, Menu, Tables) | OtherReservationsOnDay], [Day, Month]) :-
	reservations_on_day(OtherReservations, OtherReservationsOnDay, [Day, Month]) .

reservations_on_day([reservation(_, [DayNotMatched, MonthNothEqual], _, _, _, _) | OtherReservations], OtherReservationsOnDay, [Day, Month]) :-
	( DayNotMatched \= Day ; MonthNothEqual \= Month ),
	reservations_on_day(OtherReservations, OtherReservationsOnDay, [Day, Month]) .

/* 
----------------------------------------------
|           TABLES TO TEXTUAL TABLES         |
----------------------------------------------

The code below is responsible for converting an internal table representation to a textual one
*/

/* Sort reservation on time (thus not date): TODO */
internal_to_textual_table_representaiton([0, 0, 1], "the table for four") .
internal_to_textual_table_representaiton([0, 1, 0], "the table for three") .
internal_to_textual_table_representaiton([0, 1, 1], "the table for three and four") .
internal_to_textual_table_representaiton([1, 0, 0], "the table for two") .
internal_to_textual_table_representaiton([1, 0, 1], "the table for two and fout") .
internal_to_textual_table_representaiton([1, 1, 0], "the table for two and three") .
internal_to_textual_table_representaiton([1, 1, 1], "all tables") .


/* 
----------------------------------------------
|             ORDERING RESERVATIONS          |
----------------------------------------------

The code below is responsible for ordering reservations. It is modified from the British Museum sort seen during the lectures.
*/

/* Sort reservation on time (thus not date): TODO */
order_reservations_on_day(Reservations, Reservations, _Day) .


/* 
##################################################################
#                          DISPLAY SYSTEM                        #
##################################################################

The below code is responsible for displaying the results.
*/

/* Prints the reservations of a specified date [Day, Month] in a textual manner. */
textual_display_reservations_on_day(Sms, Reservations, [Day, Month]) :-
	reservations_on_day(Reservations, ReservationsOnDay, [Day, Month]),
	order_reservations_on_day(ReservationsOnDay, OrderedReservations, [Day, Month]),
	write( '\n\n' ),
	writef( '------------------------------------------ Restaurant XX planning of %t/%t ------------------------------------------', [Day, Month]),
	write( '\n\n' ),
	textual_print_reservations(Sms, OrderedReservations),
	write( '-------------------------------------------- Copyright Lennert Bontinck -------------------------------------------' ),
	write( '\n\n' ) .

/* Prints a list of reservations in a textual manner */
textual_print_reservations(_Sms, []) .

textual_print_reservations(Sms, [reservation(_Id, _Date,  [StartTime, EndTime, _TimePreference], Amount, [Menu, _MenuPreference], Tables) | OtherReservations]) :-
	minutes_since_midnight(StartTime, [StartHour, StartMinute]),
	minutes_since_midnight(EndTime, [EndHour, EndMinute]),
	is_menu(Menu, NaturalLangMenu),
	internal_to_textual_table_representaiton(Tables, TextualTables),
	writef( 'At %th%t, %t people will arive. They will have the %t menu and sit at %w. They will leave at %th%t.', [StartHour, StartMinute, Amount, NaturalLangMenu, TextualTables, EndHour, EndMinute]),
	write( '\n\n' ),
	textual_print_reservations(Sms, OtherReservations) .

/* Prints the reservations collected from the extra sms inbox on a specified date.
	Uses a cut to not allow backtracking for displaying, as proposed by the assignment.  */
textual_print_reservations_from_extra_sms([Day, Month]) :-
	is_extra_processed_sms_inbox( Sms ),
	sms_to_reservations( Sms, Reservations ),
	textual_display_reservations_on_day(Sms, Reservations, [Day, Month]),
	! .

/* Prints the reservations collected from the provided sms inbox on a specified date.
	Uses a cut to not allow backtracking for displaying, as proposed by the assignment.  */
textual_print_reservations_from_provided_sms([Day, Month]) :-
	is_processed_sms_inbox( Sms ),
	sms_to_reservations( Sms, Reservations ),
	textual_display_reservations_on_day(Sms, Reservations, [Day, Month]),
	! .

/* 
##################################################################
#                      TESTING OUTPUT SYSTEM                     #
##################################################################

The code below is made available for easy testing of the output system.
*/

test_textual_output_sample_1([Day, Month]) :- is_processed_sms_inbox( Sms ), nth1(1,Sms, FilteredSms), sms_to_reservations( [FilteredSms], Reservations ), textual_display_reservations_on_day([FilteredSms], Reservations, [Day, Month]), ! .
test_textual_output_sample_2([Day, Month]) :- is_processed_sms_inbox( Sms ), nth1(2,Sms, FilteredSms), sms_to_reservations( [FilteredSms], Reservations ), textual_display_reservations_on_day([FilteredSms], Reservations, [Day, Month]), ! .
test_textual_output_sample_3([Day, Month]) :- is_processed_sms_inbox( Sms ), nth1(3,Sms, FilteredSms), sms_to_reservations( [FilteredSms], Reservations ), textual_display_reservations_on_day([FilteredSms], Reservations, [Day, Month]), ! .
test_textual_output_sample_4([Day, Month]) :- is_processed_sms_inbox( Sms ), nth1(4,Sms, FilteredSms), sms_to_reservations( [FilteredSms], Reservations ), textual_display_reservations_on_day([FilteredSms], Reservations, [Day, Month]), ! .
test_textual_output_sample_5([Day, Month]) :- is_processed_sms_inbox( Sms ), nth1(5,Sms, FilteredSms), sms_to_reservations( [FilteredSms], Reservations ), textual_display_reservations_on_day([FilteredSms], Reservations, [Day, Month]), ! .
test_textual_output_sample_6([Day, Month]) :- is_processed_sms_inbox( Sms ), nth1(6,Sms, FilteredSms), sms_to_reservations( [FilteredSms], Reservations ), textual_display_reservations_on_day([FilteredSms], Reservations, [Day, Month]), ! .
test_textual_output_sample_7([Day, Month]) :- is_processed_sms_inbox( Sms ), nth1(7,Sms, FilteredSms), sms_to_reservations( [FilteredSms], Reservations ), textual_display_reservations_on_day([FilteredSms], Reservations, [Day, Month]), ! .
test_textual_output_sample_8([Day, Month]) :- is_processed_sms_inbox( Sms ), nth1(8,Sms, FilteredSms), sms_to_reservations( [FilteredSms], Reservations ), textual_display_reservations_on_day([FilteredSms], Reservations, [Day, Month]), ! .