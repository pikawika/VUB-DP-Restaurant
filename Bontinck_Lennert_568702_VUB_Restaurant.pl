/*

The GitHub repository for this project is available at: https://github.com/pikawika/VUB-DP-Restaurant.
    To ensure it isn't fraudulently used by colleague students please send a request via email with your GitHub username to join this repo if desired.



The created code was tested on an incremental basis through the interpreter.
   - The README.md file contains these test queries used in the interpreter.
      - The readme is best read through a markdown editor or directly on Github but a copy of the README file is provided as a huge comment at the bottom of this file.
   - Some predicates were made to make testing easy through a "one line" query.



To test the whole system by generating the final planning, one can use the following query to print the planning for the provided SMS messages on the 18th of march.
The output of this exact query is also given at the bottom of this file as a copy-paste from the terminal.
    textual_print_reservations_from_provided_sms([18,3]) .




Testing performed (see README) and general content of system:
   - GENERAL PREDICATES:
      - minutes_since_midnight
         - Tests link between [Hour, Minute] format and MinutesSinceMidNight format.
   - SMS INBOX:
      - Simple unifications for is_processed_sms_inbox and is_extra_processed_sms_inbox.
   - NLP SYSTEM:
      - date
         - Tests link from different natural language inputs (e.g. [first,of,april]) to internal [Month, Day] representation of date.
      - time, amount, menu
         - Tested in the same manner as the date.
      - reservation_request
         - Made helpful test predicates to link SMS inbox message to extracted values, this tests the whole NLP system.
         - use query: test_dcg_sample_XXX( Result ) . 
            --> with XXX in 1..8
         - use query: test_dcg_sample_extra_XXX( Result ) . 
            --> with XXX in 1..3 
      - Automated DCG part testing
         - The DCG part can be tested in a more automated way by checking whether the following predicates return true
            - test_dcg_sample_XXX_passes() . with XXX in 1..8
            - test_dcg_sample_all() .
   - CONSTRAINT SYSTEM:
      - constrain_reservation_request_menu
         - Test constraints for the menu to be a singular allowed menu.
      - constrain_reservation_request_time
         - Test constraints for time (StartTime and EndTime):
            - Must be in opening hours.
            - Time must be rounded to specified rounding from is_time_rounding (e.g. time rounding = 60, all times must be at round hour thus with minutes = 0).
            - Must be long enough for the menu.
      - constrain_reservation_request_table
         - Tests constraints for tables:
            - Amount of people must not exceed maximum capacity (9).
            - Reserved tables must be able to seat all people.
            - Edge case: no tables are assigned since the reservation is rejected. 
      - constrain_reservation_request_double_booking
         - Tests constraints for double booking so that no table is booked twice during the same time.
   - CONVERSION SYSTEM:
      - sms_to_nlp
         - Test if the list of SMS messages links correctly with the list of NLP representations
      - nlp_to_clp
         - Test if the list of NLP representations links correctly with CLPFD reservation requests representation
      - clp_labeling
         - Test if the input list of reservation requests is labelled.
      - wasted_space
         - Test if the assignment of the table with lesser wasted space is indeed performed.
      - total_amount, total_rejections & minimizer
         - total_amount: Test if the assignment of most people is indeed performed.
         - total_rejections: Test if the assignment of least rejections is indeed performed.
         - These were done by testing minimizer which is used for labelling and combines wasted_space and total_amount.
         - The by default enabled faster minimizer uses only the total_amount maximizer, thus it can be validated distinctly as well.
      - sms_to_reservations
         - Tests if SMS inbox can be linked with the made reservations correctly, chaining together all systems.
      - reservations_on_day
         - Tests if the list of reservations on a specific day can indeed be linked to the list of reservations.
      - sort_reservations
         - Tests if the list of reservations does indeed sort correctly based on month>day>start time> end time.
         - Uses a modified version of British museum sort from the lectures.
   - OUTPUT SYSTEM:
      - textual_display_reservations_on_day
         - Test if the list of reservations is displayed correctly for a given day.
      - textual_print_reservations_from_extra_sms
         - Test if the list of reservations is displayed correctly from the extra SMS inbox on a given day.
      - textual_print_reservations_from_provided_sms
         - Test if the list of reservations is displayed correctly from the given SMS inbox on a given day.
      - textual_print_reservations_from_provided_sms
         - Made helpful test predicates to test print of individual samples from the given SMS inbox.
         - use query: test_textual_output_sample_XXX( ([18,3]) ) . 
            --> with XXX in 1..8



Some assumptions and general remarks:
   - Since the text messages are said to be processed no "fool proof" operations such as downcase_atom (lowercase transformation) are done.
   - Since we could make the NLP portion endlessly big, it is "only" ensured the structures as the examples and some extra's are accepted.
      - This means some assumptions, such as the time_description requiring "at" to be present, are made. These are obvious and mentioned where the descriptions are formulated.
   - Since I'm no expert in linguistics the naming for different parts of sentences might be odd.
      - It is also possible to make weird sentences such as "book I can a table for 2" since both "book" and "can" are seen as a verb.
   - No constraint is needed for checking "Booking takes place at least a day before" (confirmed by Homer).
   - Remarks on the following sentence of the provided SMS inbox: "preferably for the standard menu at 7 o'clock"
      - 7 o'clock is 7 pm since the restaurant is not open in the morning.
      - "preferable" is concerning the standard menu, not the time since it is situated before the menu. Thus menu also has the option to be "preferred".



Known "bad" things about the code:
   - The constraint system DOES WORK with "preference" information but behaves identically for a preferred menu/time and a menu/time that is not specified.
      - If the restaurant would wish to take the preference into account it quite simply could add a reified constraint to get a truth value on weither the preference is fulfilled
      and take that variable into consideration for labeling, however this would even further slow down the code as mentioned below.
   - The system uses three variables for minimisation, this causes the conversion from SMS messages to the final result to take +- 25 minutes for the provided SMS set.
      - Using the extra SMS inboxes, this process is a manner of seconds.
      - Using the minimizer_faster (enabled by default in clp_labeling), which only looks at maximizing the amount of people seated, the process takes about a minute.



During the WPO it was asked if a TypeScript is needed, which the answer was "no, as long as you have clear examples and their output".
         --> These are the examples and output that are available in the README.md, a copy of which is at the bottom of this file
         --> The output for the given SMS inbox converted to reservations is also provided at the bottom as a copy-paste from the terminal



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

This section will provide some global predicates to ensure uniformity and ease of extension.
*/

/* Succeeds when the first parameter is the integer representation of the second parameter's menu and the time in minutes it takes to consume. */
is_menu(1, standard, 120) .
is_menu(2, theatre, 60) .

/* Succeeds when the parameter is the maximum integer representation a menu */
is_max_menu(2) .



/* Succeeds when the first parameter is the integer representation of the second parameter's preference  */
is_preference(1, fixed) .
is_preference(2, preferred) .
is_preference(3, unspecified) .

/* Succeeds when the parameter is the maximum integer representation a preference */
is_max_preference(3) .



/* Succeeds when first parameter (MinuteSinceMidnight) is equal to the passed minutes since midnight for the given second parameter ([Hour, Minute]) */
minutes_since_midnight(MinuteSinceMidnight, [Hour, Minute]) :-
	MinuteSinceMidnight #= Hour*60 + Minute,
	Hour in 0..23,
	Minute in 0..59,
	labeling( [ffc], [MinuteSinceMidnight, Hour, Minute] ) .



/* Succeeds when the first parameter is equal to the passed minutes since midnight for opening times  */
is_opening_time(Time) :- minutes_since_midnight(Time, [19, 00]) .
is_closing_time(Time) :- minutes_since_midnight(Time, [23, 00]) .



/* Succeds when the parameter represents the time rounding. This is done for performance reasons.
	E.g. if set to 60 the constraint system will check that reservation times are mutiple of 60 and thus times where the minutes are equal to 0. */
is_time_rounding(60) .











/* 
##################################################################
#                            SMS INBOX                           #
##################################################################

This section will provide the pre-processed SMS inboxes so they can be easily used for testing purposes.
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



/* Succeeds when its argument represents the extra pre-processed sms inbox provided by me to demonstrate generality.
	Very simple dataset for easy testing. */
is_extra_processed_sms_inbox( [[table,for,2,at,20,':',00,on,the,first,of,december],
								[hi,can,i,book,a,place,at,8,pm,for,4,persons,on,the,first,of,december,for,the,theatre,menu,please],
								[table,for,3,at,8,pm,on,the,first,of,december,for,the,standard,menu,please]] ) .



/* Succeeds when its argument represents the second extra pre-processed sms inbox provided by me to demonstrate generality.
	Slightly more challanging dataset for testing. */
is_extra_processed_sms_inbox2( [[table,for,2,at,21,':',00,on,the,first,of,december],
								[table,for,2,at,20,':',00,on,the,first,of,december,preferably,for,the,standard,menu],
								[4,of,us,on,1,'/',12,preferably,at,8,pm],
								[hi,can,i,book,a,place,at,9,pm,for,4,persons,on,the,first,of,december,for,the,theatre,menu,please],
								[table,for,3,at,8,pm,on,the,first,of,december,for,the,standard,menu,please]] ) .










