# Formative Othello Declarative Programming assignment @ VUB 2020-2021 

## Table of contents
- [Student info](#student-info)
- [Used software](#used-software)
- [Important files](#important-files)
- [Running the assignment](#running-the-assignment)
- [Assumptions made](#assumptions-made)
- [Testing the created predicates](#testing-the-created-predicates)

## Student info
- **Name**: Bontinck Lennert
- **Student ID**: 568702
- **Affiliation**: VUB - Master Computer Science: AI

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
   - Since the text messages are said to be processed no operations such as downcase_atom (lowercase transformation) are done.
   - Since we could make the NLP portion endlessly big, it is made so that only the examples and very minor extra's are accepted.
      - These extra's are tested via is_test_processed_sms_inbox.
   - Since I'm no expert in linguistics the naming for different parts of sentences might be odd.

## Testing the code

The created code was tested whilst being developed through the interpreter, making sure all returned answers for queries are correct by backtracking as well (using ;). Some predicates were made to make testing easy through a "one line" query.

Some examples of such tests through the interpreter are given below.

- GENERAL PREDICATES
   - ```minutes_since_midnight``` (CLPFD)
      - Succeeds when first parameter (MinuteSinceMidnight) is equal to the passed minutes since midnight for the given second parameter ([Hour, Minute]).
      - Test query: ```minutes_since_midnight(MinuteSinceMidnight, [20, 30]) .```
         - Answer: ```MinuteSinceMidnight = 1230.```
      - Test query: ```minutes_since_midnight(1230, [Hour, Minute]) .```
         - Answer: ```MinuteSinceMidnight = Hour = 20, Minute = 30.```
- SMS INBOX
   - ```is_processed_sms_inbox```
      - Succeeds when the argument represents the pre-processed SMS inbox provided by the assignment.
      - Test query: ```is_processed_sms_inbox(Inbox) .```
         - Answer: ```Inbox = [[table, for, 2, at, 20, :, 0, on|...], [please, can, we, have, a, table, for|...], [we, would, like, a, table, for|...], [can, i, book, a, table|...], [reserve, us, a, table|...], [9, people, on|...], [book, 6|...], [reservation|...]].```
   - ```is_extra_processed_sms_inbox```
      - Succeeds when the argument represents the pre-processed SMS inbox provided by the assignment.
      - Test query: ```is_extra_processed_sms_inbox(Inbox) .```
         - Answer: ```Inbox = [[table, for, 2, at, 20, :, 0, on|...], [hi, can, i, book, a, place, at|...], [table, for, 3, at, 8, pm|...]].```
- NLP SYSTEM
   -  ```Date``` (DCG)
      - Succeeds when the parameter (Date = [Day, Month]) is equal to the parsed textual representation of a date.
      - Test query: ```date( ExtractedDate, [first,of,april], [] ) .```
         - Answer: ```ExtractedDate = [1, 4]```
      - Test query: ```date( ExtractedDate, [23,'/',12], [] ) .```
         - Answer: ```ExtractedDate = [23, 12]```
   - ```time``` (DCG)
      - Succeeds when the parameter (Time = [Hour, Minute]) is equal to the parsed textual representation of time.
      - Test query: ```time( ExtractedTime, [18,':',00], [] ) .```
         - Answer: ```ExtractedTime = [18, 0]```
      - Test query: ```time( ExtractedTime, [6,pm], [] ) .```
         - Answer: ```ExtractedTime = [18, 0]```
      - Test query: ```time( ExtractedTime, [6,oclock], [] ) .```
         - Answer: ```ExtractedTime = [18, 0]```
   -  ```amount``` (DCG)
      -  Succeeds when the parameter (Amount) is equal to the parsed textual representation of a positive integer representing the amount.
      -  Test query: ```amount( ExtractedAmount, [5], [] ) .```
         - Answer: ```ExtractedAmount = 5```
      -  Test query: ```amount( ExtractedAmount, [0], [] ) .```
         - Answer: ```false```
   -  ```menu``` (DCG)
      -  Succeeds when the parameter (Menu) is equal to the textual representation of an allowed menu.
      -  Test query: ```menu( ExtractedMenu, [theatre], [] ) .```
         - Answer: ```ExtractedMenu = theatre```
      -  Test query: ```menu( ExtractedMenu, [deluxe], [] ) .```
         - Answer: ```false```
   -  ```reservation_request``` and thus ```sentence```  (DCG)
      - To test these an easy 1 liner is made
      - Test query: ```test_dcg_sample_1( Result ) .```
         - Answer: ```Result = [[18, 3], [20, 0, 1], 2, [1, 2]]```
      - Test query: ```test_dcg_sample_2( Result ) .```
         - Answer: ```Result = [[18, 3], [_46754, _46760, 3], 3, [2, 1]]```
      - Test query: ```test_dcg_sample_3( Result ) .```
         - Answer: ```Result = [[18, 3], [20, 0, 2], 5, [1, 2]]```
      - Test query: ```test_dcg_sample_4( Result ) .```
         - Answer: ```[[18, 3], [21, 0, 1], 2, [1, 1]]```
      - Test query: ```test_dcg_sample_5( Result ) .```
         - Answer: ```Result = [[18, 3], [_54644, _54650, 3], 4, [1, 1]]```
      - Test query: ```test_dcg_sample_6( Result ) .```
         - Answer: ```Result = [[18, 3], [_57262, _57268, 3], 9, [1, 2]]```
      - Test query: ```test_dcg_sample_7( Result ) .```
         - Answer: ```Result = [[18, 3], [20, 0, 1], 6, [1, 2]]```
      - Test query: ```test_dcg_sample_8( Result ) .```
         - Answer: ```Result = [[18, 3], [19, 0, 1], 7, [1, 2]]```
      - Test query: ```test_dcg_sample_extra_1( Result ) .```
         - Answer: ```Result = [[1, 4], [20, 0, 1], 2, [1, 2]]```
      - Test query: ```test_dcg_sample_extra_2( Result ) .```
         - Answer: ```Result = [[1, 4], [20, 0, 1], 4, [2, 1]]```
      - Test query: ```test_dcg_sample_extra_3( Result ) .```
         - Answer: ```Result = [[1, 4], [20, 0, 1], 3, [1, 1]]```
      - Test query: ```test_dcg_sample_all() .```
         - Answer: ```true```
- CONSTRAINT SYSTEM
   - ```constrain_reservation_request_menu``` (CLPFD)
      - Constraints for menu to be singular allowed menu.
      - Test query: ```constrain_reservation_request_menu([reservation_request(_Id, _Date, _Time, _Amount, [Menu, _MenuPreference], _Tables)]), indomain(Menu).```
         - Answer: ```Menu = 1 ; Menu = 2.```
   - ```constrain_reservation_request_time``` (CLPFD)
      - Constraints for restaurant time:
         - Must be in opening hours
         - Must be long enough for menu
      - Test query: ```constrain_reservation_request_time([reservation_request(_Id, _Date, [StartTime, EndTime, _TimePreference], _Amount, [1, _MenuPreference], _ClpTables)]) .```
         - Answer: ```StartTime in 1140..1260, 120+StartTime#=EndTime, EndTime in 1260..1380```
   - ```constrain_reservation_request_table``` (CLPFD)
      -  Constraints for reservation tables:
         - Tables must be able to seat all people
         - Amount of people must not exceed maximum capacity (9)
      - Test query: ```constrain_reservation_request_table([reservation_request(_Id, _Date, _Time, 6, _, [TableFor2, TableFor3, TableFor4])]), indomain(TableFor3) .```
         - Answer: ```TableFor2 = TableFor4, TableFor4 = 1, TableFor3 = 0 ; TableFor3 = TableFor4, TableFor4 = 1, TableFor2 in 0..1, _10566#=2*TableFor2+7, _10566 in 7..9.```
- OUTPUT SYSTEM
   - ```sms_to_nlp``` 
      - Links a list of SMS messages to a list of NLP representations.
      - Test query: ```is_extra_processed_sms_inbox(Inbox), sms_to_nlp(Inbox, NlpRepresentation) . ```
         - Answer: ```Inbox = [[table, for, 2, at, 20, :, 0, on, the, first, of, april], [hi, can, i, book, a, place, at, 8, pm, for, 4, persons, on, the, first, of, april, for, the, theatre, menu, please], [table, for, 3, at, 8, pm, on, the, first, of, april, for, the, standard, menu, please]],
            NlpRepresentation = [[[1, 4], [20, 0, 1], 2, [1, 2]], [[1, 4], [20, 0, 1], 4, [2, 1]], [[1, 4], [20, 0, 1], 3, [1, 1]]]```
   - ```nlp_to_clp```
      - Links a list of NLP representations to a list of CLP representations.
      - Test query (using NLP representation of extra sms inbox): ```nlp_to_clp([[[1, 4], [20, 0, 1], 2, [1, 2]], [[1, 4], [20, 0, 1], 4, [2, 1]], [[1, 4], [20, 0, 1], 3, [1, 1]]], ClpRepresention) . ```
         - Answer: ```ClpRepresention = [reservation_request(0, [1, 4], [1200, _34966, 1], 2, [1, 2], _34944), reservation_request(1, [1, 4], [1200, _35128, 1], 4, [2, 1], _35106), reservation_request(2, [1, 4], [1200, _35290, 1], 3, [1, 1], _35268)]```

