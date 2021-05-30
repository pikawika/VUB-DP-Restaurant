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
   
- NLP SYSTEM
   -  ```date``` (DCG)
      - Tests link from different natural language inputs (e.g. [first,of,april]) to internal [Month, Day] representation of date.
      - Test query: ```date( ExtractedDate, [first,of,april], [] ) .```
         - Answer: ```ExtractedDate = [1, 4]```
      - Test query: ```date( ExtractedDate, [23,'/',12], [] ) .```
         - Answer: ```ExtractedDate = [23, 12]```
   - ```time``` (DCG)
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
      -  Test query: ```menu( ExtractedMenu, [deluxe], [] ) .```
         - Answer: ```false```
   -  ```reservation_request``` and thus ```sentence```  (DCG)
      - To test these an easy 1 liner is made
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
         - Answer: ```Result = [[1, 4], [1200, 1], 2, [1, 2]]```
      - Test query: ```test_dcg_sample_extra_2( Result ) .```
         - Answer: ```Result = [[1, 4], [1200, 1], 4, [2, 1]]```
      - Test query: ```test_dcg_sample_extra_3( Result ) .```
         - Answer: ```Result = [[1, 4], [1200, 1], 3, [1, 1]]```
      - Test query: ```test_dcg_sample_all() .```
         - Answer: ```true```
   