/* 
##################################################################
#                           NLP SYSTEM                           #
##################################################################

This section will provide the Definite Clause Grammars (DCGs).
DCGs are a facility in Prolog which makes it easy to define languages according to grammar rules.

In our system the accepted language consists of a few major parts which can be in different orders:
   - introduction description: introductory part of the sentence. (e.g. "we would like to order a table")
   - amount_description: part of the sentence that specifies the number of people. (e.g. "for 2 people")
   - time_description: part of the sentence that specifies the time of the reservation, can be non-specified. (e.g. "at 8 pm")
   - date_description: part of the sentence that specifies the date of the reservation. (e.g. "on the first of march")
   - menu_description: part of the sentence that specifies the preferred menu, can be non-specified. (e.g. "for the standard menu")
   - ending_description: ending part of the sentence. (e.g. "thank you")

A reservation request is a natural language sentence having (some of) the above parts, from which the following arguments can be extracted:
   - Date: day of reservation - [Day, Month] - both integer.
   - Time: time of reservation - [StartTime, Preference] - StartTime is an integer or unbounded and represents the time past in minutes since midnight (00:00), Preference is an integer representing preference.
   - Amount: number of people - integer.
   - Menu: chosen menu - [Menu, Preference] - Menu is an integer representing the Menu and Preference is also an integer representing preference.
*/

/* A reservation request is a recognized sentence. */
reservation_request([Date, Time, Amount, Menu]) --> sentence([Date, Time, Amount, Menu] ) . 

/* The following sentences include all parts, alternatives where optional parts are left out are below.
    --> The alternatives are handled separately as allowing empty values for sentence parts would cause some of the following sentences to be equal and thus produce multiple true values in some cases. */
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

Some basic number recognizers are given below.
*/

/* Succeeds when the parameter is equal to the parsed positive integer. */
positive_integer(X) --> [X], {integer(X), X > 0} .

/* Succeeds when the parameter is equal to the parsed nonegative integer. */
nonnegative_integer(X) --> [X], {integer(X), X >= 0} .





/* 
----------------------------------------------
|        NLP SYSTEM: DATE RECOGNIZERS        |
----------------------------------------------

This subsection takes care of the date_description recognition.
It should detect Day and month.
For this to work a date description should start with "on" or "on the" followed by a different array of date formats supported.
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

This subsection takes care of the time_description recognition.
It should detect StarTime in minutes since midnight and the preference being "fixed", "preferred" or "unspecified" represented as an integer.
For this to work a time description should start with "at" or "<preference word> at" followed by a different array of time formats supported.
NOTE: since we're defining a grammar, a correct hour does not have to take into account the opening hours of the restaurant.
*/

/* Succeeds when the parameter (Time = [StartTime, Preference]) is equal to the parsed textual time description.
	StartTime is represented as minutes since midnight in its final form as this will make the final system easier to work with. */
time_description([StartTime, Preference]) --> 
	[at], time([Hour, Minute]),
	{minutes_since_midnight(StartTime, [Hour, Minute]), is_preference(Preference, fixed)} .

time_description([StartTime, Preference]) --> 
	preference, [at], time([Hour, Minute]),
	{minutes_since_midnight(StartTime, [Hour, Minute]), is_preference(Preference, preferred)} .

no_time_description([_StartTime, Preference]) --> [], {is_preference(Preference, unspecified)} .



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

This subsection takes care of the amount_description recognition.
It should detect the number of people that want to make a reservation.
Multiple descriptions are accepted to support the given SMS inbox.
NOTE: since we're defining a grammar, a maximum amount does not have to be taken into account.
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

This subsection takes care of the menu_description recognition.
It should detect the menu and preference for that menu.
This assumes the following format: "<optional preference word> <optional article> <supported menu> menu"
NOTE: here we do take into account that the menu has to be from the restaurant, since allowing it to be anything would also allow "junk".
*/

/* Succeeds when the parameter (Menu) is equal to the parsed textual menu description. */
menu_description([Menu, Preference]) --> [for], article, menu(Menu), [menu], {is_preference(Preference, fixed)} .
menu_description([Menu, Preference]) --> preference, [for], article, menu(Menu), [menu], {is_preference(Preference, preferred)} .

menu_description([Menu, Preference]) --> [for], menu(Menu), [menu], {is_preference(Preference, fixed)} .
menu_description([Menu, Preference]) --> preference, [for], menu(Menu), [menu], {is_preference(Preference, preferred)} .

no_menu_description([_Menu, Preference]) --> [], {is_preference(Preference, unspecified)} .



/* Succeeds when the parameter (Menu) is equal to the textual representation of an allowed menu.
	This abstraction makes it easier to add more menus down the line and ensures no "junk" is entered. */
menu(Menu) --> [RawMenu], {RawMenu = theatre, is_menu(Menu, RawMenu, _)} .
menu(Menu) --> [RawMenu], {RawMenu = standard, is_menu(Menu, RawMenu, _) } .





/* 
----------------------------------------------
|     NLP SYSTEM: OTHER SENTENCE PARTS       |
----------------------------------------------

Since a message might contain a greeting and an ending, which don't contain any value, they can be handled pretty generally.
This is taken care of in this subsection.
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



/* Succeeds when parsed text represent a verb (e.g. can, have) */
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

This section will provide some predicates for easy testing of the NLP (DCG) system.
test_dcg_sample_XXX are created for manual validation.
test_dcg_sample_1_passes() and test_dcg_sample_all()  are created for "automated" validation.
*/

test_dcg_sample_1(Result) :- is_processed_sms_inbox(List), nth1(1,List,Sample), reservation_request( Result, Sample, []) .
test_dcg_sample_1_passes() :- is_processed_sms_inbox(List), nth1(1,List,Sample), reservation_request( Result, Sample, []), Result = [[18, 3], [1200, 1], 2, [_, 3]].

test_dcg_sample_2(Result) :- is_processed_sms_inbox(List), nth1(2,List,Sample), reservation_request( Result, Sample, []) .
test_dcg_sample_2_passes() :- is_processed_sms_inbox(List), nth1(2,List,Sample), reservation_request( Result, Sample, []), Result = [[18, 3], [_, 3], 3, [2, 1]].

test_dcg_sample_3(Result) :- is_processed_sms_inbox(List), nth1(3,List,Sample), reservation_request( Result, Sample, []) .
test_dcg_sample_3_passes() :- is_processed_sms_inbox(List), nth1(3,List,Sample), reservation_request( Result, Sample, []), Result = [[18, 3], [1200, 2], 5, [_, 3]].

test_dcg_sample_4(Result) :- is_processed_sms_inbox(List), nth1(4,List,Sample), reservation_request( Result, Sample, []) .
test_dcg_sample_4_passes() :- is_processed_sms_inbox(List), nth1(4,List,Sample), reservation_request( Result, Sample, []), Result = [[18, 3], [1260, 1], 2, [1, 1]] .

test_dcg_sample_5(Result) :- is_processed_sms_inbox(List), nth1(5,List,Sample), reservation_request( Result, Sample, []) .
test_dcg_sample_5_passes() :- is_processed_sms_inbox(List), nth1(5,List,Sample), reservation_request( Result, Sample, []), Result = [[18, 3], [_, 3], 4, [1, 1]] .

test_dcg_sample_6(Result) :- is_processed_sms_inbox(List), nth1(6,List,Sample), reservation_request( Result, Sample, []) .
test_dcg_sample_6_passes() :- is_processed_sms_inbox(List), nth1(6,List,Sample), reservation_request( Result, Sample, []), Result = [[18, 3], [_, 3], 9, [_, 3]] .

test_dcg_sample_7(Result) :- is_processed_sms_inbox(List), nth1(7,List,Sample), reservation_request( Result, Sample, []) .
test_dcg_sample_7_passes() :- is_processed_sms_inbox(List), nth1(7,List,Sample), reservation_request( Result, Sample, []), Result = [[18, 3], [1200, 1], 6, [_, 3]] .

test_dcg_sample_8(Result) :- is_processed_sms_inbox(List), nth1(8,List,Sample), reservation_request( Result, Sample, []) .
test_dcg_sample_8_passes() :- is_processed_sms_inbox(List), nth1(8,List,Sample), reservation_request( Result, Sample, []), Result = [[18, 3], [1140, 1], 7, [1, 2]] .



test_dcg_sample_all() :- 
	test_dcg_sample_1_passes(),
	test_dcg_sample_2_passes(),
	test_dcg_sample_3_passes(),
	test_dcg_sample_4_passes(),
	test_dcg_sample_5_passes(),
	test_dcg_sample_6_passes(),
	test_dcg_sample_7_passes(),
	test_dcg_sample_8_passes() .



test_dcg_sample_extra_1(Result) :- is_extra_processed_sms_inbox(List), nth1(1,List,Sample), reservation_request( Result, Sample, []) .
test_dcg_sample_extra_2(Result) :- is_extra_processed_sms_inbox(List), nth1(2,List,Sample), reservation_request( Result, Sample, []) .
test_dcg_sample_extra_3(Result) :- is_extra_processed_sms_inbox(List), nth1(3,List,Sample), reservation_request( Result, Sample, []) .














/* 
##################################################################
#                        CONSTRAINT SYSTEM                       #
##################################################################

This section will provide the CLP(FD), Constraint Logic Programming with Finite Domains, to perform the scheduling of the restaurant's reservations.
In Prolog one can think of the constraint system as part of the unification process.
Indeed, we associate a set of “allowed values” with each variable, and then any attempt to unify it with something “not allowed” will fail.
Doing this will "prune" the solution trees branches that are known to fail early on, enhancing the execution speed.

A reservation is represented as [Id, Date, Time, Amount, Menu, Tables]:
   - Id: used to link reservation to original messsage, equal to nth0 of initial SMS inbox - integer
   - Date: date for reservation - [Day, Month], both integer
   - Time: time the customer is expected to come and leave and its preference - [StartTime, EndTime, TimePreference] - StartTime and EndTime represented in minutes since midnight (integer), TimePreference as integer representation
   - Amount: number of people that have made a reservation - integer
   - Menu: menu for group and it's preference - [Menu, MenuPreference] - both integer representation of the categorical values
   - Tables: assigned tables for group - [TableFor2, TableFor3, TableFor4], all boolean integers

The following concepts are constraint:
   - constrain_reservation_request_menu
      - Menu must be singular allowed menu.
   - constrain_reservation_request_time
      - Time must be:
	     - During opening hours.
		 - Rounded to specified rounding.
		 - Long enough for chosen menu.
   - constrain_reservation_request_table
      - Puts constrains on tables (and amount) in general:
	     - Amount of people must not exceed maximum capacity (9).
		 - Reserved tables must be able to seat all people.
         - Edge case: no tables are assigned since the reservation is rejected.
   - constrain_reservation_request_double_booking
      - Constraints for double booking so that no table is booked twice during the same time.

*/

