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
- **StudentID**: 568702
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

The created code was tested whilst being developed through the interpreter, making sure all returned answers for queries are correct by backtracking as well (using ;).

- SMS INBOX
   - ```is_processed_sms_inbox```
      - Succeeds when the argument represents the pre-processed SMS inbox provided by the assignment.
         - Test query: ```is_processed_sms_inbox(Inbox) .```
         - Answer: ```Inbox = [[table, for, 2, at, 20, :, 0, on|...], [please, can, we, have, a, table, for|...], [we, would, like, a, table, for|...], [can, i, book, a, table|...], [reserve, us, a, table|...], [9, people, on|...], [book, 6|...], [reservation|...]].```
- NLP SYSTEM
   -  ```day``` (DCG)
      - Succeeds when parsed textual day (e.g. first) is equal to integer representation in parameter (e.g. 1).
         - Test query: ```day( ExtractedDay, [13], [] ) .```
         - Answer: ```ExtractedDay = 13 ;```
   
   - ```month``` (DCG)
      - Succeeds when parsed textual month (e.g. march) is equal to integer representation in parameter (e.g. 3).
         - Test query: ```month( ExtractedMonth, [march], [] ) .```
         - Answer: ```ExtractedMonth = 3.```
  
   - ```reservation_request``` (DCG)
      - To test these an easy 1 liner is made
      - Test query: ```test_dcg_sample_1( Result )```
         - Answer: ```Result = [[18, 3], [20, 0, fixed], 2, [_8516, unspecified]]```
      - Test query: ```test_dcg_sample_2( Result )```
         - Answer: ```Result = [[18, 3], [_10052, _10058, unspecified], 3, [theatre, fixed]]```
      - Test query: ```test_dcg_sample_3( Result )```
         - Answer: ```Result = [[18, 3], [20, 0, preferred], 5, [_11612, unspecified]]```
      - Test query: ```test_dcg_sample_4( Result )```
         - Answer: ```Result = [[18, 3], [21, 0, fixed], 2, [standard, fixed]]```
      - Test query: ```test_dcg_sample_5( Result )```
         - Answer: ```Result = [[18, 3], [_14744, _14750, unspecified], 4, [standard, fixed]] ;```
      - Test query: ```test_dcg_sample_6( Result )```
         - Answer: ```Result = [[18, 3], [_17768, _17774, unspecified], 9, [_17756, unspecified]]```
      - Test query: ```test_dcg_sample_7( Result )```
         - Answer: ```Result = [[18, 3], [20, 0, fixed], 6, [_19304, unspecified]]```
      - Test query: ```test_dcg_sample_8( Result )```
         - Answer: ```Result = [[18, 3], [19, 0, fixed], 7, [standard, preferred]] ;```
      - ... 
