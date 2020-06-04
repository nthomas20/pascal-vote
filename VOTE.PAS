program VotingBooth;
{$V-}

uses Crt, WinTTT5, FastTTT5, ListTTT5, StrnTTT5, KeyTTT5, ReadTTT5, VoteUnit, Novell;

var
  UserNum : integer;
  LoginID : string;
  Go_On   : boolean;


procedure Login;
var
  InPass  : string;
  count   : integer;
begin
InPass := '';

  GrowMkWin(7,8,28,10,lightgray,blue,7);
    Read_String(7,9,10,'User ID#: ', 2, LoginID);
      if LoginID = '' then
        R_Char := #27;

if R_Char <> #27 then
begin
  ResetUserFile;
    for count := 1 to NumOfUsers do
      if UserNum = 0 then
      begin
        Seek(UserFile, count);
          Read(UserFile, User);
            if Upper(User.UserID) = Upper(LoginID) then
              UserNum := count;
      end;

    if UserNum <> 0 then
    begin
      Seek(UserFile, UserNum);
        Read(UserFile, User);
          Close(UserFile);
    end
    else
      begin
        Close(UserFile);
          if Registrations then
          begin
            MkWin(20,12,60,14,black,lightgray,7);
              WriteAt(21,13,black,lightgray,' Your ID# was not found...Registering. ');
                Delay(2000);
            RmWin;
              User.UserID := LoginID;
                RegisterUser(0);
              LoginID := User.UserID;
          end
          else
          begin
            MkWin(20,12,56,14,black,lightgray,7);
              WriteAt(21,13,black,lightgray,' You cannot register at this time. ');
                Delay(2000);
            RmWin;
          end;
        RmWin;
      end;

if (UserNum <> 0) then
begin
  if User.UserPass <> '' then
  begin
    GrowMkWin(15,11,46,13,lightgray,blue,7);
      Read_Password(15,12,20,'Password: ', 2, InPass);
    RmWin;
  end;

  if User.UserPass <> '' then
  begin
    if Decode(User.UserPass) = Upper(InPass) then
      Go_On := TRUE
    else
      Go_On := FALSE;
  end
  else
    Go_On := TRUE;

  RmWin;

  if Go_On then
    WriteAt(1,1,white,black,'User Name: ' + User.UserName);
end;
end
else
  Go_On := FALSE;
end;


procedure MainSystem;
var
  count      : integer;
  ChoiceList : array[1..Number_of_Choices] of string[40];
  Done       : boolean;
  AreaNum    : integer;
  Ch         : char;
  NumOfPicks : integer;
begin
if User.Able2Vote then
begin
  ReadAreas;
    GrowMkWin(14,6,76,20,white,red,7);
    repeat
      WriteAt(58,25,white,black,'           ESC to exit');
      LTTT.AllowToggle := FALSE;
      LTTT.Lines := 10;
      LTTT.TopicWidth := 55;
      LTTT.X := 15;
      LTTT.Y := 8;
         WriteAt(27, 7, white, red, 'Choose the area you want to vote in.');
           AreaListColors;
           Show_List(AreaList,50,Number_Of_Voting_Areas);
             AreaNum := L_Pick;

           if L_Char <> #27 then
           begin
             Done := FALSE;
               for count := 1 to Number_Of_Choices do
                 if (User.Choice[AreaNum, count]) and ((User.UserName <> 'Nathan Thomas') and (User.UserID <> '2324520')) then
                   Done := TRUE;

             if not Done then
             begin
               WriteAt(58,25,white,black,'ESC to abort this vote');
               ResetAreaFile;
                 Seek(AreaFile, AreaNum);
                   Read(AreaFile, Area);
               Close(AreaFile);

               if Area.AreaTitle = '<available>' then
               begin
                 Sound(700);
                   Delay(200);
                 NoSound;

                 GrowMkWin(20,12,50,14,black,lightgray,7);
                   WriteAt(21,13,black,lightgray,' Nothing to vote on in here. ');
                     Delay(1200);
                       if keypressed then
                         while keypressed do
                           ch := ReadKey;
                 RmWin;
               end
               else
               begin
                 for count := 1 to Number_Of_Choices do
                   ChoiceList[count] := Area.Choice[count];

               if Area.NumOfPicks > 1 then
                 LTTT.AllowToggle := TRUE
               else
                 LTTT.AllowToggle := FALSE;
               LTTT.Lines := 10;
               LTTT.TopicWidth := 40;
               LTTT.X := 7;
               LTTT.Y := 5;
                 GrowMkWin(6,3,53,17,blue,cyan,7);
                   if Area.NumOfPicks > 1 then
                     WriteAt(8,4,blue,cyan,'Choose ' + Int_To_Str(Area.NumOfPicks) + ' items.')
                   else
                     WriteAt(8,4,blue,cyan,'Choose 1 item.');

                     UserListColors;
                     Show_List(ChoiceList,40,Number_Of_Choices);

                 if L_Char <> #27 then
                 begin
                   Done := FALSE;

                   TempMessageBoxCh(20,12,black,lightgray,7,' Save these votes? (Y/N) ', Ch);

                   if Upper(ch) = 'Y' then
                   begin
                   NumOfPicks := 0;
                     for count := 1 to Number_Of_Choices do
                       User.Choice[AreaNum, count] := FALSE;

                     for count := 1 to Number_Of_Choices do
                     begin
                       if (L_Picks[count]) and (ChoiceList[count] <> '') then
                       begin
                         User.Choice[AreaNum, count] := TRUE;
                           Inc(NumOfPicks);

                         Done := TRUE;
                       end
                       else
                         if L_Picks[count] then
                           Done := TRUE;
                     end;

                     if (not Done) and (ChoiceList[L_Pick] <> '') then
                     begin
                       Inc(NumOfPicks);
                       User.Choice[AreaNum, L_Pick] := TRUE;
                     end;

                     if NumOfPicks <> Area.NumOfPicks then
                     begin
                       for count := 1 to Number_Of_Choices do
                         User.Choice[AreaNum, count] := FALSE;

                       TempMessageBox(8,13,black,lightgray,7,' Votes INVALID!  You MUST select ' +
                         Int_to_Str(Area.NumOfPicks) + ' items! Press any key.');
{                       TempMessageBox(8,13,black,lightgray,7,' You MUST select ' +
                         Int_To_Str(Area.NumOfPicks) + ' items! These votes erased. Press a key. ');}
                     end;
                   end;
                 end;
               RmWin;
             end;
                 L_Char := #0;
             end
             else
             begin
               Sound(700);
                 Delay(200);
               NoSound;

               GrowMkWin(20,12,52,14,black,lightgray,7);
                 WriteAt(21, 13, black, lightgray, ' You''ve already voted in here. ');
                   Delay(1200);
                     if keypressed then
                       while keypressed do
                         ch := Readkey;
               RmWin;
             end;
           end;

    until L_Char = #27;
    RmWin;