/* 
----------------------------------------------
|                  CLP: Menu                 |
----------------------------------------------

This subsection is responsible for constraining the menu variables of a reservation.
Remember that the restaurant has 2 menu's currently, standard and theatre, both represented as integers.
*/

/* Constraints for menu:
   - When menu is fixed we keep the variable ground, otherwise it can be changed.
   - Must be a legal menu
   - Only one menu must be chosen

	NOTE: makes a new list since menu variables are already ground when preferable and we need them as variables
 */
constrain_reservation_request_menu([], [], []) .

constrain_reservation_request_menu([reservation_request(Id, Date, Time, Amount, [Menu, MenuPreference], Tables) | OtherReservationRequests],
									[reservation_request(Id, Date, Time, Amount, [MenuNew, MenuPreference], Tables) | OtherReservationRequestsNew],
									[ MenuNew | OtherVariablesForLabeling]) :- 
	
	is_max_preference(MaxPreference),
	MenuPreference in 1..MaxPreference,
	is_preference(FixedPreference, fixed),
	( MenuPreference #= FixedPreference ) #==> ( Menu #= MenuNew),

	is_max_menu(MaxMenu),
	MenuNew in 1..MaxMenu,

	is_menu(StandardMenu, standard, _),
	is_menu(TheatreMenu, theatre, _),
	( MenuNew #= StandardMenu ) #<==> ( StandardMenuChosen ),
	( MenuNew #= TheatreMenu ) #<==> ( TheatreMenuChosen ),

	StandardMenuChosen + TheatreMenuChosen #= 1,	
	constrain_reservation_request_menu(OtherReservationRequests, OtherReservationRequestsNew, OtherVariablesForLabeling) .





/* 
----------------------------------------------
|                  CLP: Time                 |
----------------------------------------------

This subsection is responsible for constraining the time variables of a reservation.
Remember that the restaurant (and kitchen) is open from 19:00 - 23:00.
The internal representation of a time variable is a list: [StartTime, EndTime, TimePreference], all integers.
*/

/* Constraints for reservation time:
   - When time is fixed we keep the variable ground, otherwise it can be changed.
   - During opening hours.
   - Rounded to specified rounding.
   - Long enough for the chosen menu.

	NOTE: makes a new list since time variables are already ground when preferable and we need them as variables
 */
constrain_reservation_request_time([], [], []) .

constrain_reservation_request_time([reservation_request(Id, Date, [StartTime, EndTime, TimePreference], Amount, [Menu, MenuPreference], Tables) | OtherReservationRequests], 
									[reservation_request(Id, Date, [StartTimeNew, EndTimeNew, TimePreference], Amount, [Menu, MenuPreference], Tables) | OtherReservationRequestsNew], 
										[ StartTimeNew, EndTimeNew, Menu | OtherVariablesForLabeling]) :-
	
	is_max_preference(MaxPreference),
	TimePreference in 1..MaxPreference,
	is_preference(FixedPreference, fixed),
	( TimePreference #= FixedPreference ) #==> ( StartTimeNew #= StartTime  #/\ EndTimeNew #= EndTime ),

	is_opening_time(OpeningTime),
	is_closing_time(ClosingTime),
	StartTimeNew in OpeningTime..ClosingTime,
	EndTimeNew in OpeningTime..ClosingTime,
	EndTimeNew #>= StartTimeNew,
	
	is_time_rounding(TimeRounding),
	StartTimeNew mod TimeRounding #= 0,

	is_max_menu(MaxMenu),
	Menu in 1..MaxMenu,
	is_menu(StandardMenu, standard, StandardMenuTimeNeeded),
	is_menu(TheatreMenu, theatre, TheatreMenuTimeNeeded),
	( Menu #= StandardMenu ) #==> ( EndTimeNew - StartTimeNew #= StandardMenuTimeNeeded  ),
	( Menu #= TheatreMenu ) #==> ( EndTimeNew - StartTimeNew #= TheatreMenuTimeNeeded ),
	
	constrain_reservation_request_time(OtherReservationRequests, OtherReservationRequestsNew, OtherVariablesForLabeling) .





/* 
----------------------------------------------
|                 CLP: Tables                |
----------------------------------------------

This subsection is responsible for constraining the table variables of a reservation.
Remember that there are three tables with different capacities.
Remember, the internal representation of a table variable is a list: [TableFor2, TableFor3, TableFor4], all boolean integers
*/

/* Constraints for reservation tables:
   - Amount of people must not exceed maximum capacity (9).
   - Tables must be able to seat all people.
   - Edge case: no tables are assigned since the reservation is rejected.
 */
constrain_reservation_request_table([], []) .

constrain_reservation_request_table([reservation_request(_Id, _Date, _Time, Amount, _Menu, [TableFor2, TableFor3, TableFor4]) | OtherReservationRequests], [ Amount, TableFor2, TableFor3, TableFor4 | OtherVariablesForLabeling]) :- 
	Amount in 1..9,
	
	TableFor2 in 0..1,
	TableFor3 in 0..1,
	TableFor4 in 0..1,
	TotalSeatingCapacity #= 2*TableFor2 + 3*TableFor3 + 4*TableFor4,
	
	( TotalSeatingCapacity #\= 0 ) #==> ( TotalSeatingCapacity #>= Amount ),
	
	constrain_reservation_request_table(OtherReservationRequests, OtherVariablesForLabeling) .





/* 
----------------------------------------------
|             CLP: Double booking            |
----------------------------------------------

This subsection is responsible for constraining double booking of a table.
A table is double-booked if a reservation's date and time overlap with another reservation's date and time that has the same table assigned.
An edge case is where one reservation starts at the moment another ends, this is NOT an overlap.
*/

/* To prevent double-booking a double iterative process is performed:
    - First loop (constrain_reservation_request_double_booking_iter):
        - Initiate the second loop with "already processed" reservation until then
    - Second loop (constrain_reservation_request_double_booking_syncer):
        - Check if there are reservation that is already processed that occur on overlapping time
           - If that is the case, constrain that tables can not be shared
 */
constrain_reservation_request_double_booking( ReservationRequestList, VariablesForLabeling ) :- constrain_reservation_request_double_booking_iter([], ReservationRequestList, VariablesForLabeling) .


/* First loop: add reservations to "processed reservations" */
constrain_reservation_request_double_booking_iter(_ProcessedReservationRequestList, [], []) .

constrain_reservation_request_double_booking_iter(ProcessedReservationRequestList, [reservation_request(_Id, [Day, Month], [StartTime, EndTime, _TimePreference], _Amount, _Menu, [TableFor2, TableFor3, TableFor4]) | OtherReservationRequests], [ Day, Month, StartTime, EndTime, TableFor2, TableFor3, TableFor4 | OtherVariablesForLabeling]) :- 
	constrain_reservation_request_double_booking_syncer(ProcessedReservationRequestList, reservation_request(_, [Day, Month], [StartTime, EndTime, _], _, _, [TableFor2, TableFor3, TableFor4])), 

	append(ProcessedReservationRequestList, [reservation_request(_, [Day, Month], [StartTime, EndTime, _], _, _, [TableFor2, TableFor3, TableFor4])], NewProcessedReservationRequestList),
	constrain_reservation_request_double_booking_iter(NewProcessedReservationRequestList, OtherReservationRequests, OtherVariablesForLabeling) .


/* Second loop: update constraints so that no double booking is allowed to occur with already processed reservations. */
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
#                 CONVERSION AND CHAINGING SYSTEM                #
##################################################################

This section will provide code for converting between different stages of the system as well as chain these stages together.
It will also be responsible for performing the labelling on the CLP(FD).
*/

/* 
----------------------------------------------
|                  SMS TO NLP                |
----------------------------------------------
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
*/

/* Links a list of NLP representations to a list of CLP representations.
	Id is the nth0 element location of the input NlpList. */
nlp_to_clp( NlpList, ClpList ) :- nlp_to_clp_iter(0, NlpList, ClpList) .



nlp_to_clp_iter(_Id, [], []) .
nlp_to_clp_iter( Id, [[[Day, Month], [StartTime, TimePreference], Amount, [Menu, MenuPreference]] | NlpRest], [reservation_request(Id, [Day, Month], [StartTime, _ClpEndTime, TimePreference], Amount, [Menu, MenuPreference], _ClpTables) | ClpRest] ) :-
	NewId is Id + 1,
	nlp_to_clp_iter(NewId, NlpRest, ClpRest) .




/* 
----------------------------------------------
|    RESERVATION REQUESTS TO RESERVATIONS    |
----------------------------------------------
*/

/* Converts reservation requests to reservation by changing leading term.
	NOTE: this is nothing more then a representation change and does not perform an actual "action". */
reservationrequests_to_reservation([], []) .

reservationrequests_to_reservation([reservation_request(Id, Date, Time, Amount, Menu, Tables) | OtherReservationRequests], [reservation(Id, Date, Time, Amount, Menu, Tables) | OtherReservations]) :-
	reservationrequests_to_reservation(OtherReservationRequests, OtherReservations) .





/* 
----------------------------------------------
|              CLP TO RESERVATIONS           |
----------------------------------------------
*/

/* Performs labeling using either the fast or slow minimizer (comment out what is preffered).
	Has a parameter for the initial list of reservation requests and a final list of confirmed reservations. */
clp_labeling(InputRequestList, Reservations) :-
	constrain_reservation_request_menu(InputRequestList, UpdatedRequestList, VariablesForLabelingMenu),
	constrain_reservation_request_table(UpdatedRequestList, VariablesForLabelingTable),
	constrain_reservation_request_time(UpdatedRequestList, FinalRequestList, VariablesForLabelingTime),
	constrain_reservation_request_double_booking(FinalRequestList, VariablesForLabelingDoubleBooking),
	
	% use the faster minimizer by default that only looks at the total amount of rejected reservations.
	minimizer_fast(FinalRequestList, Minimization),
	%minimizer(FinalRequestList, Minimization),
	
	append([[Minimization], VariablesForLabelingMenu, VariablesForLabelingTable, VariablesForLabelingTime, VariablesForLabelingDoubleBooking], Variables),
	labeling( [min(Minimization)], Variables ),
	reservationrequests_to_reservation(FinalRequestList, Reservations).



/* This will calculate the wasted space by calculating the difference between how many people are at a table and how many people that table can have.
	Minimizing this can be used as a criteria for labeling. Rejected reservations are "ignored". */
wasted_space([], 0) .

wasted_space([reservation_request(_Id, _Date, _Time, Amount, _Menu, [TableFor2, TableFor3, TableFor4]) | OtherReservationRequests], Minimization) :-
	TotalSeatingCapacity #= 2*TableFor2 + 3*TableFor3 + 4*TableFor4,
	( TableFor2 #= 1 #\/ TableFor3 #= 1 #\/ TableFor4 #= 1 ) #<==> Accepted,
	WastedSpace #= Accepted*(TotalSeatingCapacity - Amount),
	Minimization #= NewMinimization + WastedSpace,
	wasted_space(OtherReservationRequests, NewMinimization) .



/* This will calculate the total amount of people served in the reservations.
	Maximizing this can be used as a criteria for labeling. Rejected reservations are "ignored". */
total_amount([], 0) .

total_amount([reservation_request(_Id, _Date, _Time, Amount, _Menu, [TableFor2, TableFor3, TableFor4]) | OtherReservationRequests], Maximization) :-
	( TableFor2 #= 1 #\/ TableFor3 #= 1 #\/ TableFor4 #= 1 ) #<==> Accepted,
	Maximization #= NewMaximization + Accepted*Amount,
	total_amount(OtherReservationRequests, NewMaximization) .



/* This will calculate the total amount of rejected reservations.
	Minimizing this can be used as a criteria for labeling. */
total_rejections([], 0) .
total_rejections([reservation_request(_Id, _Date, _Time, _Amount, _Menu, [TableFor2, TableFor3, TableFor4]) | OtherReservationRequests], Minimization) :-
	( TableFor2 #= 0 #/\ TableFor3 #= 0 #/\ TableFor4 #= 0 ) #<==> Rejected,
	Minimization #= NewMinimization + Rejected,
	total_rejections(OtherReservationRequests, NewMinimization) .



/* This will use wasted_space, total_amount and total_rejections to create a minimizer.
	total_rejections has the highest impact since we want to reject as few reservations as possible.
	Note that total_amount should be maximized thus a minus is put in front of it.  */
minimizer(ReservationRequests, Minimization) :-
	wasted_space(ReservationRequests, WastedSpace),
	total_amount(ReservationRequests, TotalAmount),
	total_rejections(ReservationRequests, Rejected),
	Minimization #= WastedSpace - 3*TotalAmount + 9*Rejected.



/* This predicate will only use total_amount to create a minimizer, which is faster than the minimizer above. */
minimizer_fast(ReservationRequests, Minimization) :-
	total_amount(ReservationRequests, TotalAmount),
	Minimization #= - TotalAmount.





/* 
----------------------------------------------
|             SMS TO RESERVATIONS            |
----------------------------------------------
*/

/* Unifies an SMS inbox with the made reservations. */
sms_to_reservations(Sms, Reservations) :-
	sms_to_nlp( Sms, Nlp ),
	nlp_to_clp( Nlp, ReservationRequests),
	clp_labeling(ReservationRequests, Reservations) .





/* 
----------------------------------------------
|            ALL RESERVATIONS TO DAY         |
----------------------------------------------
*/

/* Unifies a list of reservations with reservations made on a particular day.
	Does this by skipping non equal dated reservations and adding equal dated ones. */
reservations_on_day([], [], _Date) .

reservations_on_day([reservation(Id, [Day, Month], Time, Amount, Menu, Tables) | OtherReservations], [reservation(Id, [Day, Month], Time, Amount, Menu, Tables) | OtherReservationsOnDay], [Day, Month]) :-
	reservations_on_day(OtherReservations, OtherReservationsOnDay, [Day, Month]) .

reservations_on_day([reservation(_, [DayNotMatched, MonthNothEqual], _, _, _, _) | OtherReservations], OtherReservationsOnDay, [Day, Month]) :-
	( DayNotMatched \= Day ; MonthNothEqual \= Month ),
	reservations_on_day(OtherReservations, OtherReservationsOnDay, [Day, Month]) .





/* 
----------------------------------------------
|          NON REJECTED RESERVATIONS         |
----------------------------------------------
*/

/* Unifies a list of reservations with reservations that are non rejected.
	Rejected reservations are those who don't have a table assigned to them. */
non_rejected_reservations([], []) .

non_rejected_reservations([reservation(Id, Day, Time, Amount, Menu, [TableFor2, TableFor3, TableFor4]) | OtherReservations], [reservation(Id, Day, Time, Amount, Menu, [TableFor2, TableFor3, TableFor4]) | OtherReservationsNonNul]) :-
	( TableFor2 \= 0 ; TableFor3 \= 0 ; TableFor4 \= 0 ),
	non_rejected_reservations(OtherReservations, OtherReservationsNonNul) .

non_rejected_reservations([reservation(_, _, _, _, _, [0, 0, 0]) | OtherReservations], OtherReservationsNonNul) :-
	non_rejected_reservations(OtherReservations, OtherReservationsNonNul) .






/* 
----------------------------------------------
|           TABLES TO TEXTUAL TABLES         |
----------------------------------------------
*/

/* Gives a textual representation for all possible table assignments */
internal_to_textual_table_representation([0, 0, 1], "the table for four") .
internal_to_textual_table_representation([0, 1, 0], "the table for three") .
internal_to_textual_table_representation([0, 1, 1], "the table for three and four") .
internal_to_textual_table_representation([1, 0, 0], "the table for two") .
internal_to_textual_table_representation([1, 0, 1], "the table for two and four") .
internal_to_textual_table_representation([1, 1, 0], "the table for two and three") .
internal_to_textual_table_representation([1, 1, 1], "all tables") .





/* 
----------------------------------------------
|             ORDERING RESERVATIONS          |
----------------------------------------------

This subsection is responsible for ordering reservations on date/time. 
It is modified from the British Museum sort seen during the lectures.
*/

/* Sort reservation on time */
sort_reservations(RawReservations, SortedReservations) :-
	when( nonvar( SortedReservations ), ordering_of_reservations( SortedReservations )),
	perm( RawReservations, SortedReservations ).


ordering_of_reservations( [] ).

ordering_of_reservations( [_] ).

ordering_of_reservations( [reservation(_Id, [Day1, Month1],  [StartTime1, EndTime1, _TimePreference], _Amount, _Menu, _Tables), reservation(_, [Day2, Month2],  [StartTime2, EndTime2, _], _, _, _) | OtherReservations] ) :-
	Month1 #=< Month2,
	Day1 #=< Day2,
	StartTime1 #=< StartTime2,
	EndTime1 #=< EndTime2,
	when( nonvar( OtherReservations ), ordering_of_reservations( [ reservation(_, [Day2, Month2],  [StartTime2, EndTime2, _], _, _, _) | OtherReservations ] )).



perm( [], [] ).

perm( [X|Y], [U|V] ) :-
	del( U, [X|Y], W ),
	perm( W, V ).



del( X, [X|Y], Y ).

del( X, [Y|U], [Y|V] ) :-
	del( X, U, V ).










/* 
##################################################################
#                          DISPLAY SYSTEM                        #
##################################################################
*/

/* 
----------------------------------------------
|                TEXTUAL DISPLAY             |
----------------------------------------------

This subsection is responsible for a text based displaying system of reservations.
Uses some fancy ASCII art work and formatting. :-)
*/

/* Prints the reservations for Restaurant XX of a specified date [Day, Month] in a textual manner.
	Shown "header" ASCII art inspired by: https://www.asciiart.eu/art-and-design/borders */
textual_display_reservations_on_day(Sms, Reservations, [Day, Month]) :-
	reservations_on_day(Reservations, ReservationsOnDay, [Day, Month]),

	non_rejected_reservations(ReservationsOnDay, AcceptedReservations),
	subtract(ReservationsOnDay, AcceptedReservations, RejectedReservations ),

	sort_reservations(AcceptedReservations, OrderedReservations),

	write( '\n\n' ),
	writef( '   _________________________________________________________\n / \\                                                        \\\n|   |            R E S T A U R A N T   X X                  |\n \\_ |                                                       |\n    |                                                       |\n    |                                                       |\n    |         R E S E R V A T I O N S    L I S T            |\n    |                   D A T E: %t/%t                       |\n    |                                                       |\n    |                                                       |\n    |                                                       |\n    |  M a d e    b y    L e n n e r t    B o n t i n c k   |\n    |   ____________________________________________________|___\n    |  /                                                       /\n    \\_/_______________________________________________________/\n', [Day, Month]),
	write( '\n\n' ),

	textual_print_reservations(Sms, OrderedReservations),

	textual_print_rejected_reservations(Sms, RejectedReservations),

	write( '\n\n' ) .



/* Prints a list of reservations in a textual manner.
	Also finds the related SMS message to show it as a form of identification.
	--> Assumes Id is the Nth0 element of the SMS inbox list.  */
textual_print_reservations(_Sms, []) .

textual_print_reservations(Sms, [reservation(Id, _Date,  [StartTime, EndTime, _TimePreference], Amount, [Menu, _MenuPreference], Tables) | OtherReservations]) :-
	minutes_since_midnight(StartTime, [StartHour, StartMinute]),
	minutes_since_midnight(EndTime, [EndHour, EndMinute]),
	is_menu(Menu, NaturalLangMenu, _),
	internal_to_textual_table_representation(Tables, TextualTables),
	nth0(Id,Sms, OrderMessage),

	writef( 'At %th%t, %t people will arrive. They will have the %t menu and sit at %w. They will leave at %th%t.', [StartHour, StartMinute, Amount, NaturalLangMenu, TextualTables, EndHour, EndMinute]),
	write( '\n' ),
	writef( '\tOrder message: %t', [OrderMessage]),
	write( '\n\n' ),
	textual_print_reservations(Sms, OtherReservations) .



/* Prints a list of rejected reservations in a textual manner.
	Also finds the related SMS message to show it as a form of identification.  */
textual_print_rejected_reservations(_Sms, []) :-
	writef( 'No reservations had to be rejected!') .

textual_print_rejected_reservations(Sms, [Reservation | OtherReservations]) :-
	writef( 'Sadly, some reservations had to be rejected: \n'),
	textual_print_rejected_reservations_iter(Sms, [Reservation | OtherReservations]) .



textual_print_rejected_reservations_iter(_Sms, []) .

textual_print_rejected_reservations_iter(Sms, [reservation(Id, _Date, _Time, _Amount, _Menu, _Tables) | OtherReservations]) :-
	nth0(Id,Sms, OrderMessage),
	writef( '\tOrder message: %t', [OrderMessage]),
	write( '\n' ),
	textual_print_rejected_reservations_iter(Sms, OtherReservations) .





/* 
----------------------------------------------
|            TEXTUAL DISPLAY: TEST           |
----------------------------------------------

This subsection provides predicates that can be used to test the textually displaying of reservations in an easy manner.
*/

/* Prints the reservations collected from the extra sms inbox on a specified date.
	Uses a cut to not allow backtracking for displaying, as proposed by the assignment.  */
textual_print_reservations_from_extra_sms([Day, Month]) :-
	is_extra_processed_sms_inbox( Sms ),
	sms_to_reservations( Sms, Reservations ),
	textual_display_reservations_on_day(Sms, Reservations, [Day, Month]),
	! .



/* Prints the reservations collected from the extra sms inbox 2 on a specified date.
	Uses a cut to not allow backtracking for displaying, as proposed by the assignment.  */
textual_print_reservations_from_extra_sms2([Day, Month]) :-
		is_extra_processed_sms_inbox2( Sms ),
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

This section will provide some predicates for easy testing of the complete system.
test_textual_output_sample_XXX are created for manual validation.
*/

test_textual_output_sample_1([Day, Month]) :- is_processed_sms_inbox( Sms ), nth1(1,Sms, FilteredSms), sms_to_reservations( [FilteredSms], Reservations ), textual_display_reservations_on_day([FilteredSms], Reservations, [Day, Month]), ! .
test_textual_output_sample_2([Day, Month]) :- is_processed_sms_inbox( Sms ), nth1(2,Sms, FilteredSms), sms_to_reservations( [FilteredSms], Reservations ), textual_display_reservations_on_day([FilteredSms], Reservations, [Day, Month]), ! .
test_textual_output_sample_3([Day, Month]) :- is_processed_sms_inbox( Sms ), nth1(3,Sms, FilteredSms), sms_to_reservations( [FilteredSms], Reservations ), textual_display_reservations_on_day([FilteredSms], Reservations, [Day, Month]), ! .
test_textual_output_sample_4([Day, Month]) :- is_processed_sms_inbox( Sms ), nth1(4,Sms, FilteredSms), sms_to_reservations( [FilteredSms], Reservations ), textual_display_reservations_on_day([FilteredSms], Reservations, [Day, Month]), ! .
test_textual_output_sample_5([Day, Month]) :- is_processed_sms_inbox( Sms ), nth1(5,Sms, FilteredSms), sms_to_reservations( [FilteredSms], Reservations ), textual_display_reservations_on_day([FilteredSms], Reservations, [Day, Month]), ! .
test_textual_output_sample_6([Day, Month]) :- is_processed_sms_inbox( Sms ), nth1(6,Sms, FilteredSms), sms_to_reservations( [FilteredSms], Reservations ), textual_display_reservations_on_day([FilteredSms], Reservations, [Day, Month]), ! .
test_textual_output_sample_7([Day, Month]) :- is_processed_sms_inbox( Sms ), nth1(7,Sms, FilteredSms), sms_to_reservations( [FilteredSms], Reservations ), textual_display_reservations_on_day([FilteredSms], Reservations, [Day, Month]), ! .
test_textual_output_sample_8([Day, Month]) :- is_processed_sms_inbox( Sms ), nth1(8,Sms, FilteredSms), sms_to_reservations( [FilteredSms], Reservations ), textual_display_reservations_on_day([FilteredSms], Reservations, [Day, Month]), ! .










/* 
##################################################################
#                    TERMINAL OUTPUT OF SYSTEM                   #
##################################################################

This section will provide some copy pastes from the terminal as to not have to run the lengthy process.
These are a straight copy, without modifications.
*/

/* 
----------------------------------------------
|                SLOW MINIMIZER              |
----------------------------------------------

The below terminal output is that of the slow minimizer (which takes +- 25 minutes).

--------- OUTPUT STARTS HERE ---------
1 ?- textual_print_reservations_from_provided_sms([18,3]) .


   _________________________________________________________ 
 / \                                                        \
|   |            R E S T A U R A N T   X X                  |
 \_ |                                                       |
    |                                                       |
    |                                                       |
    |         R E S E R V A T I O N S    L I S T            |
    |                   D A T E: 18/3                       |
    |                                                       |
    |                                                       |
    |                                                       |
    |  M a d e    b y    L e n n e r t    B o n t i n c k   |
    |   ____________________________________________________|___
    |  /                                                       /
    \_/_______________________________________________________/


At 19h0, 7 people will arrive. They will have the theatre menu and sit at the table for three and four. They will leave at 20h0.
        Order message: [reservation,for,7,on,march,18,preferably,for,standard,menu,at,7,oclock]

At 20h0, 2 people will arrive. They will have the theatre menu and sit at the table for three. They will leave at 21h0.
        Order message: [table,for,2,at,20,:,0,on,18,march]

At 20h0, 6 people will arrive. They will have the theatre menu and sit at the table for two and four. They will leave at 21h0.
        Order message: [book,6,of,us,in,on,18,march,at,20,:,0]

At 21h0, 3 people will arrive. They will have the theatre menu and sit at the table for four. They will leave at 22h0.
        Order message: [please,can,we,have,a,table,for,3,for,the,theatre,menu,on,march,18,th]

At 21h0, 5 people will arrive. They will have the theatre menu and sit at the table for two and three. They will leave at 22h0.
        Order message: [we,would,like,a,table,for,5,preferably,at,8,pm,on,18,/,3]

At 22h0, 9 people will arrive. They will have the theatre menu and sit at all tables. They will leave at 23h0.
        Order message: [9,people,on,18,th,of,march]

Sadly, some reservations had to be rejected:
        Order message: [can,i,book,a,table,at,9,pm,for,2,people,on,the,18,th,of,march,for,the,standard,menu,please]
        Order message: [reserve,us,a,table,on,march,18,for,a,party,of,4,for,the,standard,menu]


true.

*/





/* 
----------------------------------------------
|                FAST MINIMIZER              |
----------------------------------------------

The below terminal output is that of the faster minimizer (which takes +- 1 minute).
It is clear the maximisation of amount worked: 32 people are seated.
One might notice the output is identical to the longer variant, however this is not guaranteed for all inputs.

--------- OUTPUT STARTS HERE ---------
1 ?- textual_print_reservations_from_provided_sms([18,3]) .  


   _________________________________________________________
 / \                                                        \
|   |            R E S T A U R A N T   X X                  |
 \_ |                                                       |
    |                                                       |
    |                                                       |
    |         R E S E R V A T I O N S    L I S T            |
    |                   D A T E: 18/3                       |
    |                                                       |
    |                                                       |
    |                                                       |
    |  M a d e    b y    L e n n e r t    B o n t i n c k   |
    |   ____________________________________________________|___
    |  /                                                       /
    \_/_______________________________________________________/


At 19h0, 7 people will arrive. They will have the theatre menu and sit at the table for three and four. They will leave at 20h0.
        Order message: [reservation,for,7,on,march,18,preferably,for,standard,menu,at,7,oclock]

At 20h0, 2 people will arrive. They will have the theatre menu and sit at the table for three. They will leave at 21h0.
        Order message: [table,for,2,at,20,:,0,on,18,march]

At 20h0, 6 people will arrive. They will have the theatre menu and sit at the table for two and four. They will leave at 21h0.
        Order message: [book,6,of,us,in,on,18,march,at,20,:,0]

At 21h0, 3 people will arrive. They will have the theatre menu and sit at the table for four. They will leave at 22h0.
        Order message: [please,can,we,have,a,table,for,3,for,the,theatre,menu,on,march,18,th]

At 21h0, 5 people will arrive. They will have the theatre menu and sit at the table for two and three. They will leave at 22h0.
        Order message: [we,would,like,a,table,for,5,preferably,at,8,pm,on,18,/,3]

At 22h0, 9 people will arrive. They will have the theatre menu and sit at all tables. They will leave at 23h0.
        Order message: [9,people,on,18,th,of,march]

Sadly, some reservations had to be rejected:
        Order message: [can,i,book,a,table,at,9,pm,for,2,people,on,the,18,th,of,march,for,the,standard,menu,please]
        Order message: [reserve,us,a,table,on,march,18,for,a,party,of,4,for,the,standard,menu]


true.
--------- OUTPUT ENDS HERE ---------
*/




/* 
----------------------------------------------
|            SLOW MINIMIZER (EXTRA)          |
----------------------------------------------

The below terminal output is that of the slower minimizer for the extra SMS inbox made by me. This only takes a manner of seconds.

--------- OUTPUT STARTS HERE ---------
1 ?- textual_print_reservations_from_extra_sms([1,12]) .   


   _________________________________________________________
 / \                                                        \
|   |            R E S T A U R A N T   X X                  |
 \_ |                                                       |
    |                                                       |
    |                                                       |
    |         R E S E R V A T I O N S    L I S T            |
    |                   D A T E: 1/12                       |
    |                                                       |
    |                                                       |
    |                                                       |
    |  M a d e    b y    L e n n e r t    B o n t i n c k   |
    |   ____________________________________________________|___
    |  /                                                       /
    \_/_______________________________________________________/


At 20h0, 4 people will arrive. They will have the theatre menu and sit at the table for four. They will leave at 21h0.
        Order message: [hi,can,i,book,a,place,at,8,pm,for,4,persons,on,the,first,of,december,for,the,theatre,menu,please]

At 20h0, 2 people will arrive. They will have the standard menu and sit at the table for two. They will leave at 22h0.
        Order message: [table,for,2,at,20,:,0,on,the,first,of,december]

At 20h0, 3 people will arrive. They will have the standard menu and sit at the table for three. They will leave at 22h0.
        Order message: [table,for,3,at,8,pm,on,the,first,of,december,for,the,standard,menu,please]

No reservations had to be rejected!

true.
--------- OUTPUT ENDS HERE ---------
*/




/* 
----------------------------------------------
|           SLOW MINIMIZER (EXTRA2)          |
----------------------------------------------

The below terminal output is that of the slower minimizer for the second extra SMS inbox made by me. This only takes a manner of seconds.

--------- OUTPUT STARTS HERE ---------
3 ?- textual_print_reservations_from_extra_sms2([1,12]) .  


   _________________________________________________________
 / \                                                        \
|   |            R E S T A U R A N T   X X                  |
 \_ |                                                       |
    |                                                       |
    |                                                       |
    |         R E S E R V A T I O N S    L I S T            |
    |                   D A T E: 1/12                       |
    |                                                       |
    |                                                       |
    |                                                       |
    |  M a d e    b y    L e n n e r t    B o n t i n c k   |
    |   ____________________________________________________|___
    |  /                                                       /
    \_/_______________________________________________________/


At 19h0, 4 people will arrive. They will have the standard menu and sit at the table for four. They will leave at 21h0.
        Order message: [4,of,us,on,1,/,12,preferably,at,8,pm]

At 20h0, 2 people will arrive. They will have the theatre menu and sit at the table for two. They will leave at 21h0.
        Order message: [table,for,2,at,20,:,0,on,the,first,of,december,preferably,for,the,standard,menu]

At 20h0, 3 people will arrive. They will have the standard menu and sit at the table for three. They will leave at 22h0.
        Order message: [table,for,3,at,8,pm,on,the,first,of,december,for,the,standard,menu,please]

At 21h0, 4 people will arrive. They will have the theatre menu and sit at the table for four. They will leave at 22h0.
        Order message: [hi,can,i,book,a,place,at,9,pm,for,4,persons,on,the,first,of,december,for,the,theatre,menu,please]

At 21h0, 2 people will arrive. They will have the standard menu and sit at the table for two. They will leave at 23h0.
        Order message: [table,for,2,at,21,:,0,on,the,first,of,december]

No reservations had to be rejected!

true.
--------- OUTPUT ENDS HERE ---------
*/










/* 
##################################################################
#                      README OF GITHUB REPO                     #
##################################################################

Below a copy of the README from the GitHub Repo is provided.
It includes a list of performed tests.
It is best viewed in a markdown editor.
*/




/* 

# Declarative Programming project @ VUB 2020-2021 

## Table of contents

- [Student info](#student-info)
- [Used software](#used-software)
- [Important files](#important-files)
- [Running the assignment](#running-the-assignment)
- [Assumptions made](#assumptions-made)
- [Testing the code](#testing-the-code)

## Student info

- **Name**: Bontinck Lennert
- **Student ID**: 568702
- **Affiliation**: VUB - Master Computer Science: AI
- **Email**: lennert.bontinck@vub.be

## Used software

- [Visual Studio code](https://code.visualstudio.com/Download) with [VSC-Prolog plugin](https://marketplace.visualstudio.com/items?itemName=arthurwang.vsc-prolog)
- [SWI Prolog V8.2.4-1](https://www.swi-prolog.org/download/stable) from terminal using path variable.

## Important files

- The [assignment pdf](assignment.pdf)
- Single loadable file with comments and methods as prescribed in the assignment
   - [Bontinck_Lennert_568702_VUB_Restaurant.pl](Bontinck_Lennert_568702_VUB_Restaurant.pl)

## Running the assignment

- Make sure SWI Prolog is installed with the path variable set
- Go to the root of this GitHub repository in your terminal
- use:  ```swipl -s Bontinck_Lennert_568702_VUB_Restaurant.pl```

## Assumptions made

Some things were assumed:

- Since the text messages are said to be processed no operations such as downcase_atom (lowercase transformation) are done.
- Since we could make the NLP portion endlessly big, it is made so that only the examples and very minor extra's are accepted.
   - This means some assumptions, such as the time_description required "at" to be present, are made. These are obvious where the descriptions are formulated.
- Since I'm no expert in linguistics the naming for different parts of sentences might be odd.
   - It is also possible to make weird sentences such as "book I can a table for 2" since both "book" and "can" are seen as a verb.
- No constraint needed for "Booking takes place at least a day before" (confirmed by Homer).
- From the following sentence of the provided SMS inbox: "preferably for the standard menu at 7 o'clock"
   - 7 o'clock is 7 pm since the restaurant is not open in the morning.
   - "preferable" is concerning the standard menu, not the time since it is situated before the menu. Thus menu also has the option to be "preferred".

## Testing the code

The created code was tested whilst being developed through the interpreter, making sure all returned answers for queries are correct by backtracking as well (using ;). Some predicates were made to make testing easy through a "one line" query. To test the whole system by generating the final planning, one can use the following query to print the planning for the provided SMS messages on the 18th of march: ```textual_print_reservations_from_provided_sms([18,3]) .```

Some examples of the performed tests through the interpreter are given below.

- GENERAL PREDICATES

   - ```minutes_since_midnight``` (CLPFD)
      - Tests link between [Hour, Minute] format and MinutesSinceMidNight format.
      - Test query: ```minutes_since_midnight(MinuteSinceMidnight, [20, 30]) .```
         - Answer: ```MinuteSinceMidnight = 1230.```
      - Test query: ```minutes_since_midnight(1230, [Hour, Minute]) .```
         - Answer: ```MinuteSinceMidnight = Hour = 20, Minute = 30.```

- SMS INBOX

   - Simple unifications for is_processed_sms_inbox and is_extra_processed_sms_inbox.
   - ```is_processed_sms_inbox```
      - Succeeds when the argument represents the pre-processed SMS inbox provided by the assignment.
      - Test query: ```is_processed_sms_inbox(Inbox) .```
         - Answer: ```Inbox = [[table, for, 2, at, 20, :, 0, on|...], [please, can, we, have, a, table, for|...], [we, would, like, a, table, for|...], [can, i, book, a, table|...], [reserve, us, a, table|...], [9, people, on|...], [book, 6|...], [reservation|...]].```
   - ```is_extra_processed_sms_inbox```
      - Succeeds when the argument represents the custom pre-processed SMS inbox.
      - Test query: ```is_extra_processed_sms_inbox(Inbox) .```
         - Answer: ```Inbox = [[table, for, 2, at, 20, :, 0, on|...], [hi, can, i, book, a, place, at|...], [table, for, 3, at, 8, pm|...]].```
   - ```is_extra_processed_sms_inbox2```
      - Succeeds when the argument represents the custom pre-processed SMS inbox.
      - Test query: ```is_extra_processed_sms_inbox2(Inbox) .```
         - Answer: ```Inbox = [[table, for, 2, at, 21, :, 0, on|...], [table, for, 2, at, 20, :, 0|...], [4, of, us, on, 1, /|...], [hi, can, i, book, a|...], [table, for, 3, at|...]].```

- NLP SYSTEM

   -  ```date``` (DCG)
      - Tests link from different natural language inputs (e.g. [first,of,april]) to internal [Month, Day] representation of date.
      - Test query: ```date( ExtractedDate, [first,of,april], [] ) .```
         - Answer: ```ExtractedDate = [1, 4]```
      - Test query: ```date( ExtractedDate, [23,'/',12], [] ) .```
         - Answer: ```ExtractedDate = [23, 12]```
   -  ```time``` (DCG)
      - Tested in the same manner as the date.
      - Test query: ```time( ExtractedTime, [18,':',00], [] ) .```
         - Answer: ```ExtractedTime = [18, 0]```
      - Test query: ```time( ExtractedTime, [6,pm], [] ) .```
         - Answer: ```ExtractedTime = [18, 0]```
      - Test query: ```time( ExtractedTime, [6,oclock], [] ) .```
         - Answer: ```ExtractedTime = [18, 0]```
   -  ```amount``` (DCG)
      -  Tested in the same manner as the date.
      -  Test query: ```amount( ExtractedAmount, [5], [] ) .```
         - Answer: ```ExtractedAmount = 5```
      -  Test query: ```amount( ExtractedAmount, [0], [] ) .```
         - Answer: ```false```
   -  ```menu``` (DCG)
      -  Tested in the same manner as the date.
      -  Test query: ```menu( ExtractedMenu, [theatre], [] ) .```
         - Answer: ```ExtractedMenu = 2```
      -  Test query: ```menu( ExtractedMenu, [randomjunk], [] ) .```
         - Answer: ```false```
   -  ```reservation_request``` and thus ```sentence```  (DCG)
      - To test the NLP extraction with manual validation an easy 1 liner is made for the provided SMS inboxes.
      - Test query: ```test_dcg_sample_1( Result ) .```
         - Answer: ```Result = [[18, 3], [1200, 1], 2, [1, 2]]```
      - Test query: ```test_dcg_sample_2( Result ) .```
         - Answer: ```Result = [[18, 3], [_46754, 3], 3, [2, 1]]```
      - Test query: ```test_dcg_sample_3( Result ) .```
         - Answer: ```Result = [[18, 3], [1200, 2], 5, [1, 2]]```
      - Test query: ```test_dcg_sample_4( Result ) .```
         - Answer: ```[[18, 3], [1260, 1], 2, [1, 1]]```
      - Test query: ```test_dcg_sample_5( Result ) .```
         - Answer: ```Result = [[18, 3], [_54644, 3], 4, [1, 1]]```
      - Test query: ```test_dcg_sample_6( Result ) .```
         - Answer: ```Result = [[18, 3], [_57262, 3], 9, [1, 2]]```
      - Test query: ```test_dcg_sample_7( Result ) .```
         - Answer: ```Result = [[18, 3], [1200, 1], 6, [1, 2]]```
      - Test query: ```test_dcg_sample_8( Result ) .```
         - Answer: ```Result = [[18, 3], [1140, 1], 7, [1, 2]]```
      - Test query: ```test_dcg_sample_extra_1( Result ) .```
         - Answer: ```Result = [[1, 12], [1200, 1], 2, [1, 2]]```
      - Test query: ```test_dcg_sample_extra_2( Result ) .```
         - Answer: ```Result = [[1, 12], [1200, 1], 4, [2, 1]]```
      - Test query: ```test_dcg_sample_extra_3( Result ) .```
         - Answer: ```Result = [[1, 12], [1200, 1], 3, [1, 1]]```
   -  Automated testing
      -  The DCG part can be tested in a more automated way by checking whether the following predicates return true
         -  ```test_dcg_sample_XXX_passes() .``` with XXX in 1..8
            - Example: ```test_dcg_sample_1_passes() .```  should be true (and it is!).
         -  ```test_dcg_sample_all() .```  should be true (and it is!).

- CONSTRAINT SYSTEM

   - ```constrain_reservation_request_menu``` (CLPFD)
      - Test constraints for the menu to be a singular allowed menu.
      - Test query: ```constrain_reservation_request_menu([reservation_request(_Id, _Date, _Time, _Amount, [Menu, 1], _Tables)], NewReservations, VariablesForLabeling), indomain(Menu) .```
         - Note: uses menu "fixed".
         - Answer: ```Menu = 1, NewReservations = [reservation_request(_Id, _Date, _Time, _Amount, [1, 1], _Tables)], VariablesForLabeling = [1]```
         - Backtrack: ```Menu = 2, NewReservations = [reservation_request(_Id, _Date, _Time, _Amount, [2, 1], _Tables)], VariablesForLabeling = [2].```
         - Menu can indeed be 1 or 2!
   - ```constrain_reservation_request_time``` (CLPFD)
      - Test constraints for time (StartTime and EndTime):
         - Must be in opening hours.
         - Time must be rounded to specified rounding from is_time_rounding (e.g. time rounding = 60, all times must be at round hour thus with minutes = 0).
         - Must be long enough for the menu.
      - Test query: ```constrain_reservation_request_time([reservation_request(_Id, _Date, [StartTime, EndTime, 1], _Amount, [1, _MenuPreference], _ClpTables)], UpdatedRequests, VariablesForLabeling), indomain(StartTime) .```
         - Note: This makes the time "fixed" -> has easier results -> works when leaving TimePreference a variable as well.
         - Answer: ```StartTime = 1140, EndTime = 1260, UpdatedRequests = [reservation_request(_Id, _Date, [1140, 1260, 1], _Amount, [1, _MenuPreference], _ClpTables)], VariablesForLabeling = [1140, 1260, 1]```
         - Backtrack: ```StartTime = 1200, EndTime = 1320, UpdatedRequests = [reservation_request(_Id, _Date, [1200, 1320, 1], _Amount, [1, _MenuPreference], _ClpTables)], VariablesForLabeling = [1200, 1320, 1]```
         - Backtrack: ```StartTime = 1260, EndTime = 1380, UpdatedRequests = [reservation_request(_Id, _Date, [1260, 1380, 1], _Amount, [1, _MenuPreference], _ClpTables)], VariablesForLabeling = [1260, 1380, 1].```
         - Time domains seem good!
   - ```constrain_reservation_request_table``` (CLPFD)
      -  Tests constraints for tables:
         - Amount of people must not exceed maximum capacity (9).
         - Reserved tables must be able to seat all people.
         - Edge case: no tables are assigned since the reservation is rejected.
      -  Test query: ```constrain_reservation_request_table([reservation_request(_Id, _Date, _Time, 6, _, [TableFor2, TableFor3, TableFor4])], VariablesForLabeling), indomain(TableFor3) .```
         - Answer: ```TableFor3 = 0, VariablesForLabeling = [6, TableFor2, 0, TableFor4], TableFor2 in 0..1, _13930#=2*TableFor2+4*TableFor4, TableFor4 in 0..1, _13930 in 0..6, _13930#>=6#<==>_14016, _13930#\=0#<==>_14040, _14016 in 0..1, _14040#==>_14016, _14040 in 0..1```
         - Backtrack: ```TableFor3 = TableFor4, TableFor4 = 1, VariablesForLabeling = [6, TableFor2, 1, 1], TableFor2 in 0..1, _19936#=2*TableFor2+7, _19936 in 7..9.```
         - Calculations for tables seem to be correct! (can either be enough or all 0)!
   - ```constrain_reservation_request_double_booking``` (CLPFD)
      - Tests constraints for double booking so that no table is booked twice during the same time.
      - Test query: ```constrain_reservation_request_double_booking( [reservation_request(0, [1, 4], [1200, _34966, 1], 2, [1, 2], [Table2For0, Table3For0, Table4For0]), reservation_request(1, [1, 4], [1200, _35128, 1], 4, [2, 1], [Table2For1, Table3For1, Table4For1]), reservation_request(2, [1, 4], [1200, _35290, 1], 3, [1, 1], [Table2For2, Table3For2, Table4For2])], VariablesForLabeling ) . ```
         - Answer: ```VariablesForLabeling = [1, 4, 1200, _34966, Table2For0, Table3For0, Table4For0, 1, 4|...], _35290#>=_34966#<==>_19512, _34966#>=1201#<==>_19536, _35128#>=_34966#<==>_19560, _34966#>=1201#<==>_19584, _35290#>=_35128#<==>_19608, _35290#>=1201#<==>_19632, _35290#>=1201#<==>_19656, _35128#>=1201#<==>_19680, _35128#>=1201#<==>_19704, _19680 in 0..1, _19680#/\_19608#<==>_19752, _19608 in 0..1, _19752 in 0..1, _19632#\/_19752#<==>_19824, _19632 in 0..1, _19824 in 0..1, _19824#/\_19902#<==>_19896, _19824#/\_19926#<==>_19920, _19824#/\_19950#<==>_19944, _19902 in 0..1, Table4For1#=1#<==>_19902, Table4For1#\=Table4For2#<==>_20016, Table4For0#\=Table4For1#<==>_20040, Table4For0#\=Table4For2#<==>_20064, Table4For0#=1#<==>_20088, Table4For0#=1#<==>_20112, _20088 in 0..1, _20164#/\_20088#<==>_20160, _20164 in 0..1, _20164#/\_20214#<==>_20208, _20164#/\_20238#<==>_20232, _19656#\/_20262#<==>_20164, _20214 in 0..1, Table3For0#=1#<==>_20214, Table3For0#\=Table3For2#<==>_20328, Table3For0#\=Table3For1#<==>_20352, Table3For0#=1#<==>_20376, Table3For1#\=Table3For2#<==>_20400, Table3For1#=1#<==>_19926, _19926 in 0..1, _19920 in 0..1, _19920#==>_20400, _20400 in 0..1, _20352 in 0..1, _20560#==>_20352, _20560 in 0..1, _20608#/\_20376#<==>_20560, _20608 in 0..1, _20608#/\_20112#<==>_20652, _20608#/\_20682#<==>_20676, _19704#\/_20706#<==>_20608, _20112 in 0..1, _20652 in 0..1, _20652#==>_20040, _20040 in 0..1, _20682 in 0..1, Table2For0#=1#<==>_20682, Table2For0#\=Table2For2#<==>_20862, Table2For0#=1#<==>_20238, Table2For0#\=Table2For1#<==>_20910, Table2For1#\=Table2For2#<==>_20934, Table2For1#=1#<==>_19950, _19950 in 0..1, _19944 in 0..1, _19944#==>_20934, _20934 in 0..1, _20910 in 0..1, _20676#==>_20910, _20676 in 0..1, _20862 in 0..1, _20232#==>_20862, _20232 in 0..1, _20238 in 0..1, _19704 in 0..1, _20706 in 0..1, _19584#/\_19560#<==>_20706, _19584 in 0..1, _19560 in 0..1, _20376 in 0..1, _20328 in 0..1, _20208#==>_20328, _20208 in 0..1, _19656 in 0..1, _20262 in 0..1, _19536#/\_19512#<==>_20262, _19536 in 0..1, _19512 in 0..1, _20160 in 0..1, _20160#==>_20064, _20064 in 0..1, _20016 in 0..1, _19896#==>_20016, _19896 in 0..1 ```
         - Backtrack: false
         - This answer is obviously hard to validate but when looking at the variables of Tables (Table2For0 etc) it does indeed look as if the system recognizes these can not be 1 at the same time for overlapping reservations, which the constraint should indeed enforce.

- CONVERSION SYSTEM

   - ```sms_to_nlp``` 

      - Test if the list of SMS messages links correctly with the list of NLP representations

      - Test query: ```is_extra_processed_sms_inbox(Inbox), sms_to_nlp(Inbox, NlpRepresentation) . ```

         - Answer: ```Inbox = [[table, for, 2, at, 20, :, 0, on, the, first, of, december], [hi, can, i, book, a, place, at, 8, pm, for, 4, persons, on, the, first, of, december, for, the, theatre, menu, please], [table, for, 3, at, 8, pm, on, the, first, of, december, for, the, standard, menu, please]],```

            ```NlpRepresentation = [[[1, 12], [1200, 1], 2, [_1320, 3]], [[1, 12], [1200, 1], 4, [2, 1]], [[1, 12], [1200, 1], 3, [1, 1]]]```

         - Backtrack: false

   - ```nlp_to_clp```

      - Test if the list of NLP representations links correctly with CLPFD reservation requests representation
      - Test query: ```nlp_to_clp([[[1, 4], [1200, 1], 2, [1, 2]], [[1, 4], [1200, 1], 4, [2, 1]], [[1, 4], [1200, 1], 3, [1, 1]]], ClpRepresention) . ```
         - Answer: ```ClpRepresention = [reservation_request(0, [1, 4], [1200, _6442, 1], 2, [1, 2], _6420), reservation_request(1, [1, 4], [1200, _6504, 1], 4, [2, 1], _6482), reservation_request(2, [1, 4], [1200, _6566, 1], 3, [1, 1], _6544)]```

         - Backtrack: false

   - ```clp_labeling```

      - Test if input list of reservation requests is labelled.
      - Test query: ```clp_labeling([reservation_request(0, [1, 4], [1200, _, 1], 2, [1, 2], _), reservation_request(1, [1, 4], [1200, _, 1], 4, [2, 1], _), reservation_request(2, [1, 4], [1200, _, 1], 3, [1, 1], _)], Reservations) .```
         - Answer: ```Reservations = [reservation(0, [1, 4], [1200, 1320, 1], 2, [1, 2], [1, 0, 0]), reservation(1, [1, 4], [1200, 1260, 1], 4, [2, 1], [0, 0, 1]), reservation(2, [1, 4], [1200, 1320, 1], 3, [1, 1], [0, 1, 0])]```
         - Backtrack: ```Reservations = [reservation(0, [1, 4], [1200, 1260, 1], 2, [2, 2], [1, 0, 0]), reservation(1, [1, 4], [1200, 1260, 1], 4, [2, 1], [0, 0, 1]), reservation(2, [1, 4], [1200, 1320, 1], 3, [1, 1], [0, 1, 0])]```
         - Backtrack: ```Reservations = [reservation(0, [1, 4], [1200, 1320, 1], 2, [1, 2], [0, 0, 0]), reservation(1, [1, 4], [1200, 1260, 1], 4, [2, 1], [0, 0, 1]), reservation(2, [1, 4], [1200, 1320, 1], 3, [1, 1], [0, 1, 0])]```
         - It becomes clear that less optimal results (where reservations are rejected etc) are only found after backtracking, suggesting our optimisation is good!

   - Minimizers 

      - Tests if the minimizers work by checking some samples individually.
      - Test query: ```test_textual_output_sample_1([18,3]) .```
         - Prints the reservations from the provided SMS inbox filter to only have first (nth1 index 1) sample on the 18th of March.
         - Answer: At 20h0, 2 people will arrive. They will have the standard menu and sit at the table for two. They will leave at 22h0.
            - Order message: [table,for,2,at,20,:,0,on,18,march]
         - NOTE: the "slower" minimizer is needed for this output!
         - It is clear that the table for 2 is assigned since that option wastes no space. If you enable backtracking (by removing the cut), it is also clear it is not by luck since tables are assigned in "worsening" order.

   - ```sms_to_reservations```

      - Tests if SMS inbox can be linked with the made reservations correctly, chaining together all systems.
      - Test query: ```is_extra_processed_sms_inbox( Sms ), sms_to_reservations( Sms, Reservations ) .```
         - Answer: ```Sms = [[table, for, 2, at, 20, :, 0, on, the, first, of, december], [hi, can, i, book, a, place, at, 8, pm, for, 4, persons, on, the, first, of, december, for, the, theatre, menu, please], [table, for, 3, at, 8, pm, on, the, first, of, december, for, the, standard, menu, please]],```
            ```Reservations = [reservation(0, [1, 12], [1200, 1320, 1], 2, [1, 3], [1, 0, 0]), reservation(1, [1, 12], [1200, 1260, 1], 4, [2, 1], [0, 0, 1]), reservation(2, [1, 12], [1200, 1320, 1], 3, [1, 1], [0, 1, 0])] ```
         - Backtracking is again possible to see less viable options, looks great!

   - ```reservations_on_day```

      - Tests if the list of reservations on a specific day can indeed be linked to the list of reservations.
      - Test query: ```reservations_on_day([reservation(0, [1, 4], [1200, 1320, 1], 2, [1, 2], [1, 0, 0]), reservation(1, [1, 4], [1200, 1260, 1], 4, [2, 1], [0, 0, 1]), reservation(2, [1, 4], [1200, 1320, 1], 3, [1, 1], [0, 1, 0])], ReservationsOnDay, [2, 4]) .```
         - Answer: ```ReservationsOnDay = []```
      - Test query: ```reservations_on_day([reservation(0, [1, 4], [1200, 1320, 1], 2, [1, 2], [1, 0, 0]), reservation(1, [1, 4], [1200, 1260, 1], 4, [2, 1], [0, 0, 1]), reservation(2, [1, 4], [1200, 1320, 1], 3, [1, 1], [0, 1, 0])], ReservationsOnDay, [1, 4]) .```
         - Answer: ```ReservationsOnDay = [reservation(0, [1, 4], [1200, 1320, 1], 2, [1, 2], [1, 0, 0]), reservation(1, [1, 4], [1200, 1260, 1], 4, [2, 1], [0, 0, 1]), reservation(2, [1, 4], [1200, 1320, 1], 3, [1, 1], [0, 1, 0])]```
      - Seem good!

   - ```sort_reservations```

      - Tests if the list of reservations does indeed sort correctly based on month>day>start time> end time.
      - Uses a modified version of British museum sort from the lectures.
      - Test query:  ```sort_reservations([reservation(0, [1, 4], [1200, 1320, 1], 2, [1, 2], [1, 0, 0]), reservation(1, [1, 4], [1200, 1260, 1], 4, [2, 1], [0, 0, 1]), reservation(2, [1, 4], [1200, 1320, 1], 3, [1, 1], [0, 1, 0])], SortedReservations) . ```
         - Answer: ```SortedReservations = [reservation(1, [1, 4], [1200, 1260, 1], 4, [2, 1], [0, 0, 1]), reservation(0, [1, 4], [1200, 1320, 1], 2, [1, 2], [1, 0, 0]), reservation(2, [1, 4], [1200, 1320, 1], 3, [1, 1], [0, 1, 0])]``` 
         - Indeed, the list is ordered!

- OUTPUT SYSTEM

   - ```textual_display_reservations_on_day```
      - Test if the list of reservations is displayed correctly for a given day.
      - Test query: ```is_extra_processed_sms_inbox( Sms ), sms_to_reservations( Sms, Reservations ), textual_display_reservations_on_day(Sms, Reservations, [1,12]) .```
         - Answer: prints the reservations from the extra SMS inbox on the first of December. Perfect!
   - ```textual_print_reservations_from_extra_sms```
      - Test if the list of reservations is displayed correctly from the extra SMS inbox on a given day.
      - Test query:  ```textual_print_reservations_from_extra_sms([1,12]) .```
         - Answer: prints the reservations from the extra SMS inbox on the first of December.
      - Perfect! See bottom of Prolog file for a terminal export!
   - ```textual_print_reservations_from_extra_sms2```
      - Same as above but with more samples since it uses the second extra SMS inbox. Demonstrates system is capable of handling "preference".
      - Test query:  ```textual_print_reservations_from_extra_sms2([1,12]) .```
         - Answer: prints the reservations from the second extra SMS inbox on the first of December
      - Perfect! See bottom of Prolog file for a terminal export!
   - ```textual_print_reservations_from_provided_sms```
      - Test if the list of reservations is displayed correctly from the given SMS inbox on a given day.
      - Test query:  ```textual_print_reservations_from_provided_sms([18,3]) .```
         - Answer: prints the reservations from the provided SMS inbox on the 18th of March.
      - Perfect! See bottom of Prolog file for a terminal export!
   - ```test_textual_output_sample_XXX```
      - Made helpful test predicates to test print of individual samples from the given SMS inbox.
      - use query: ```test_textual_output_sample_XXX( ([18,3]) ) . ``` with XXX in 1..8.
      - Test query: ```test_textual_output_sample_1([18,3]) .```
         - Prints the reservations from the provided SMS inbox filter to only have first (nth1 index 1) sample on the 18th of March.
         - Answer: At 20h0, 2 people will arrive. They will have the standard menu and sit at the table for two. They will leave at 22h0.
            - Order message: [table,for,2,at,20,:,0,on,18,march]

*/