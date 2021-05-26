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

This code block will iport the required libraries:
		- lists: used since it's seen as the default library for basic lists operation. 
			The used documententation can be found here: https://www.swi-prolog.org/pldoc/man?section=lists.
*/

:- use_module( [library(lists)] ).

/* 
##################################################################
#                            SMS INBOX                           #
##################################################################

This code block provides the SMS inbox so that it can be easily used for testing purposes.
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



/* 
##################################################################
#                           NLP SYSTEM                           #
##################################################################

This code block implements the Definite Clause Grammars (DCGs).
DCGs are a facility in Prolog which makes it easy to define languages according to grammar rules.
DCGs will be used as tool to perform Natural Language Processing (NLP) on the pre-processed sentences.
It will convert the natural sentences from an SMS message to the following list of important information:
	- Date: day of reservation - [Day, Month]
	- Time: time of reservation - [Hour, Minute]
	- Amount: number of people - integer
	- Menu: chosen menu - standard, theatre or either
*/

reservation_request( [[Day, Month], [Hour, Minute], Amount, either] ) --> [table, for], positive_integer(Amount),
																			[at],
																			positive_integer(Hour), [':'],  nonnegative_integer(Minute),
																			[on],
																			positive_integer(Day),
																			month(Month) .

positive_integer(X) --> [X], {integer(X), X > 0} .

nonnegative_integer(X) --> [X], {integer(X), X >= 0} .

month(Month) --> [RawMonth], {RawMonth = march, Month = 3} .