/*Single loadable file for the Restaurant assignment.

The GitHub repository for this project is available at: https://github.com/pikawika/VUB-DP-Restaurant.
    It will be made public once the deadline of the assignment has passed to ensure it isn't fraudulently used by colleague students.

The created predicates were tested on an individual basis through the interpreter, making sure all returned answers are correct by backtracking as well (using ;).
	The README.md files contains these test queries used in the interpreter. The readme is best read through a markdown editor or directly on Github
	but a copy of the README file is provided as a huge comment at the bottom of this file.

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
	- Time: time of reservation - [Hour, Minute, Preference] - 2 integers and a constant being fixed, preferred or none
	- Amount: number of people - integer
	- Menu: chosen menu - standard, theatre or unspecified - constant
*/

reservation_request( [Date, Time, Amount, Menu] ) --> random_text,
														amount(Amount),
														time(Time),
														date(Date),
														menu(Menu) .





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

date([Day, Month]) --> [on], day(Day), month(Month) .
date([Day, Month]) --> [on, the], day(Day), [of], month(Month) .

/* Succeeds when a correct day integer (1 - 31) is parsed and equal to its parameter. */
day(Day) --> [Day], { integer(Day), Day > 0, Day < 32 } .

/* Succeeds when parsed textual day (e.g. first) is equal to interger representation in parameter (e.g. 1).
	Note: since no examples from the given message inbox had this only a couple are provided as proof-of-concept. */
day(Day) --> [RawDay], { downcase_atom(RawDay, StringDay),
							StringDay = first, Day = 1 } .
day(Day) --> [RawDay], { downcase_atom(RawDay, StringDay),
							StringDay = second, Day = 2 } .
day(Day) --> [RawDay], { downcase_atom(RawDay, StringDay),
							StringDay = third, Day = 3 } .

/* Succeeds when parsed textual month (e.g. march) is equal to integer representation in parameter (e.g. 3) */
month(Month) --> [RawMonth], { downcase_atom(RawMonth, StringMonth),
								StringMonth = january, Month = 1} .
month(Month) --> [RawMonth], { downcase_atom(RawMonth, StringMonth),
								StringMonth = february, Month = 2} .
month(Month) --> [RawMonth], { downcase_atom(RawMonth, StringMonth),
								StringMonth = march, Month = 3} .
month(Month) --> [RawMonth], { downcase_atom(RawMonth, StringMonth),
								StringMonth = april, Month = 4} .
month(Month) --> [RawMonth], { downcase_atom(RawMonth, StringMonth),
								StringMonth = may, Month = 5} .
month(Month) --> [RawMonth], { downcase_atom(RawMonth, StringMonth),
								StringMonth = june, Month = 6} .
month(Month) --> [RawMonth], { downcase_atom(RawMonth, StringMonth),
								StringMonth = july, Month = 7} .
month(Month) --> [RawMonth], { downcase_atom(RawMonth, StringMonth),
								StringMonth = august, Month = 8} .
month(Month) --> [RawMonth], { downcase_atom(RawMonth, StringMonth),
								StringMonth = september, Month = 9} .
month(Month) --> [RawMonth], { downcase_atom(RawMonth, StringMonth),
								StringMonth = october, Month = 10} .
month(Month) --> [RawMonth], { downcase_atom(RawMonth, StringMonth),
								StringMonth = november, Month = 11} .
month(Month) --> [RawMonth], { downcase_atom(RawMonth, StringMonth),
								StringMonth = december, Month = 12} .


/* 
----------------------------------------------
|        NLP SYSTEM: TIME RECOGNIZERS        |
----------------------------------------------
*/

time([Hour, Minute, fixed]) --> [at], positive_integer(Hour), [':'],  nonnegative_integer(Minute) .
time([Hour, Minute, preferred]) --> [preferably, at], positive_integer(Hour), [':'],  nonnegative_integer(Minute) .
time([_, _, none]) --> [] .

/* 
----------------------------------------------
|       NLP SYSTEM: AMOUNT RECOGNIZERS       |
----------------------------------------------
*/

amount(Amount) --> [for], positive_integer(Amount).


/* 
----------------------------------------------
|        NLP SYSTEM: MENU RECOGNIZERS        |
----------------------------------------------
*/

menu(unspecified) --> [] .

/* 
----------------------------------------------
|          NLP SYSTEM: TEXT SKIPPER          |
----------------------------------------------

Since a message might contain irrelevant information the following can be used to filter it out.
This is usefull for skipping a greeting (e.g. 'hello I would like to'). 
*/

random_text --> [] .
random_text --> [_], random_text .

