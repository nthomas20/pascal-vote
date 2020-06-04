program VotingBoothSetup;
{$V-}
{$R-}
{$I-}
{$M 20480, 0, 655360}

uses Crt, Printer, WinTTT5, FastTTT5, PullTTT5, ListTTT5, StrnTTT5, KeyTTT5, ReadTTT5, MiscTTT5, VoteUnit;


const
  ClickNum    = 19;
  PassNum     = 20;
  RegisterNum = 24;

  UName       = 1;
  UNum        = 2;
  Both        = 3;

var
  Menu         : Pull_Array;
  UserList     : array[1..Maximum_Num_Of_Users] of string[25];
  AreaNum      : integer;
  ToggleStatus : boolean;
  UserFormat   : integer;


{$I VHELP.PAS}


{****************************************************************************}
procedure EndProgram;
begin
  SaveVoteINI;
    TextColor(lightgray);
    TextBackground(black);
      ClrScr;

  halt;
end;


{****************************************************************************}
{$F+}
procedure Context_Help(var MenuChar : char; Heading, Sub : byte);
begin
  if (MenuChar = #187) then
    ShowHelp(Heading, Sub);
  if MenuChar = #173 then
    EndProgram;
end;
{$F-}


{****************************************************************************}
{$F+}
procedure ListHelp(var Ch : char; HiPick : integer);
var
  ChE : char;
begin
if Ch = #187 then
begin
  MkWin(15,8,65,19,white,black,7);
    WriteAt(37,8,lightgray,black,' Help ');

    WriteAt(17, 9,  lightgray, black, ' List Help');
    WriteAt(17, 10, lightgray, black, '**************');
    WriteAt(17, 12, lightgray, black, 'Use the arrow keys to move up and down the');
    WriteAt(17, 13, lightgray, black, 'list.');
    WriteAt(17, 15, lightgray, black, '<SPACE> to tag an item.');
    WriteAt(17, 16, lightgray, black, '<ENTER> to select an item.');
    WriteAt(17, 17, lightgray, black, '<ESC>   to abort');

    ChE := ReadKey;
  RmWin;
end;
end;
{$F-}



{****************************************************************************}
procedure SetupMenus;
begin
  FillChar(Menu,SizeOf(Menu),#0);
    Menu[1] := '\ File ';
      Menu[2] := 'About                 ';
      Menu[3] := 'eXit            Alt+X ';

    Menu[4] := '\ Votes ';
      Menu[5]  := 'View votes              ';
      Menu[6]  := 'Calculate winners       ';
      Menu[7]  := 'enter neW voting area   ';
      Menu[8]  := 'Modify old voting area  ';
      Menu[9]  := 'Delete old voting area  ';
      Menu[10] := 'delete All voting areas ';

    Menu[11] := '\ Users ';
      Menu[12] := 'rEgister user                  ';
      Menu[13] := 'Modify user registration       ';
      Menu[14] := 'Clear registration for user    ';
      Menu[15] := 'Toggle user voting status      ';
      Menu[16] := 'clear All votes for everyone   ';
      Menu[17] := 'clear Spec. votes for everyone ';

    Menu[18] := '\ Options ';
      if ClickCredits = TRUE then
        Menu[ClickNum] := 'turn click write Credits OFF '
      else
        Menu[ClickNum] := 'turn click write Credits ON  ';

      if Passwords = TRUE then
        Menu[PassNum] := 'turn user Passwords OFF      '
      else
        Menu[PassNum] := 'turn user Passwords ON       ';

      Menu[22] := 'change Amount of users       ';
      Menu[23] := 'protect Setup with password  ';

      if Registrations then
        Menu[RegisterNum] := 'turn Registrations OFF       '
      else
        Menu[RegisterNum] := 'turn Registrations ON        ';

      Menu[25] := 'sort User list               ';
      Menu[26] := 'sort Voting area list        ';
      Menu[27] := 'usEr list format  NAME & ID# ';

    Menu[28] := '\\';

  PTTT.LeftChar := ' ';
  PTTT.RightChar := ' ';
  PTTT.AlwaysDown := FALSE;
  PTTT.AllowEsc := FALSE;
  PTTT.TopX := 2;
  PTTT.Gap := 0;
  PTTT.Hook := Context_Help;

if not Colorscreen and not ColorMonitor then
begin
  PTTT.FCol := lightgray;
  PTTT.BCol := black;
  PTTT.CCol := white;
  PTTT.MBCol := lightgray;
  PTTT.HFCol := black;
  PTTT.HBCol := lightgray;
  PTTT.BorCol := lightgray;
end
else
begin
 PTTT.FCol := lightgray;
 PTTT.BCol := black;
 PTTT.CCol := red;
 PTTT.MBCol := lightgray;
 PTTT.HFCol := black;
 PTTT.HBCol := green;
 PTTT.BorCol := lightgray;
end;

    LTTT.BoxType := 2;
    LTTT.LeftChar := ' ';
    LTTT.RightChar := ' ';
    LTTT.ToggleChar := #16;
    LTTT.Hook := ListHelp;

  RTTT.WhiteSpace := #32;
  RTTT.AllowEsc := TRUE;
  RTTT.Msg_Line := 25;
if not ColorScreen and not ColorMonitor then
begin
  RTTT.FCol := black;
  RTTT.BCol := lightgray;
  RTTT.PFCol := black;
  RTTT.PBCol := lightgray;
  RTTT.BoxFCol := black;
  RTTT.BoxBCol := lightgray;
  RTTT.Msg_BCol := lightgray;
  RTTT.Msg_FCol := black;
end
else
begin
  RTTT.FCol := lightgray;
  RTTT.BCol := blue;
  RTTT.PFCol := white;
  RTTT.PBCol := blue;
  RTTT.BoxFCol := lightgray;
  RTTT.BoxBCol := blue;
  RTTT.Msg_BCol := red;
  RTTT.Msg_FCol := yellow;
end;

end;


{****************************************************************************}
procedure DrawMenu;
begin
  FastWrite(1,1,Attr(lightgray,black),'  File  Votes  Users  Options')
end;


{****************************************************************************}
{$F+}
procedure ShowWinnersHook(var Ch : char; HiPick : integer);
var
  NumOfVotes : array[1..Number_Of_Choices] of integer;
  WinnerList : array[1..Number_Of_Choices] of string[56];
  NextLine   : integer;
  count,
  count1     : integer;
  blank      : char;
begin
  if Ch = #187 then
    ListHelp(Ch, HiPick);
  if Ch = #188 then             {F2}
  begin
    for count := 1 to Number_Of_Choices do
    begin
      NumOfVotes[count] := 0;
      WinnerList[count] := '';
    end;

    ResetAreaFile;
      Seek(AreaFile, AreaNum);
        Read(AreaFile, Area);
    Close(AreaFile);

    ResetUserFile;
      for count := 1 to NumOfUsers do
      begin
        Seek(Userfile, count);
          Read(UserFile, User);
            for count1 := 1 to Number_Of_Choices do
              if User.Choice[AreaNum, count1] then
                Inc(NumOfVotes[count1]);
      end;
    Close(UserFile);

    NextLine := 1;

    for count := NumOfUsers downto 0 do
      for count1 := 1 to Number_Of_Choices do
        if NumOfVotes[count1] = count then
          if Area.Choice[count1] <> '' then
          begin
            WinnerList[NextLine] := Int_to_Str(NumOfVotes[count1]) + ' votes for ' + Area.Choice[count1];
              Inc(NextLine);
          end;

    if NextLine = 1 then
      WinnerList[NextLine] := 'There were no choices in this area.';

    WriteLn(Lst, 'Winners in ', Area.AreaTitle, '.');
      if IOResult = 0 then
      begin
        Write(Lst, Replicate(80,'*'));
          for count := 1 to Number_Of_Choices do
            if WinnerList[count] <> '' then
              WriteLn(Lst, WinnerList[count]);
        WriteLn(Lst, Replicate(80,'*'));
      end
      else
      begin
        Write(#7);
          if ColorMonitor or ColorScreen then
          begin
            GrowMkWin(15,10,47,12,white,blue,7);
              WriteAt(16,1,white,blue,' The printer is not available. ');
          end
          else
          begin
            GrowMkWin(15,10,47,12,white,blue,7);
              WriteAt(16,11,white,blue,' The printer is not available. ');
          end;
        blank := ReadKey;

        RmWin;
      end;
  end;

end;
{$F-}


{****************************************************************************}
procedure ShowWinners(ANum : integer);
var
  NumOfVotes : array[1..Number_Of_Choices] of integer;
  count,
  count1     : integer;
  WinnerList : array[1..Number_Of_Choices] of string[56];
  NextLine   : integer;
begin
AreaNum := ANum;

WriteAt(63,25,white,black,'F2=Print');

for count := 1 to Number_Of_Choices do
begin
  NumOfVotes[count] := 0;
  WinnerList[count] := '';
end;

ResetAreaFile;
  Seek(AreaFile, ANum);
    Read(AreaFile, Area);
Close(AreaFile);

ResetUserFile;
  for count := 1 to NumOfUsers do
  begin
    Seek(Userfile, count);
      Read(UserFile, User);
        for count1 := 1 to Number_Of_Choices do
          if User.Choice[ANum, count1] then
            Inc(NumOfVotes[count1]);
  end;
Close(UserFile);

NextLine := 1;

for count := NumOfUsers downto 0 do
  for count1 := 1 to Number_Of_Choices do
    if NumOfVotes[count1] = count then
      if Area.Choice[count1] <> '' then
      begin
        WinnerList[NextLine] := Int_to_Str(NumOfVotes[count1]) + ' votes for ' + Area.Choice[count1];
          Inc(NextLine);
      end;

if NextLine = 1 then
  WinnerList[NextLine] := 'There were no choices in this area.';


LTTT.Lines := 15;
LTTT.TopicWidth := 56;
LTTT.X := 9;
LTTT.Y := 6;
LTTT.AllowToggle := FALSE;
LTTT.Hook := ShowWinnersHook;
  GrowMkWin(8,4,71,23,white,red,7);
    WriteCenter(5, white, red, Area.AreaTitle);
    AreaListColors;
    Show_List(WinnerList,56,Number_Of_Choices);
  RmWin;
LTTT.AllowToggle := TRUE;
LTTT.Hook := ListHelp;

WriteAt(63,25,lightgray,black,'        ');
end;


{****************************************************************************}
procedure ShowUserVotes(UserNum : integer; AreaNum : integer);
var
  count,
  NextLine   : integer;
  Ch         : char;
  ChoiceList : array[1..Number_Of_Choices] of string[55];
  Temp_Pick  : integer;
  Temp_Picks : array[1..Number_Of_Voting_Areas] of boolean;
begin
Temp_Pick := L_Pick;
  for count := 1 to Number_Of_Voting_Areas do
    Temp_Picks[count] := L_Picks[count];

NextLine := 1;

ResetAreaFile;
  Seek(AreaFile, AreaNum);
    Read(AreaFile, Area);
Close(AreaFile);


ResetUserFile;
  Seek(UserFile, UserNum);
    Read(UserFile, User);
Close(UserFile);

  for count := 1 to Number_Of_Choices do
    ChoiceList[count] := '';

  for count := 1 to Number_Of_Choices do
    if User.Choice[AreaNum, count] then
    begin
      ChoiceList[NextLine] := Area.Choice[count];

      Inc(NextLine);
    end
    else
      ChoiceList[count] := '';

if ChoiceList[1] = '' then
  ChoiceList[1] := 'User has not voted yet.';
if Area.AreaTitle = '<available>' then
  ChoiceList[1] := 'Not a legal voting area.';

LTTT.Lines := 14;
LTTT.TopicWidth := 55;
LTTT.X := 10;
LTTT.Y := 6;
LTTT.AllowToggle := FALSE;
  GrowMkWin(9,3,71,22,blue,cyan,7);
    WriteCenter(3, blue, cyan, ' Personal Votes ');
    WriteCenter(4, white, cyan, ' User: ' + User.UserName + '/' + User.UserID + ' ');
    WriteCenter(5, white, cyan, 'Area: ' + Area.AreaTitle);
      UserListColors;
      Show_List(ChoiceList,55,Number_Of_Choices);
  RmWin;
LTTT.AllowToggle := TRUE;
LTTT.Lines := 10;
LTTT.TopicWidth := 55;
LTTT.X := 15;
LTTT.Y := 8;
L_Pick := Temp_Pick;
  for count := 1 to Number_Of_Voting_Areas do
    L_Picks[count] := Temp_Picks[count];
end;


{****************************************************************************}
procedure SortUserFile;
var
  count,
  count1     : integer;
  TempUser,
  TempUser1,
  TempUser2  : UserRecord;
begin
ResetUserFile;
  for count := 1 to NumOfUsers do
  begin
    for count1 := 1 to NumOfUsers - count do
    begin
      Seek(UserFile, count1);
        Read(UserFile, TempUser1);
        Read(UserFile, TempUser2);

        if TempUser1.UserName = '' then
          TempUser1.UserName := #255;
        if TempUser2.UserName = '' then
          TempUser2.UserName := #255;

          if TempUser2.UserName < TempUser1.UserName then
          begin
            TempUser := TempUser1;
            TempUser1 := TempUser2;
            TempUser2 := TempUser;
          end;

        if TempUser1.UserName = #255 then
          TempUser1.UserName := '';
        if TempUser2.UserName = #255 then
          TempUser2.UserName := '';

      Seek(UserFile, count1);
        Write(UserFile, TempUser1);
        Write(UserFile, TempUser2);
    end;
  end;
Close(UserFile);
end;


{****************************************************************************}
procedure SortAreaFile;
var
  count,
  count1     : integer;
  TempArea,
  TempArea1,
  TempArea2  : AreaRecord;
begin
ResetAreaFile;
  for count := 1 to Number_Of_Voting_Areas do
  begin
    for count1 := 1 to Number_Of_Voting_Areas - count do
    begin
      Seek(AreaFile, count1);
        Read(AreaFile, TempArea1);
        Read(AreaFile, TempArea2);

        if TempArea1.AreaTitle = '<available>' then
          TempArea1.AreaTitle := #255;
        if TempArea2.AreaTitle = '<available>' then
          TempArea2.AreaTitle := #255;

          if TempArea2.AreaTitle < TempArea1.AreaTitle then
          begin
            TempArea := TempArea1;
            TempArea1 := TempArea2;
            TempArea2 := TempArea;
          end;

        if TempArea1.AreaTitle = #255 then
          TempArea1.AreaTitle := '<available>';
        if TempArea2.AreaTitle = #255 then
          TempArea2.AreaTitle := '<available>';

      Seek(AreaFile, count1);
        Write(AreaFile, TempArea1);
        Write(AreaFile, TempArea2);
    end;
  end;
Close(AreaFile);
end;


{****************************************************************************}
procedure UpDateUserList;
var
  count,
  count1   : integer;
  TempUser : UserRecord;
begin
ResetUserFile;
  for count := 1 to NumOfUsers do
  begin
    Seek(UserFile, count);
      Read(UserFile, TempUser);
        if TempUser.UserName = '' then
          UserList[count] := #255
        else
        begin
          if UserFormat = UName then
            UserList[count] := TempUser.UserName;

          if UserFormat = UNum then
            UserList[count] := TempUser.UserID;

          if UserFormat = Both then
            UserList[count] := TempUser.UserID + ' - ' + TempUser.UserName;
        end;

          if ToggleStatus then
            if not TempUser.Able2Vote then
              UserList[count] := '*' + UserList[count]
            else
              UserList[count] := ' ' + UserList[count];
  end;
Close(UserFile);
end;


{****************************************************************************}
procedure MainProgram;
var
  Heading,
  Sub       : byte;
  finished  : boolean;
  count,
  count1,
  count2,
  count3    : integer;
  TempUser  : UserRecord;
  TempUser1 : UserRecord;
  TempArea  : AreaRecord;
  TempArea1 : AreaRecord;
  ch        : char;
  txt       : string;
  Done,
  Done1     : boolean;
  PrevUsers : integer;
  U_Picks   : array[1..Maximum_Num_Of_Users] of boolean;
  U_Pick    : integer;
  V_Picks   : array[1..Number_Of_Voting_Areas] of boolean;
  V_Pick    : integer;
begin
  Heading := 0;
  Sub := 0;
  finished := FALSE;

  repeat
    Pull_Menu(Menu, Heading, Sub);

    case Heading of
      1:
        case Sub of
          1:
          begin
            MkWin(70,25,80,25,lightgray,black,0);
            GrowMkWin(22,7,57,15,white,cyan,2);
              WriteCenter(7,white,cyan,' About ');
              WriteCenter(9,yellow,cyan,'Voting Booth Setup Utility');
              WriteCenter(11,yellow,cyan,'Version ' + VersionNum);
              WriteCenter(13,yellow,cyan,'written by Nathan Thomas');
                ch := ReadKey;
            RmWin;
            RmWin;
          end;
          2:
            finished := TRUE;
        end;
      2:
        case Sub of
          1:
          begin
            UpDateUserList;
            ReadAreas;
            GrowMkWin(7,6,37,22,blue,cyan,5);
              LTTT.Lines := 15;
              LTTT.TopicWidth := 25;
              LTTT.X := 7;
              LTTT.Y := 6;
                UserListColors;
                Show_List(UserList,25,NumOfUsers);

                  LTTT.Lines := 10;
                  LTTT.TopicWidth := 55;
                  LTTT.X := 15;
                  LTTT.Y := 8;

              if L_Char <> #27 then
              begin
                Done := FALSE;
                  for count := 1 to Maximum_Num_Of_Users do
                    U_Picks[count] := L_Picks[count];

                  U_Pick := L_Pick;

                  for count := 1 to NumOfUsers do
                  begin
                    if U_Picks[count] then
                    begin
                      GrowMkWin(14,6,76,20,white,red,7);
                        WriteAt(16,7,lightgray,red,UserList[count]);
                        AreaListColors;
                        Show_List(AreaList,50,Number_Of_Voting_Areas);

                        if L_Char <> #27 then
                        begin
                          Done1 := FALSE;

                          for count1 := 1 to Number_Of_Voting_Areas do
                          begin
                            if L_Picks[count1] then
                            begin
                              ShowUserVotes(count, count1);
                              Done1 := TRUE;
                            end;
                          end;

                              if not Done1 then
                              begin
                                ShowUserVotes(count, L_Pick);
                              end;
                        end;

                      RmWin;
                      Done := TRUE;
                    end;
                  end;

                    if not Done then
                    begin
                      GrowMkWin(14,6,76,20,white,red,7);
                        WriteAt(16,7,lightgray,red,UserList[U_Pick]);
                        AreaListColors;
                        Show_List(AreaList,50,Number_Of_Voting_Areas);

                        if L_Char <> #27 then
                        begin
                          Done1 := FALSE;

                          for count1 := 1 to Number_Of_Voting_Areas do
                          begin
                            if L_Picks[count1] then
                            begin
                              ShowUserVotes(U_Pick, count1);
                              Done1 := TRUE;
                            end;
                          end;

                              if not Done1 then
                              begin
                                ShowUserVotes(U_Pick, L_Pick);
                              end;
                        end;
                        RmWin;
                    end;
              end;

            RmWin;
          end;
          2:
          begin
            ReadAreas;
            GrowMkWin(15,8,75,19,white,red,5);
              LTTT.Lines := 10;
              LTTT.TopicWidth := 55;
              LTTT.X := 15;
              LTTT.Y := 8;
                AreaListColors;
                Show_List(AreaList,50,Number_Of_Voting_Areas);

              if L_Char <> #27 then
              begin
                Done := FALSE;
                  for count := 1 to Number_Of_Voting_Areas do
                    V_Picks[count] := L_Picks[count];

                  V_Pick := L_Pick;

                for count := 1 to Number_Of_Voting_Areas do
                begin
                  if V_Picks[count] then
                  begin
                    ShowWinners(count);

                    Done := TRUE;
                  end;
                end;

                  if not Done then
                    ShowWinners(V_Pick);
              end;
            RmWin;
          end;
          3:
            CreateVotingArea(0);
          4:
          begin
            ReadAreas;
            GrowMkWin(15,8,75,19,white,red,5);
              LTTT.Lines := 10;
              LTTT.TopicWidth := 55;
              LTTT.X := 15;
              LTTT.Y := 8;
                AreaListColors;
                Show_List(AreaList,50,Number_Of_Voting_Areas);

              if L_Char <> #27 then
              begin
                Done := FALSE;

                for count := 1 to Number_Of_Voting_Areas do
                begin
                  if L_Picks[count] then
                  begin
                    CreateVotingArea(count);

                    Done := TRUE;
                  end;
                end;

                  if Done = FALSE then
                    CreateVotingArea(L_Pick);
              end;
            RmWin;
          end;
          5:
          begin
            ReadAreas;
            GrowMkWin(15,8,75,19,white,red,5);
              LTTT.Lines := 10;
              LTTT.TopicWidth := 55;
              LTTT.X := 15;
              LTTT.Y := 8;
                AreaListColors;
                Show_List(AreaList,50,Number_Of_Voting_Areas);

              if L_Char <> #27 then
              begin
                Done := FALSE;

                TempArea.AreaTitle := '<available>';
                TempArea.NumOfPicks := 0;
                  for count1 := 1 to Number_Of_Choices do
                    TempArea.Choice[count1] := '';

                ResetAreaFile;
                ResetUserFile;

                  for count := 1 to Number_Of_Voting_Areas do
                  begin
                    if L_Picks[count] then
                    begin
                      Seek(AreaFile, count);
                        Write(AreaFile, TempArea);

                        if count <= 9 then
                          AreaList[count] := ' ' + Int_to_Str(count) + '.  ' + Area.AreaTitle
                        else
                          AreaList[count] := Int_to_Str(count) + '.  ' + Area.AreaTitle;

                      for count := 1 to NumOfUsers do
                      begin
                        Seek(UserFile, count);
                          Read(UserFile, User);

                          if User.UserName <> '' then
                          begin
                            for count1 := 1 to Number_Of_Choices do
                              User.Choice[count, count1] := FALSE;

                            Seek(UserFile, count);
                              Write(UserFile, User);
                          end;
                      end;

                    Done := TRUE;
                  end;
                end;

                  if Done = FALSE then
                  begin
                    Seek(AreaFile, L_Pick);
                      Write(AreaFile, TempArea);

                    if L_Pick <= 9 then
                      AreaList[L_Pick] := ' ' + Int_to_Str(L_Pick) + '.  ' + Area.AreaTitle
                    else
                      AreaList[L_Pick] := Int_to_Str(L_Pick) + '.  ' + Area.AreaTitle;

                      for count := 1 to NumOfUsers do
                      begin
                        Seek(UserFile, count);
                          Read(UserFile, User);

                          if User.UserName <> '' then
                          begin
                            for count1 := 1 to Number_Of_Choices do
                              User.Choice[L_Pick, count1] := FALSE;

                            Seek(UserFile, count);
                              Write(UserFile, User);
                          end;
                      end;
                  end;

                Close(AreaFile);
                Close(UserFile);
              end;
            RmWin;
          end;
          6:
          begin
            TempMessageBoxCh(20,12,black,lightgray,7,' Are you sure? (Y/N) ', Ch);

            if Upper(Ch) = 'Y' then
            begin
              TempArea.AreaTitle := '<available>';
              TempArea.NumOfPicks := 0;
                for count := 1 to Number_Of_Choices do
                  TempArea.Choice[count] := '';

              ResetAreaFile;
                for count := 1 to Number_Of_Voting_Areas do
                begin
                  Seek(AreaFile, count);
                    Write(AreaFile, TempArea);
                end;
              Close(Areafile);

                ResetUserFile;

                for count := 1 to NumOfUsers do
                begin
                  Seek(UserFile, count);
                    Read(UserFile, TempUser);

                    if TempUser.UserName <> '' then
                    begin
                      for count1 := 1 to Number_Of_Voting_Areas do
                        for count2 := 1 to Number_Of_Choices do
                          TempUser.Choice[count1, count2] := FALSE;

                      Seek(UserFile, count);
                        Write(UserFile, TempUser);
                    end;
                end;

                Close(UserFile);

            end;
          end;
        end;
      3:
        case Sub of
          1:
          begin
            User.UserID := '';
              RegisterUser(0);
          end;
          2:
          begin
            UpDateUserList;
            GrowMkWin(7,6,37,22,blue,cyan,5);
              LTTT.Lines := 15;
              LTTT.TopicWidth := 25;
              LTTT.X := 7;
              LTTT.Y := 6;
                UserListColors;
                Show_List(UserList,25,NumOfUsers);

              if L_Char <> #27 then
              begin
                Done := FALSE;

                for count := 1 to NumOfUsers do
                begin
                  if L_Picks[count] then
                  begin
                    RegisterUser(count);

                    Done := TRUE;
                  end;
                end;

                  if Done = FALSE then
                    RegisterUser(L_Pick);
              end;

            RmWin;
          end;
          3:
          begin
            UpDateUserList;
            GrowMkWin(7,6,37,22,blue,cyan,5);
              LTTT.Lines := 15;
              LTTT.TopicWidth := 25;
              LTTT.X := 7;
              LTTT.Y := 6;
                UserListColors;
                Show_List(UserList,25,NumOfUsers);
                  TempUser.UserName := '';
                  TempUser.UserID := '';
                  TempUser.UserPass := '';
                  TempUser.Able2Vote := TRUE;
                    for count := 1 to Number_Of_Voting_Areas do
                      for count1 := 1 to Number_Of_Choices do
                        TempUser.Choice[count, count1] := FALSE;

              if L_Char <> #27 then
              begin
                Done := FALSE;

                ResetUserFile;
                  for count := 1 to NumOfUsers do
                  begin
                    if L_Picks[count] then
                    begin
                      Seek(UserFile, count);
                        Write(UserFile, TempUser);
                          UserList[count] := '';

                      Done := TRUE;
                    end;
                  end;

                    if Done = FALSE then
                    begin
                      Seek(UserFile, L_Pick);
                        Write(UserFile, TempUser);
                          UserList[L_Pick] := '';
                    end;

                Close(UserFile);
              end;

            RmWin;
          end;
          4:
          begin
            ToggleStatus := TRUE;
              UpDateUserList;
            ToggleStatus := FALSE;
            GrowMkWin(7,6,37,22,blue,cyan,5);
              LTTT.Lines := 15;
              LTTT.TopicWidth := 25;
              LTTT.X := 7;
              LTTT.Y := 6;
                UserListColors;
                Show_List(UserList,25,NumOfUsers);

              if L_Char <> #27 then
              begin
                Done := FALSE;

                ResetUserFile;

                  for count := 1 to NumOfUsers do
                  begin
                    if L_Picks[count] then
                    begin
                      Seek(UserFile, count);
                        Read(UserFile, User);

                        if User.Able2Vote then
                          txt := User.UserName + ' CAN vote.'
                        else
                          txt := User.UserName + ' CANNOT vote.';

                        TempMessageBoxCh(15,10,black,lightgray,7,txt + ' Toggle? (Y/N)',Ch);

                          if Upper(Ch) = 'Y' then
                            User.Able2Vote := not User.Able2Vote;

                      Seek(UserFile, count);
                        Write(UserFile, User);

                      Done := TRUE;
                    end;
                  end;

                    if Done = FALSE then
                    begin
                      Seek(UserFile, L_Pick);
                        Read(UserFile, User);

                        if User.Able2Vote then
                          txt := User.UserName + ' CAN vote.'
                        else
                          txt := User.UserName + ' CANNOT vote.';

                        TempMessageBoxCh(15,10,black,lightgray,7,txt + ' Toggle? (Y/N)',Ch);
                          if Upper(Ch) = 'Y' then
                            User.Able2Vote := not User.Able2Vote;

                      Seek(UserFile, L_Pick);
                        Write(UserFile, User);
                    end;

                Close(UserFile);
              end;

            RmWin;
          end;
          5:
          begin
            TempMessageBoxCh(15,10,black,lightgray,7,'Are you sure you want to clear the votes? (Y/N)', Ch);
              if Upper(Ch) = 'Y' then
              begin
              MkWin(7,8,53,10,black,lightgray,7);
                WriteAt(9,9,black,lightgray,'Clearing all votes...this may take a while!');

                ResetUserFile;

                for count := 1 to NumOfUsers do
                begin
                  Seek(UserFile, count);
                    Read(UserFile, TempUser);

                    if TempUser.UserName <> '' then
                    begin
                      for count1 := 1 to Number_Of_Voting_Areas do
                        for count2 := 1 to Number_Of_Choices do
                          TempUser.Choice[count1, count2] := FALSE;

                      Seek(UserFile, count);
                        Write(UserFile, TempUser);
                    end;
                end;

                Close(UserFile);
              RmWin;
              end;
          end;
          6:
          begin
            ReadAreas;
            GrowMkWin(15,8,75,19,white,red,5);
              LTTT.Lines := 10;
              LTTT.TopicWidth := 55;
              LTTT.X := 15;
              LTTT.Y := 8;
                AreaListColors;
                Show_List(AreaList,50,Number_Of_Voting_Areas);

                if L_Char <> #27 then
                begin
                  Done := FALSE;

                  ResetUserFile;

                        for count := 1 to NumOfUsers do
                        begin
                          Seek(UserFile, count);
                            Read(Userfile, TempUser);

                            if TempUser.UserName <> '' then
                            begin
                              for count1 := 1 to Number_Of_Voting_Areas do
                                if L_Picks[count1] then
                                begin
                                  for count2 := 1 to Number_Of_Choices do
                                    TempUser.Choice[count1, count2] := FALSE;
                                end;

                                    Seek(UserFile, count);
                                      Read(UserFile, TempUser);
                            end;

                          Done := TRUE;
                        end;

                      if Done = FALSE then
                      begin
                        for count1 := 1 to NumOfUsers do
                        begin
                          Seek(UserFile, count1);
                            Read(Userfile, TempUser);

                            if TempUser.UserName <> '' then
                            begin
                              for count2 := 1 to Number_Of_Choices do
                                TempUser.Choice[L_Pick, count2] := FALSE;

                                Seek(UserFile, count1);
                                  Read(UserFile, TempUser);
                            end;
                        end;
                      end;
                  Close(UserFile);
                end;
            RmWin;
          end;
        end;
      4:
        case Sub of
          1:
          begin
            ClickCredits := not ClickCredits;

            if ClickCredits then
              Menu[ClickNum] := 'turn click write Credits OFF '
            else
              Menu[ClickNum] := 'turn click write Credits ON  ';
          end;
          2:
          begin
            Passwords := not Passwords;

            if Passwords = TRUE then
              Menu[PassNum] := 'turn user Passwords OFF      '
            else
              Menu[PassNum] := 'turn user Passwords ON       ';
          end;
          3:
          begin
            PrevUsers := NumOfUsers;
              GrowMkWin(7,8,30,10,black,lightgray,7);
                Read_Int(7,9,5,'Amount of users: ', 2, NumOfUsers, 15, Maximum_Num_Of_Users);
                  if NumOfUsers > PrevUsers then
                  begin
                    User.UserName := '';
                    User.UserID := '';
                    User.UserPass := '';
                    User.Able2Vote := TRUE;
                      for count := 1 to Number_Of_Voting_Areas do
                        for count1 := 1 to Number_Of_choices do
                          User.Choice[count, count1] := FALSE;

                    ResetUserFile;
                      for count := PrevUsers + 1 to NumOfUsers do
                      begin
                        Seek(UserFile, count);
                          Write(UserFile, User);
                      end;
                    Close(UserFile);
                  end;
              RmWin;
          end;
          4:
          begin
            GrowMkWin(7,8,31,10,lightgray,blue,7);
              Read_Password(7,9,10,'System pass: ', 2, SystemPass);
                SystemPass := Upper(SystemPass);
            RmWin;
          end;
          5:
          begin
            Registrations := not Registrations;

            if Registrations then
              Menu[RegisterNum] := 'turn Registrations OFF       '
            else
              Menu[RegisterNum] := 'turn Registrations ON        ';
          end;
          6:
          begin
            GrowMkWin(20,12,40,14,yellow,red,7);
              WriteAt(21,13,yellow,red,' Sorting User File ');

              SortUserFile;
            RmWin;
          end;
          7:
          begin
            GrowMkWin(20,12,47,14,yellow,red,7);
              WriteAt(21,13,yellow,red,' Sorting Voting Area File ');

              SortAreaFile;
            RmWin;
          end;
          8:
          begin
            Inc(UserFormat);
              if UserFormat > 3 then
                UserFormat := 1;

            if UserFormat = UName then
              Menu[27] := 'usEr list format        NAME ';

            if UserFormat = UNum then
              Menu[27] := 'usEr list format         ID# ';

            if UserFormat = Both then
              Menu[27] := 'usEr list format  NAME & ID# ';
          end;
        end;
    end;
  until finished;
end;


{****************************************************************************}
var
  AskPass : string;
begin
checkbreak := FALSE;
ShadColor := black;
ToggleStatus := FALSE;
UserFormat := Both;
SetUpMenus;
OffCursor;
  FillScreen(1,2,80,24,black,lightgray,#177);
    FillScreen(1,1,80,1,black,black,#32);
    FillScreen(1,25,80,25,black,black,#32);

  if not ColorScreen and not ColorMonitor then
  begin
    GrowMkWin(15,9,65,13,black,lightgray,5);
      WriteCenter(10,black,lightgray,'T H E   V O T I N G   B O O T H');
      WriteCenter(11,black,lightgray,'*******************************');
        WriteCenter(11,black,lightgray,' Setup Utility  V' + VersionNum + ' ');
      WriteCenter(12,black,lightgray,'by Nathan Thomas');
  end
  else
  begin
    GrowMkWin(15,9,65,13,white,cyan,5);
      WriteCenter(10,yellow,cyan,'T H E   V O T I N G   B O O T H');
      WriteCenter(11,yellow,cyan,'*******************************');
        WriteCenter(11,yellow,cyan,' Setup Utility  V' + VersionNum + ' ');
      WriteCenter(12,yellow,cyan,'by Nathan Thomas');
  end;

    Delay(2000);
  RmWin;

  DrawMenu;

    if ClickCredits then
      ClickWrite(1,25,lightgray,black,'Voting Booth Setup Utility * by Nathan Thomas')
    else
      FastWrite(1,25,Attr(lightgray, black),'Voting Booth Setup Utility * by Nathan Thomas');

    WriteAt(73,25,white,black,'F1=Help');

  if SystemPass <> '' then
  begin
    GrowMkWin(7,8,31,10,lightgray,blue,7);
      Read_Password(7,9,10,'System pass: ', 2, AskPass);
    RmWin;
      if (Upper(SystemPass) = Upper(AskPass)) or (Upper(AskPass) = Decode(SystemPassword)) then
        MainProgram;
  end
  else
    MainProgram;

    EndProgram;
end.