- CONSTRAINT SYSTEM
   - ```constrain_reservation_request_menu``` (CLPFD)
      - Test constraints for the menu to be a singular allowed menu.
      - Test query: ```constrain_reservation_request_menu([reservation_request(_Id, _Date, _Time, _Amount, [Menu, _MenuPreference], _Tables)], VariablesForLabeling), indomain(Menu) .```
         - Note: This makes the menu "fixed" -> has easier results -> works when leaving MenuPreference a variable as well.
         - Answer: ```Menu = MenuNew, MenuNew = 1, VariablesForLabeling = [1]```
         - Backtrack: ```Menu = MenuNew, MenuNew = 2, VariablesForLabeling = [2].```
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
   - ```constrain_reservation_request_table``` (CLPFD)
      -  Tests constraints for tables:
         - Amount of people must not exceed maximum capacity (9).
         - Reserved tables must be able to seat all people.
      -  Test query: ```constrain_reservation_request_table([reservation_request(_Id, _Date, _Time, 6, _, [TableFor2, TableFor3, TableFor4])], VariablesForLabeling), indomain(TableFor3) .```
         - Answer: ```TableFor2 = TableFor4, TableFor4 = 1, TableFor3 = 0, VariablesForLabeling = [6, 1, 0, 1]```
         - Backtrack: ```TableFor3 = TableFor4, TableFor4 = 1, VariablesForLabeling = [6, TableFor2, 1, 1], TableFor2 in 0..1, _52694#=2*TableFor2+7, _52694 in 7..9.```
   - ```constrain_reservation_request_double_booking``` (CLPFD)
      - Tests constraints for double booking so that no table is booked twice during the same time.
      - Test query: ```constrain_reservation_request_double_booking( [reservation_request(0, [1, 4], [1200, _34966, 1], 2, [1, 2], [Table2For0, Table3For0, Table4For0]), reservation_request(1, [1, 4], [1200, _35128, 1], 4, [2, 1], [Table2For1, Table3For1, Table4For1]), reservation_request(2, [1, 4], [1200, _35290, 1], 3, [1, 1], [Table2For2, Table3For2, Table4For2])], VariablesForLabeling ) . ```
         - Answer: ```VariablesForLabeling = [1, 4, 1200, _34966, Table2For0, Table3For0, Table4For0, 1, 4|...], _35290#>=_34966#<==>_81532, _34966#>=1201#<==>_81556, _35128#>=_34966#<==>_81580, _34966#>=1201#<==>_81604, _35290#>=_35128#<==>_81628, _35290#>=1201#<==>_81652, _35290#>=1201#<==>_81676, _35128#>=1201#<==>_81700, _35128#>=1201#<==>_81724, _81700 in 0..1, _81700#/\_81628#<==>_81772, _81628 in 0..1, _81772 in 0..1, _81652#\/_81772#<==>_81844, _81652 in 0..1, _81844 in 0..1, _81844#/\_81922#<==>_81916, _81844#/\_81946#<==>_81940, _81844#/\_81970#<==>_81964, _81922 in 0..1, Table4For1#=1#<==>_81922, Table4For1#\=Table4For2#<==>_82036, Table4For0#\=Table4For1#<==>_82060, Table4For0#\=Table4For2#<==>_82084, Table4For0#=1#<==>_82108, Table4For0#=1#<==>_82132, _82108 in 0..1, _82184#/\_82108#<==>_82180, _82184 in 0..1, _82184#/\_82234#<==>_82228, _82184#/\_82258#<==>_82252, _81676#\/_82282#<==>_82184, _82234 in 0..1, Table3For0#=1#<==>_82234, Table3For0#\=Table3For2#<==>_82348, Table3For0#\=Table3For1#<==>_82372, Table3For0#=1#<==>_82396, Table3For1#\=Table3For2#<==>_82420, Table3For1#=1#<==>_81946, _81946 in 0..1, _81940 in 0..1, _81940#==>_82420, _82420 in 0..1, _82372 in 0..1, _82580#==>_82372, _82580 in 0..1, _82628#/\_82396#<==>_82580, _82628 in 0..1, _82628#/\_82132#<==>_82672, _82628#/\_82702#<==>_82696, _81724#\/_82726#<==>_82628, _82132 in 0..1, _82672 in 0..1, _82672#==>_82060, _82060 in 0..1, _82702 in 0..1, Table2For0#=1#<==>_82702, Table2For0#\=Table2For2#<==>_82882, Table2For0#=1#<==>_82258, Table2For0#\=Table2For1#<==>_82930, Table2For1#\=Table2For2#<==>_82954, Table2For1#=1#<==>_81970, _81970 in 0..1, _81964 in 0..1, _81964#==>_82954, _82954 in 0..1, _82930 in 0..1, _82696#==>_82930, _82696 in 0..1, _82882 in 0..1, _82252#==>_82882, _82252 in 0..1, _82258 in 0..1, _81724 in 0..1, _82726 in 0..1, _81604#/\_81580#<==>_82726, _81604 in 0..1, _81580 in 0..1, _82396 in 0..1, _82348 in 0..1, _82228#==>_82348, _82228 in 0..1, _81676 in 0..1, _82282 in 0..1, _81556#/\_81532#<==>_82282, _81556 in 0..1, _81532 in 0..1, _82180 in 0..1, _82180#==>_82084, _82084 in 0..1, _82036 in 0..1, _81916#==>_82036, _81916 in 0..1 ```
         - This answer is obviously hard to validate but when looking at the variables of Tables (Table2For0 etc) it does indeed look as if the system recognizes these can not be 1 at the same time for overlapping reservations, which the constraint should indeed enforce.
   
