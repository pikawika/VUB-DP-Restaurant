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

- SMS INBOX
   - ```is_processed_sms_inbox```
      - Succeeds when the argument represents the pre-processed SMS inbox provided by the assignment.
         - Test query: ```is_processed_sms_inbox(Inbox) .```
         - Answer: ```Inbox = [[table, for, 2, at, 20, :, 0, on|...], [please, can, we, have, a, table, for|...], [we, would, like, a, table, for|...], [can, i, book, a, table|...], [reserve, us, a, table|...], [9, people, on|...], [book, 6|...], [reservation|...]].```
   - ```is_extra_processed_sms_inbox```
      - Succeeds when the argument represents the pre-processed SMS inbox provided by the assignment.
         - Test query: ```is_extra_processed_sms_inbox(Inbox) .```
         - Answer: ```Inbox = XXX.```
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
         - Answer: ```Result = [[18, 3], [20, 0, fixed], 2, [_8516, unspecified]]```
      - Test query: ```test_dcg_sample_2( Result ) .```
         - Answer: ```Result = [[18, 3], [_10052, _10058, unspecified], 3, [theatre, fixed]]```
      - Test query: ```test_dcg_sample_3( Result ) .```
         - Answer: ```Result = [[18, 3], [20, 0, preferred], 5, [_11612, unspecified]]```
      - Test query: ```test_dcg_sample_4( Result ) .```
         - Answer: ```Result = [[18, 3], [21, 0, fixed], 2, [standard, fixed]]```
      - Test query: ```test_dcg_sample_5( Result ) .```
         - Answer: ```Result = [[18, 3], [_14744, _14750, unspecified], 4, [standard, fixed]] ;```
      - Test query: ```test_dcg_sample_6( Result ) .```
         - Answer: ```Result = [[18, 3], [_17768, _17774, unspecified], 9, [_17756, unspecified]]```
      - Test query: ```test_dcg_sample_7( Result ) .```
         - Answer: ```Result = [[18, 3], [20, 0, fixed], 6, [_19304, unspecified]]```
      - Test query: ```test_dcg_sample_8( Result ) .```
         - Answer: ```Result = [[18, 3], [19, 0, fixed], 7, [standard, preferred]```
      - Test query: ```test_dcg_sample_extra_1( Result ) .```
         - Answer: ```Result = [[1, 3], [20, 0, fixed], 2, [_1878, unspecified]]```
      - Test query: ```test_dcg_sample_extra_2( Result ) .```
         - Answer: ```Result = [[1, 3], [_4024, _4030, unspecified], 2, [_4012, unspecified]]```
      - Test query: ```test_dcg_sample_all() .```
         - Answer: ```true```
- CONSTRAINT SYSTEM
   - ```constrain_restaurant_time``` (CLPFD)
      - Constraints for restaurant time:
         - Must be in opening hours
         - Must be long enough for menu
      - Test query: ```constrain_reservation_time([reservation(_, _, [StartHour, StartMinute], [EndHour, EndMinute], _, 1, _)]), indomain(StartHour) .```
         - Answer: ```StartHour = 19, StartMinute = EndMinute, EndHour = 21, EndMinute in 0..60 ; [...] StartHour = 21, StartMinute = EndMinute,  ndMinute = 0, EndHour = 23. ```
   - ```constrain_reservation_table``` (CLPFD)
      -  Constraints for reservation tables:
         - Tables must be able to seat all people
         - Amount of people must not exceed maximum capacity (9)
      - Test query: ```constrain_reservation_table([reservation(_, [Day, Month], [StartHour, StartMinute], [EndHour, EndMinute], 6, _, [TableFor2, TableFor3, TableFor4])]), indomain(TableFor2) .```
         - Answer: ```TableFor2 = 0, TableFor3 = TableFor4, TableFor4 = 1 ; TableFor2 = TableFor4, TableFor4 = 1, TableFor3 in 0..1, _43406#=3*TableFor3+6, _43406 in 6..9.```
