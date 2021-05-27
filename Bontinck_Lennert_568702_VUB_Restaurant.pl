/*Single loadable file for the Restaurant assignment.

The GitHub repository for this project is available at: https://github.com/pikawika/VUB-DP-Restaurant.
    It will be made public once the deadline of the assignment has passed to ensure it isn't fraudulently used by colleague students.

The created predicates were tested on an individual basis through the interpreter, making sure all returned answers are correct by backtracking as well (using ;).
	The README.md files contains these test queries used in the interpreter. The readme is best read through a markdown editor or directly on Github
	but a copy of the README file is provided as a huge comment at the bottom of this file.

Some things were assumed:
   - Since the text messages are said to be processed no operations such as downcase_atom (lowercase transformation) are done.
   - Since we could make the NLP portion endlessly big, it is made so that only the examples and very minor extra's are accepted.
      - These extra's are tested via is_test_processed_sms_inbox.
   - Since I'm no expert in linguistics the naming for different parts of sentences might be odd.
      - It is also possible to make weird sentences such as "book i can a table for 2" due to the division in verb.
   - No constraint needed for "Booking takes place at least a day before" (confirmed by Homer).

KNOWN BUGS:
   - sample 6 matches with mutiple due to empty values
   - sample 7 & 8 not working

STUDENT INFO:
	- Name: Bontinck Lennert
    - StudentID: 568702
    - Affiliation: VUB - Master Computer Science: AI 
*/

/* 
##################################################################
#                         LIBRARY IMPORTS                        #
##################################################################

The following code will import the required libraries:
		- lists: used since it's seen as the default library for basic lists operation. 
			The used documententation can be found here: https://www.swi-prolog.org/pldoc/man?section=lists.
*/

:- use_module( [library(lists)] ).

/* 
##################################################################
#                            SMS INBOX                           #
##################################################################

The following code provides the SMS inbox so that it can be easily used for testing purposes.
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

is_test_processed_sms_inbox( [[table,for,2,at,20,':',00,on,the,first,of,march],
								[table,for,2,on,the,first,of,march]] ) .


/* 
##################################################################
#                           NLP SYSTEM                           #
##################################################################

The following code implements the Definite Clause Grammars (DCGs).
DCGs are a facility in Prolog which makes it easy to define languages according to grammar rules.
DCGs will be used to link the following arguments with natural language sentences:
	- Date: day of reservation - [Day, Month] - both integer
	- Time: time of reservation - [Hour, Minute, Preference] - 2 integers and a constant being fixed, preferred or unspecified
	- Amount: number of people - integer
	- Menu: chosen menu - standard, theatre or unspecified - constant
*/

reservation_request( [Date, Time, Amount, Menu] ) --> sentence([Date, Time, Amount, Menu] ) . 

sentence( [Date, Time, Amount, Menu] ) --> introduction_description,
											amount_description(Amount),
											time_description(Time),
											date_description(Date),
											menu_description(Menu),
											ending_description .

sentence( [Date, Time, Amount, Menu] ) --> introduction_description,
											amount_description(Amount),
											menu_description(Menu),
											date_description(Date),
											time_description(Time),
											ending_description .

sentence( [Date, Time, Amount, Menu] ) --> introduction_description,
											time_description(Time),
											amount_description(Amount),
											date_description(Date),
											menu_description(Menu),
											ending_description .

sentence( [Date, Time, Amount, Menu] ) --> introduction_description,
											date_description(Date),
											time_description(Time),
											amount_description(Amount),
											menu_description(Menu),
											ending_description .



/* 
----------------------------------------------
|       NLP SYSTEM: NUMBER RECOGNIZERS       |
----------------------------------------------
*/

positive_integer(X) --> [X], {integer(X), X > 0} .

nonnegative_integer(X) --> [X], {integer(X), X >= 0} .

/* 
----------------------------------------------
|        NLP SYSTEM: DATE RECOGNIZERS        |
----------------------------------------------
*/

/* Succeeds when the parameter (Date = [Day, Month]) is equal to the parsed textual representation. */
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

/* Succeeds when parsed textual day (e.g. first) is equal to interger representation in parameter (e.g. 1).
	Note: since no examples from the given message inbox had this only a couple are provided as proof-of-concept. */
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

/* Succeeds when the parameter (Time = [Hour, Minute, Preference]) is equal to the parsed textual representation. */
time_description([Hour, Minute, fixed]) --> [at], time([Hour, Minute]) .
time_description([Hour, Minute, preferred]) --> [preferably, at], time([Hour, Minute])  .
time_description([_, _, unspecified]) --> [] .