- CONVERSION SYSTEM
   - ```sms_to_nlp``` 
      
      - Test if the list of SMS messages links correctly with the list of NLP representations
      - Test query: ```is_extra_processed_sms_inbox(Inbox), sms_to_nlp(Inbox, NlpRepresentation) . ```
         - Answer: ```Inbox = [[table, for, 2, at, 20, :, 0, on, the, first, of, april], [hi, can, i, book, a, place, at, 8, pm, for, 4, persons, on, the, first, of, april, for, the, theatre, menu, please], [table, for, 3, at, 8, pm, on, the, first, of, april, for, the, standard, menu, please]],```
            
            ```NlpRepresentation = [[[1, 4], [1200, 1], 2, [1, 2]], [[1, 4], [1200, 1], 4, [2, 1]], [[1, 4], [1200, 1], 3, [1, 1]]]```
      
   - ```nlp_to_clp```
      
      - Test if the list of NLP representations links correctly with CLPFD reservation requests representation
      - Test query: ```nlp_to_clp([[[1, 4], [1200, 1], 2, [1, 2]], [[1, 4], [1200, 1], 4, [2, 1]], [[1, 4], [1200, 1], 3, [1, 1]]], ClpRepresention) . ```
         - Answer: ```ClpRepresention = [reservation_request(0, [1, 4], [1200, _9338, 1], 2, [1, 2], _9316), reservation_request(1, [1, 4], [1200, _9400, 1], 4, [2, 1], _9378), reservation_request(2, [1, 4], [1200, _9462, 1], 3, [1, 1], _9440)]```
      
   - ```clp_labeling```
   
      - Test if input list of reservation requests is labelled.
      - Test query: ```clp_labeling([reservation_request(0, [1, 4], [1200, EndTime1, 1], 2, [1, 2], Tables1), reservation_request(1, [1, 4], [1200, EndTime2, 1], 4, [2, 1], Tables2), reservation_request(2, [1, 4], [1200, EndTime3, 1], 3, [1, 1], Tables3)]) .```
         - Answer: ```EndTime1 = EndTime3, EndTime3 = 1320, Tables1 = [1, 0, 0], EndTime2 = 1260, Tables2 = [0, 0, 1], Tables3 = [0, 1, 0] ;```
   
   - ```sms_to_reservations```
      
      - Tests if SMS inbox can be linked with the made reservations correctly, chaining together all systems.
      - Test query: ```is_extra_processed_sms_inbox( Sms ), sms_to_reservations( Sms, Reservations ) .```
         - Answer: ```Sms = [[table, for, 2, at, 20, :, 0, on, the, first, of, april], [hi, can, i, book, a, place, at, 8, pm, for, 4, persons, on, the, first, of, april, for, the, theatre, menu, please], [table, for, 3, at, 8, pm, on, the, first, of, april, for, the, standard, menu, please]],```
            ```Reservations = [reservation(0, [1, 4], [1200, 1320, 1], 2, [1, 2], [1, 0, 0]), reservation(1, [1, 4], [1200, 1260, 1], 4, [2, 1], [0, 0, 1]), reservation(2, [1, 4], [1200, 1320, 1], 3, [1, 1], [0, 1, 0])] ```
      
   - ```reservations_on_day```
      
      - Tests if the list of reservations on a specific day can indeed be linked to the list of reservations.
      - Test query: ```reservations_on_day([reservation(0, [1, 4], [1200, 1320, 1], 2, [1, 2], [1, 0, 0]), reservation(1, [1, 4], [1200, 1260, 1], 4, [2, 1], [0, 0, 1]), reservation(2, [1, 4], [1200, 1320, 1], 3, [1, 1], [0, 1, 0])], ReservationsOnDay, [2, 4]) .```
         - Answer: ```ReservationsOnDay = []```
      - Test query: ```reservations_on_day([reservation(0, [1, 4], [1200, 1320, 1], 2, [1, 2], [1, 0, 0]), reservation(1, [1, 4], [1200, 1260, 1], 4, [2, 1], [0, 0, 1]), reservation(2, [1, 4], [1200, 1320, 1], 3, [1, 1], [0, 1, 0])], ReservationsOnDay, [1, 4]) .```
         - Answer: ```ReservationsOnDay = [reservation(0, [1, 4], [1200, 1320, 1], 2, [1, 2], [1, 0, 0]), reservation(1, [1, 4], [1200, 1260, 1], 4, [2, 1], [0, 0, 1]), reservation(2, [1, 4], [1200, 1320, 1], 3, [1, 1], [0, 1, 0])]```
      
   - ```sort_reservations```
   
      - Tests if the list of reservations does indeed sort correctly based on month>day>start time> end time.
      - Uses a modified version of British museum sort from the lectures.
      - Test query:  ```sort_reservations([reservation(0, [1, 4], [1200, 1320, 1], 2, [1, 2], [1, 0, 0]), reservation(1, [1, 4], [1200, 1260, 1], 4, [2, 1], [0, 0, 1]), reservation(2, [1, 4], [1200, 1320, 1], 3, [1, 1], [0, 1, 0])], SortedReservations) . ```
         - Answer: ```SortedReservations = [reservation(1, [1, 4], [1200, 1260, 1], 4, [2, 1], [0, 0, 1]), reservation(0, [1, 4], [1200, 1320, 1], 2, [1, 2], [1, 0, 0]), reservation(2, [1, 4], [1200, 1320, 1], 3, [1, 1], [0, 1, 0])]``` 
         - Indeed, the list is ordered!
   