end
else
begin
  GrowMkWin(15,12,68,14,black,lightgray,7);
    WriteAt(16,13,black,lightgray,' The supervisor has revoked your voting privileges. ');
      Delay(3000);
  RmWin;
end;
end;


var
  LoginTime : NovTime;
begin
checkbreak := FALSE;
ShadColor := black;
OffCursor;
  FillScreen(1,2,80,24,black,lightgray,#177);
  FillScreen(1,1,80,1,black,black,#32);
  FillScreen(1,25,80,25,black,black,#32);

  if not ColorScreen and not ColorMonitor then
  begin
    GrowMkWin(15,9,65,13,darkgray,lightgray,5);
      WriteCenter(10,darkgray,lightgray,'T H E   V O T I N G   B O O T H');
      WriteCenter(11,darkgray,lightgray,'*******************************');
        WriteCenter(11,darkgray,lightgray,' Version ' + VersionNum + ' ');
      WriteCenter(12,darkgray,lightgray,'by Nathan Thomas');
  end
  else
  begin
    GrowMkWin(15,9,65,13,white,cyan,5);
      WriteCenter(10,yellow,cyan,'T H E   V O T I N G   B O O T H');
      WriteCenter(11,yellow,cyan,'*******************************');
        WriteCenter(11,yellow,cyan,' Version ' + VersionNum + ' ');
      WriteCenter(12,yellow,cyan,'by Nathan Thomas');
  end;

    Delay(2000);
  RmWin;

    if ClickCredits then
      ClickWrite(1,25,lightgray,black,'Voting Booth * by Nathan Thomas')
    else
      FastWrite(1,25,Attr(lightgray, black),'Voting Booth * by Nathan Thomas');

    WriteAt(1,1,white,black,'User Name:');

RTTT.WhiteSpace := #32;
RTTT.AllowEsc := TRUE;
RTTT.FCol := lightgray;
RTTT.BCol := blue;
RTTT.PFCol := white;
RTTT.PBCol := blue;
RTTT.BoxFCol := lightgray;
RTTT.BoxBCol := blue;
RTTT.Msg_BCol := red;
RTTT.Msg_FCol := yellow;
RTTT.Msg_Line := 25;

LTTT.BoxType := 2;
LTTT.LeftChar := ' ';
LTTT.RightChar := ' ';
LTTT.ToggleChar := #16;


UserNum := 0;
  if stationno <> 0 then
    GetConnInfo(GetConnNo, LoginID, LoginTime);

repeat
  Login;
until (UserNum <> 0) or (R_Char = #27);

if Go_On then
begin
  MainSystem;
    if User.Able2Vote then
    begin
      GrowMkWin(29,9,50,11,white,red,7);
        WriteAt(30,10,white,red,' Recording Votes... ');

        ResetUserFile;
          Seek(UserFile, UserNum);
            Write(UserFile, User);
        Close(Userfile);

      RmWin;
    end;
end
else
  if R_Char <> #27 then
  begin
    Sound(700);
      Delay(200);
    NoSound;

    GrowMkWin(20,12,40,14,black,lightgray,7);
      WriteAt(21,13,black,lightgray,' INVALID password! ');
        Delay(3000);
    RmWin;
  end;
TextColor(lightgray);
TextBackground(black);
ClrScr;
end.
