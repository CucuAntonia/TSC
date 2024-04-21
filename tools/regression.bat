echo. >> ..\reports\regression_status.txt
echo Date and time: %DATE% at %TIME%  >>  ..\reports\regression_status.txt


call run_test.bat 100 100 0 0 c INC_INC 91736824 
call run_test.bat 100 100 0 1 c INC_RAND 90328532 
call run_test.bat 100 100 0 2 c INC_DEC 349370353 
call run_test.bat 100 100 1 0 c RAND_INC 190484743
call run_test.bat 100 100 1 1 c RAND_RAND 74525460 
call run_test.bat 100 100 1 2 c RAND_DEC 79125764 
call run_test.bat 100 100 2 0 c DEC_INC 2330864113 
call run_test.bat 100 100 2 1 c DEC_RAND 3410943884
call run_test.bat 100 100 2 2 c DEC_DEC 1018632464 

@REM call run_test.bat 100 100 1 1 c RAND_RAND1 91736824
@REM call run_test.bat 100 100 1 1 c RAND_RAND2 74525760
@REM call run_test.bat 100 100 1 1 c RAND_RAND3 349370353
@REM call run_test.bat 100 100 1 1 c RAND_RAND4 190484743
@REM call run_test.bat 100 100 1 1 c RAND_RAND5 90328589
@REM call run_test.bat 100 100 1 1 c RAND_RAND6 79125764
@REM call run_test.bat 100 100 1 1 c RAND_RAND7 71197893
@REM call run_test.bat 100 100 1 1 c RAND_RAND8 2330864113
@REM call run_test.bat 100 100 1 1 c RAND_RAND9 3410943884
@REM call run_test.bat 100 100 1 1 c RAND_RAND10 1018632464

@REM call run_test.bat 50 50 1 1 gui RAND_RAND1 91736824

@REM call run_test.bat 100 100 1 1 gui RAND_RAND2 74525760