- OUTPUT SYSTEM
   - ```textual_display_reservations_on_day```
      - Test if the list of reservations is displayed correctly for a given day.
      - Test query: ```is_extra_processed_sms_inbox( Sms ), sms_to_reservations( Sms, Reservations ), textual_display_reservations_on_day(Sms, Reservations, [1,4]) .```
         - Answer: prints the reservations from the extra SMS inbox on the first of April.
   - ```textual_print_reservations_from_extra_sms```
      - Test if the list of reservations is displayed correctly from the extra SMS inbox on a given day.
      - Test query:  ```textual_print_reservations_from_extra_sms([1,4]) .```
         - Answer: prints the reservations from the extra SMS inbox on the first of April.
            - At 20h0, 4 people will arrive. They will have the theatre menu and sit at the table for four. They will leave at 21h0.
               - Order message: [hi,can,i,book,a,place,at,8,pm,for,4,persons,on,the,first,of,april,for,the,theatre,menu,please]
            - At 20h0, 2 people will arrive. They will have the standard menu and sit at the table for two. They will leave at 22h0.
               - Order message: [table,for,2,at,20,:,0,on,the,first,of,april]
            - At 20h0, 3 people will arrive. They will have the standard menu and sit at the table for three. They will leave at 22h0.
               - Order message: [table,for,3,at,8,pm,on,the,first,of,april,for,the,standard,menu,please]
   - ```textual_print_reservations_from_extra_sms2```
      - Same as above but with more samples since it uses the second extra SMS inbox. Demonstrates system is capable of handling "preference".
      - Test query:  ```textual_print_reservations_from_extra_sms2([1,4]) .```
         - Answer: prints the reservations from the extra SMS inbox on the first of April.
            - At 19h0, 4 people will arrive. They will have the theatre menu and sit at the table for four. They will leave at 20h0.
               - Order message: [hi,can,i,book,a,place,preferably,at,8,pm,for,4,persons,on,the,first,of,april,for,the,theatre,menu,please]
            - At 20h0, 2 people will arrive. They will have the theatre menu and sit at the table for four. They will leave at 21h0.
               - Order message: [table,for,2,at,20,:,0,on,the,first,of,april,preferably,for,the,standard,menu]
            - [...]
   - ```textual_print_reservations_from_provided_sms```
      - Test if the list of reservations is displayed correctly from the given SMS inbox on a given day.
      - Test query:  ```textual_print_reservations_from_provided_sms([18,3]) .```
         - Answer: prints the reservations from the provided SMS inbox on the 18th of March.
   - ```test_textual_output_sample_XXX```
      - Made helpful test predicates to test print of individual samples from the given SMS inbox.
      - use query: ```test_textual_output_sample_XXX( ([18,3]) ) . ``` with XXX in 1..8.
      - Test query: ```test_textual_output_sample_1([18,3]) .```
         - Answer: Prints the reservations from the provided SMS inbox filter to only have first (nth1 index 1) sample on the 18th of March.