/* Succeeds when the parameter (Time = [Hour, Minute]) is equal to the parsed 24 hour representation (e.g. 14:00). */
time([Hour, Minute]) --> hour(Hour), [':'], minute(Minute) .

/* Succeeds when the parameter (Time = [Hour, Minute]) is equal to the parsed am/pm representation (e.g. 8 pm or 8 pm 30). */
time([Hour, Minute]) --> hour(Hour), [am], minute(Minute) .
time([Hour, 0]) --> hour(Hour), [am] .

time([Hour, Minute]) --> hour_pm(Hour), [pm], minute(Minute) .
time([Hour, 0]) --> hour_pm(Hour), [pm] .

/* Succeeds when the paramater (Hour) is equal to textual represenatation) */
hour(Hour) --> [Hour], {integer(Hour), Hour > 0, Hour =< 23} .
hour_pm(Hour) --> [RawHour], {integer(RawHour),
								RawHour >= 1, RawHour =< 12,
								Hour is RawHour + 12} .

/* Succeeds when the paramater (Minute) is equal to textual represenatation) */
minute(Minute) --> [Minute], {integer(Minute), Minute >= 0, Minute =< 60} .




 

/* 
----------------------------------------------
|       NLP SYSTEM: AMOUNT RECOGNIZERS       |
----------------------------------------------
*/

/* Succeeds when the parameter (Amount) is equal to the parsed textual representation. */
amount_description(Amount) --> [for], amount(Amount) .
amount_description(Amount) --> [for], amount(Amount), [people] .
amount_description(Amount) --> [for], amount(Amount), [persons] .
amount_description(Amount) --> [for], amount(Amount), [person] .
amount_description(Amount) --> [for, a, party, of], amount(Amount).
amount_description(Amount) --> [for, a, party, of], amount(Amount), [people] .
amount_description(Amount) --> [for, a, party, of], amount(Amount), [persons] .
amount_description(Amount) --> [for, a, party, of], amount(Amount), [person] .
amount_description(Amount) --> amount(Amount), [people] .
amount_description(Amount) --> amount(Amount), [persons] .
amount_description(Amount) --> amount(Amount), [person] .

/* Succeeds when the parameter (Amount) is equal to the parsed textual representation of a positive integer. */
amount(Amount) --> positive_integer(Amount) .


/* 
----------------------------------------------
|        NLP SYSTEM: MENU RECOGNIZERS        |
----------------------------------------------
*/

/* Succeeds when the parameter (Menu) is equal to the parsed textual representation.
	If no menu is given, standard menu is preffered */
menu_description([_, unspecified]) --> [] .
menu_description([Menu, fixed]) --> [for, the], menu(Menu), [menu] .
menu_description([Menu, preferred]) --> [preferably, for, the], menu(Menu), [menu] .

/* Succeeds when the parameter (Menu) is equal to the textual representation of an allowed menu.
	This abstraction makes it easier to add more menus down the line. */
menu(Menu) --> [Menu], {Menu = theatre} .
menu(Menu) --> [Menu], {Menu = standard} .

/* 
----------------------------------------------
|    NLP SYSTEM: INTRODUCTION AND ENDING     |
----------------------------------------------

Since a message might contain a greeting and an ending, which don't contain any value, they can be handled pretty easy. 
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

/* Succeeds when parsed text represent a verb part of a sentce (e.g. a table). */
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





/* 
##################################################################
#                             TESTING                            #
##################################################################

The code below is made available for easy testing.
*/

test_dcg_sample_1( Result ) :- reservation_request( Result, [table,for,2,at,20,':',00,on,18,march], []) .
test_dcg_sample_2( Result ) :- reservation_request( Result, [please,can,we,have,a,table,for,3,for,the,theatre,menu,on,march,18,th], []) .
test_dcg_sample_3( Result ) :- reservation_request( Result, [we,would,like,a,table,for,5,preferably,at,8,pm,on,18,'/',03], []) .
test_dcg_sample_4( Result ) :- reservation_request( Result, [can,i,book,a,table,at,9,pm,for,2,people,on,the,18,th,of,march,for,the,standard,menu,please], []) .
test_dcg_sample_5( Result ) :- reservation_request( Result, [reserve,us,a,table,on,march,18,for,a,party,of,4,for,the,standard,menu], []) .
test_dcg_sample_6( Result ) :- reservation_request( Result, [9,people,on,18,th,of,march], []) .
test_dcg_sample_7( Result ) :- reservation_request( Result, [book,6,of,us,in,on,18,march,at,20,':',00], []) .
test_dcg_sample_8( Result ) :- reservation_request( Result, [reservation,for,7,on,march,18,preferably,for,standard,menu,at,7,oclock], []) .