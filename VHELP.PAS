procedure ShowHelp(Heading, Sub : integer);
var
  count : integer;
  txt   : array[1..10] of string[47];
  Ch    : char;
begin
if not ColorScreen and not ColorMonitor then
begin
  MkWin(1,25,80,25,black,lightgray,0);
    WriteCenter(25,black,lightgray,'Press <ESC> to continue');
end
else
begin
  MkWin(1,25,80,25,white,green,0);
    WriteCenter(25,white,green,'Press <ESC> to continue');
end;

  MkWin(15,8,65,18,white,black,7);
    WriteAt(37,8,lightgray,black,' Help ');

  for count := 1 to 10 do
    txt[count] := '';

  case Heading of
    1:
      case Sub of
        0:
        begin
          txt[1] := '* File';
          txt[2] := '*******';
          txt[3] := 'The File menu lets you leave Voting Booth Setup';
          txt[4] := 'Utility, and tells you about the program.';
        end;
        1:
        begin
          txt[1] := '* File*About';
          txt[2] := '*************';
          txt[3] := 'This option tells you a little bit about the';
          txt[4] := 'Voting Booth Setup Utility.';
        end;
        2:
        begin
          txt[1] := '* File*Exit';
          txt[2] := '************';
          txt[3] := 'The Exit command exits Voting Booth Setup,';
          txt[4] := 'removes it from memory, and returns you to DOS.';
        end;
      end;
    2:
      case Sub of
        0:
        begin
          txt[1] := '* Votes';
          txt[2] := '********';
          txt[3] := 'The Votes menu allows you to manipulate the';
          txt[4] := 'voting areas and calculate the winners in each.';
        end;
        1:
        begin
          txt[1] := '* Votes*View votes';
          txt[2] := '*******************';
          txt[3] := 'This option allows to you view individual votes';
          txt[4] := 'cast by a certain user';
        end;
        2:
        begin
          txt[1] := '* Votes*Calculate winners';
          txt[2] := '**************************';
          txt[3] := 'This option will tabulate the order of';
          txt[4] := 'winners in selected area(s) and display them';
          txt[5] := 'in a scrolling list box.';
        end;
        3:
        begin
          txt[1] := '* Votes*enter neW voting area';
          txt[2] := '******************************';
          txt[3] := 'This option allows you to enter a new voting';
          txt[4] := 'area and enter the ' + Int_to_Str(Number_Of_Choices) + ' choices from which the';
          txt[5] := 'voters can select from.';
        end;
        4:
        begin
          txt[1] := '* Votes*Modify old voting area';
          txt[2] := '*******************************';
          txt[3] := 'This option allows you to modify the title';
          txt[4] := 'and/or options of a voting area.';
        end;
        5:
        begin
          txt[1] := '* Votes*Delete old voting area';
          txt[2] := '*******************************';
          txt[3] := 'This option will delete the title and choices';
          txt[4] := 'of selected area(s).';
          txt[6] := 'Note: There is no confirmation about the';
          txt[7] := '      deletion.';
        end;
        6:
        begin
          txt[1] := '* Votes*delete All voting areas';
          txt[2] := '********************************';
          txt[3] := 'This option will first ask you if you''re';
          txt[4] := 'sure, and then will delete the titles and the';
          txt[5] := 'choices of all voting areas.';
        end;
      end;
    3:
      case Sub of
        0:
        begin
          txt[1] := '* Users';
          txt[2] := '********';
          txt[3] := 'The Users menu allows you to manipulate the';
          txt[4] := 'user records and clear their votes.';
        end;
        1:
        begin
          txt[1] := '* Users*rEgister user';
          txt[2] := '**********************';
          txt[3] := 'This option will put a new user in the Voting';
          txt[4] := 'Booth''s user database.';
          txt[6] := 'Note: If the ID they choose is already in use,';
          txt[7] := '      then they will not be able to register';
          txt[8] := '      with that ID number.';
        end;
        2:
        begin
          txt[1] := '* Users*Modify user registration';
          txt[2] := '*********************************';
          txt[3] := 'This option will allow you to change the name,';
          txt[4] := 'password (if turned on), and/or ID# of';
          txt[5] := 'selected user(s).';
        end;
        3:
        begin
          txt[1] := '* Users*Clear registration for user';
          txt[2] := '************************************';
          txt[3] := 'This option lets you delete a user';
          txt[4] := 'registration.';
          txt[6] := 'Note: There is no confirmation about the';
          txt[7] := '      deletion.';
        end;
        4:
        begin
          txt[1] := '* Users*Toggle user voting status';
          txt[2] := '**********************************';
          txt[3] := 'This option lets you keep a user from voting.';
          txt[5] := 'Note: This only affects votes made after';
          txt[6] := '      revoking.  The votes they made before';
          txt[7] := '      will still be counted in the tallies.';
        end;
        5:
        begin
          txt[1] := '* Users*clear All votes for everyone';
          txt[2] := '*************************************';
          txt[3] := 'This option will wipe out all previously made';
          txt[4] := 'votes for everyone.';
        end;
        6:
        begin
          txt[1] := '* Users*clear Spec. votes for everyone';
          txt[2] := '***************************************';
          txt[3] := 'This option will wipe out votes in chosen';
          txt[4] := 'voting areas for everyone.';
        end;
      end;
    4:
      case Sub of
        0:
        begin
          txt[1] := '* Options';
          txt[2] := '**********';
          txt[3] := 'The Options menu allows you to set some of the';
          txt[4] := 'characteristics of how the Voting Booth acts,';
          txt[5] := 'like user passwords, clicking text, etc...';
        end;
        1:
        begin
          txt[1] := '* Options*turn click write Credits ON | OFF';
          txt[2] := '********************************************';
          txt[3] := 'This option will toggle the click writing at';
          txt[4] := 'the bottom of the screen when the program';
          txt[5] := 'starts.';
        end;
        2:
        begin
          txt[1] := '* Options*turn user Passwords ON | OFF';
          txt[2] := '***************************************';
          txt[3] := 'This option will toggle the ability of the';
          txt[4] := 'users to have personal passwords.';
          txt[6] := 'Note: This option will not remove previous';
          txt[7] := '      passwords that users have. It only';
          txt[8] := '      turns off the ability to make new ones.';
        end;
        3:
        begin
          txt[1] := '* Options*change Amount of users';
          txt[2] := '*********************************';
          txt[3] := 'This allows you to change the maximum';
          txt[4] := 'amount of users that can be in the database.';
          txt[6] := 'Values range from 15 to ' + Int_to_Str(Maximum_Num_Of_Users);
        end;
        4:
        begin
          txt[1] := '* Options*protect Setup with password';
          txt[2] := '**************************************';
          txt[3] := 'If you have a Setup password, you will';
          txt[4] := 'not be able to enter the Voting Booth Setup';
          txt[5] := 'without knowing the password.';
        end;
        5:
        begin
          txt[1] := '* Options*turn Registrations ON | OFF';
          txt[2] := '**************************************';
          txt[3] := 'This option enables or disables user';
          txt[4] := 'registration in the VOTE program, not the';
          txt[5] := 'SETUP program.  Which means that if a users''';
          txt[6] := 'ID is not found, it does not try to register';
          txt[7] := 'it.';
        end;
        6:
        begin
          txt[1] := '* Options*sort User list';
          txt[2] := '*************************';
          txt[3] := 'Use this option to sort the user file list.';
        end;
        7:
        begin
          txt[1] := '* Options*sort Voting area list';
          txt[2] := '********************************';
          txt[3] := 'Use this option to sort the area file list.';
        end;
        8:
        begin
          txt[1] := '* Options*usEr list format';
          txt[2] := '***************************';
          txt[3] := 'This option allows you to change the format of';
          txt[4] := 'the user list from NAME & ID# to NAME to ID#.';
        end;
      end;
  end;


    for count := 9 to 17 do
      WriteAt(17,count,lightgray,black,txt[count-8]);

    repeat
      Ch := ReadKey;
    until Ch = #27;

    RmWin;
    RmWin;
end;