unit VoteUnit;
{$I-,V-,R-}

interface
const
  Number_Of_Voting_Areas = 50;
  Number_Of_Choices      = 30;
  Maximum_Num_Of_Users   = 2150;
  SystemPassword         = 'YTRFX';

  VersionNum             = '1.1b';

type
  AreaRecord = record
    AreaTitle  : string[50];
    NumOfPicks : integer;
    Choice     : array[1..Number_Of_Choices] of string[40];
  end;

  UserRecord = record
    UserName  : string[40];
    UserID    : string[10];
    UserPass  : string[20];
    Able2Vote : boolean;
    Choice    : array[1..Number_Of_Voting_Areas,1..Number_Of_Choices] of boolean;
  end;

  INIRecord = record
    Clicking      : boolean;
    Passwords     : boolean;
    Registrations : boolean;
    NumOfUsers    : integer;
    SetUpPass     : string[10];
  end;

var
  Area          : AreaRecord;
  User          : UserRecord;

  AreaFile      : file of AreaRecord;
  UserFile      : file of UserRecord;
  INIFile       : file of INIRecord;

  NoAreas       : boolean;

  AreaList      : array[1..Number_Of_Voting_Areas] of string[50];

  ClickCredits  : boolean;
  Passwords     : boolean;
  Registrations : boolean;
  NumOfUsers    : integer;
  SystemPass    : string;
  UserRecordNum : integer;
  ColorMonitor  : boolean;

procedure ResetUserFile;
procedure ResetAreaFile;
procedure ResetINIFile;

procedure ReadAreas;
procedure ReadVoteINI;
procedure SaveVoteINI;

procedure CreateVotingArea(RecordNum : integer);

procedure RegisterUser(RecordNum : integer);

procedure VotingAreaHook(var Ch : char; var CurrentField:byte;var Refresh:byte);
procedure RegisterUserHook(var Ch : char; var CurrentField:byte;var Refresh:byte);
procedure EditingHelp;
procedure RangeHelp;

function Encode(txt : string) : string;
function Decode(txt : string) : string;

procedure UserListColors;
procedure AreaListColors;

implementation

uses Dos, Crt, MiscTTT5, StrnTTT5, IOTTT5, WinTTT5, FastTTT5, ListTTT5;

var
  Next_Table : byte;


procedure RangeHelp;
var
  Ch : char;
begin
  OffCursor;
    MkWin(15,8,65,19,white,black,7);
      WriteAt(37,8,lightgray,black,' Help ');

      WriteAt(17, 9,  lightgray, black, ' Range Help');
      WriteAt(17, 10, lightgray, black, '***************');
      WriteAt(17, 12, lightgray, black, 'The values must be within 1 to ' + Int_To_Str(Number_Of_Choices) + '.');
      WriteAt(17, 14, lightgray, black, 'Values from 1 - ' + Int_To_Str(Number_Of_Choices) + ' mean the user MUST');
      WriteAt(17, 15, lightgray, black, 'choose that amount.');

      Ch := ReadKey;
    Rmwin;
OnCursor;
end;


procedure EditingHelp;
var
  Ch : char;
begin
OffCursor;
  MkWin(15,8,65,19,white,black,7);
    WriteAt(37,8,lightgray,black,' Help ');

    WriteAt(17, 9,  lightgray, black, ' Editing Help');
    WriteAt(17, 10, lightgray, black, '*****************');
    WriteAt(17, 12, lightgray, black, 'Alt-E    Clear all fields');
    WriteAt(17, 13, lightgray, black, 'Alt-D    Clear current field');
    WriteAt(17, 14, lightgray, black, 'TAB      Move to next field');
    WriteAt(17, 15, lightgray, black, 'BACKTAB  Move to previous field');
    WriteAt(17, 16, lightgray, black, 'F10      Save current input');
    WriteAt(17, 17, lightgray, black, 'ESC      Abort current input');

    Ch := ReadKey;
  RmWin;
OnCursor;
end;


{$F+}
procedure RegisterUserHook(var Ch : char; var CurrentField:byte;var Refresh:byte);
var
  ChE  : char;
  Done : boolean;
begin
Done := FALSE;
  case Ch of
    #196:
    begin
      OffCursor;
        if User.UserName = '' then
        begin
          TempMessageBox(20, 12, black, lightgray, 7, ' You can''t save without a Name. ');
            Ch := No_Char;
              Done := TRUE;
        end;
        if (User.UserID = '') and not Done then
        begin
          TempMessageBox(20, 12, black, lightgray, 7, ' You can''t save without an ID#. ');
            Ch := No_Char;
        end;
      OnCursor;
    end;
    #187:
    begin
      EditingHelp;
        Ch := No_Char;
    end;
    #27:
    begin
      OffCursor;
        TempMessageBoxCh(20, 12, black, lightgray, 7, ' Do you want to abort? (Y/N) ', ChE);
      OnCursor;
      if Upper(ChE) = 'Y' then
        Refresh := End_Input
      else
        Ch := No_Char;
    end;
  end;
end;
{$F-}


{$F+}
procedure VotingAreaHook(var Ch : char; var CurrentField:byte;var Refresh:byte);
var
  ChE               : char;
  There_Are_Choices : boolean;
  count             : integer;
  Done              : boolean;
begin
Done := FALSE;
  case Ch of
  #196:
  begin
    There_Are_Choices := FALSE;
      OffCursor;
        if Area.AreaTitle = '' then
        begin
          TempMessageBox(20, 12, black, lightgray, 7, ' You can''t save without a Title. ');
            Ch := No_Char;
              Done := TRUE;
        end;
          for count := 1 to Number_Of_Choices do
            if Area.Choice[count] <> '' then
              There_Are_Choices := TRUE;

        if not There_Are_Choices and not Done then
        begin
          TempMessageBox(20, 12, black, lightgray, 7, ' You can''t save without atleast one choice. ');
            Ch := No_Char;
        end;
      OnCursor;
  end;
  #201:                       {PgUp}
  begin
    if Next_Table = 2 then
    begin
      Next_Table := 1;
      Refresh := End_Input;
    end;
  end;
  #209:                       {PgDn}
  begin
    if Next_Table = 1 then
    begin
      Next_Table := 2;
      Refresh := End_Input;
    end;
  end;
  #27:
  begin
    OffCursor;
      TempMessageBoxCh(20, 12, black, lightgray, 7, ' Do you want to abort? (Y/N) ', ChE);
    OnCursor;
    if Upper(ChE) = 'Y' then
    begin
      Next_Table := 0;
      Refresh := End_Input;
    end
    else
      Ch := No_Char;
  end;
  #187:
  begin
    if CurrentField <> 2 then
      EditingHelp
    else
      RangeHelp;

      Ch := No_Char;
  end;
end;
end;
{$F-}


procedure ResetUserFile;
var
  TempResult : integer;
  count      : integer;
begin
  repeat
    Reset(UserFile);
      TempResult := IOResult;
        if TempResult <> 0 then
          delay(50);
  until TempResult = 0;
end;


procedure ResetAreaFile;
var
  TempResult : integer;
begin
  repeat
    Reset(AreaFile);
      TempResult := IOResult;
        if TempResult <> 0 then
          delay(50);
  until TempResult = 0;
end;


procedure ResetINIFile;
var
  TempResult : integer;
begin
  repeat
    Reset(INIFile);
      TempResult := IOResult;
        if TempResult <> 0 then
          delay(50);
  until TempResult = 0;
end;


procedure ReadVoteINI;
var
  INI : INIRecord;
begin
  if Exist('VOTE.INI') then
  begin
    ResetINIFile;
      Read(INIFile, INI);
    Close(INIFile);
  end
  else
  begin
    Rewrite(INIFile);
      INI.Clicking := TRUE;
      INI.Passwords := TRUE;
      INI.Registrations := TRUE;
      INI.NumOfUsers := 15;
      INI.SetupPass := '';
        Write(INIFile, INI);
    Close(INIFile);
  end;

    ClickCredits := INI.Clicking;
    Passwords := INI.Passwords;
    NumOfUsers := INI.NumOfUsers;
    Registrations := INI.Registrations;
    SystemPass := Decode(INI.SetupPass);

end;


procedure SaveVoteINI;
var
  INI : INIRecord;
begin
  ResetINIFile;
    INI.Clicking := ClickCredits;
    INI.Passwords := Passwords;
    INI.Registrations := Registrations;
    INI.NumOfUsers := NumOfUsers;
    INI.SetupPass := Encode(SystemPass);
      Write(INIFile, INI);
  Close(INIFile);
end;


procedure ReadAreas;
var
  count  : integer;
  count1 : integer;
begin
  if Exist('~_ALST.VTE') then
  begin
    NoAreas := TRUE;

    ResetAreaFile;
      for count := 1 to Number_Of_Voting_Areas do
      begin
        Seek(AreaFile, count);
          Read(AreaFile, Area);

          if Area.AreaTitle <> '<available>' then
            NoAreas := FALSE;

          if count <= 9 then
            AreaList[count] := ' ' + Int_to_Str(count) + '.  ' + Area.AreaTitle
          else
            AreaList[count] := Int_to_Str(count) + '.  ' + Area.AreaTitle;
      end;

    Close(AreaFile);
  end
  else
  begin
    Rewrite(AreaFile);
      for count1 := 1 to Number_Of_Choices do
        Area.Choice[count1] := '';

      Area.AreaTitle := 'VSETUP Area File' + Chr(0) + Chr(26);
        Seek(AreaFile, 0);
          Write(AreaFile, Area);

      Area.AreaTitle := '<available>';

      for count := 1 to Number_Of_Voting_Areas do
      begin
        Seek(AreaFile, count);
          Write(AreaFile, Area);

        if count <= 9 then
          AreaList[count] := ' ' + Int_to_Str(count) + '.  ' + Area.AreaTitle
        else
          AreaList[count] := Int_to_Str(count) + '.  ' + Area.AreaTitle;
      end;
    Close(AreaFile);

    NoAreas := TRUE;
  end;
end;


procedure CreateVotingArea(RecordNum : integer);

  procedure Display_Page1;
  var
    count : integer;
  begin
    FillScreen(6, 4, 74, 22, black, lightgray, #32);
      WriteAt(60, 3, black, lightgray, ' Page 1 of 2 ');
      WriteCenter(23, black, lightgray, ' F10 to save / PgDn for other choices ');
      WriteAt(7, 4, black, lightgray, 'Area Title:');
      WriteAt(7, 5, black, lightgray, 'Number of items the user must select:');

      for count := 1 to 15 do
        if count <= 9 then
          WriteAt(7, count + 6, black, lightgray, 'Choice  ' + Int_to_Str(count) + ':')
        else
          WriteAt(7, count + 6, black, lightgray, 'Choice ' + Int_to_Str(count) + ':');
  end;


  procedure Display_Page2;
  var
    count : integer;
  begin
    FillScreen(6, 4, 74, 22, black, lightgray, #32);
      WriteAt(60, 3, black, lightgray, ' Page 2 of 2 ');
      WriteCenter(23, black, lightgray, ' F10 to save / PgUp for other choices ');
      WriteAt(7, 4, black, lightgray, 'Area Title:');
      WriteAt(7, 5, black, lightgray, 'Number of items the user must select:');

      for count := 1 to 15 do
        WriteAt(7, count + 6, black, lightgray, 'Choice ' + Int_to_Str(count + 15) + ':');
  end;


  procedure Process_Table1(Field : byte);
  begin
    Activate_Table(1);
      Display_Page1;
      Display_All_Fields;
      Process_Input(Field);
  end;


  procedure Process_Table2;
  begin
    Activate_Table(2);
    Display_Page2;
    Display_All_Fields;
    Process_Input(1);
  end;


var
  count,
  count1   : integer;
  TempArea : AreaRecord;
  finished : boolean;
begin
Area.AreaTitle := '';
Area.NumOfPicks := 1;
finished := FALSE;

for count := 1 to Number_Of_Voting_Areas do
  Area.Choice[count] := '';

  if RecordNum <> 0 then
  begin
    ResetAreaFile;
      Seek(AreaFile, RecordNum);
        Read(AreaFile, Area);
    Close(AreaFile);
  end;

  Create_Tables(2);

  for count := 1 to 2 do
    with Table[count]^.ITTT do
    begin
      HiFCol := lightgray;
      HiBCol := black;
      LoFCol := black;
      LoBCol := lightgray;
      MsgFCol := black;
      MsgBCol := lightgray;
      WhiteSpace := #32;
      ErrorLine := 25;
      AllowEsc := TRUE;
    end;
      Activate_Table(1);
      Create_Fields(17);
        Add_Field(1,17,2,17,2, 19, 4);
          String_Field(1, Area.AreaTitle, Replicate(50, '*'));
        Add_Field(2,1,3,1,3,45,5);
          Integer_Field(2, Area.NumOfPicks, '**', 1, Number_Of_Choices);

      for count := 3 to 17 do
      begin
        if count <> 17 then
          Add_Field(count,count - 1,count + 1,count - 1,count + 1,18,count + 4)
        else
          Add_Field(count,16,1,16,1,18,count + 4);
        String_Field(count,Area.Choice[count - 2], Replicate(40, '*'));
      end;
        Assign_CharHook(VotingAreaHook);

      Activate_Table(2);
      Create_Fields(17);
        Add_Field(1,17,2,17,2, 19, 4);
          String_Field(1, Area.AreaTitle, Replicate(50, '*'));
        Add_Field(2,1,3,1,3,45,5);
          Integer_Field(2, Area.NumOfPicks, '**', 1, 100 + Number_Of_Choices);

      for count := 3 to 17 do
      begin
        if count <> 17 then
          Add_Field(count,count - 1,count + 1,count - 1,count + 1,18,count + 4)
        else
          Add_Field(count,16,1,16,1,18,count + 4);

        String_Field(count,Area.Choice[count + 13], Replicate(40, '*'));
      end;
        Assign_CharHook(VotingAreaHook);


    GrowMkWin(5, 3, 75, 23, black, lightgray, 7);

    Next_Table := 1;

  repeat
    if Next_Table = 1 then
      Process_Table1(1)
    else
      if Next_Table = 2 then
        Process_Table2;
  until (Next_Table = 0) or (I_char = #196);
if Area.NumOfPicks = 0 then
  Area.NumOfPicks := 1;

  if Next_Table <> 0 then
  begin
    if RecordNum <> 0 then
    begin
      ResetAreaFile;
        Seek(AreaFile, RecordNum);
          Read(AreaFile, TempArea);

            TempArea.AreaTitle := Area.AreaTitle;
            TempArea.NumOfPicks := Area.NumOfPicks;

              for count1 := 1 to Number_Of_Choices do
                TempArea.Choice[count1] := Area.Choice[count1];

        Seek(AreaFile, RecordNum);
          Write(AreaFile, TempArea);
      Close(AreaFile);

      if RecordNum <= 9 then
        AreaList[RecordNum] := ' ' + Int_to_Str(RecordNum) + '.  ' + Area.AreaTitle
      else
        AreaList[RecordNum] := Int_to_Str(RecordNum) + '.  ' + Area.AreaTitle;
    end
    else
    begin

      ResetAreaFile;
        for count := 1 to Number_Of_Voting_Areas do
        begin
          Seek(AreaFile, count);
            Read(AreaFile, TempArea);

            if (TempArea.AreaTitle = '<available>') and not finished then
            begin
              TempArea.AreaTitle := Area.AreaTitle;
              TempArea.NumOfPicks := Area.NumOfPicks;

                for count1 := 1 to Number_Of_Choices do
                  TempArea.Choice[count1] := Area.Choice[count1];

              Seek(AreaFile, count);
                Write(AreaFile, TempArea);

                finished := TRUE;

                if count <= 9 then
                  AreaList[count] := ' ' + Int_to_Str(count) + '.  ' + Area.AreaTitle
                else
                  AreaList[count] := Int_to_Str(count) + '.  ' + Area.AreaTitle;
            end;
        end;
      Close(AreaFile);
    end;
  end;

  RmWin;
    Dispose_Fields;
    Dispose_Tables;
end;


procedure RegisterUser(RecordNum : integer);
var
  count      : integer;
  TempUser   : UserRecord;
  found      : boolean;
begin
found := FALSE;

User.UserName := '';
User.UserPass := '';
User.Able2Vote := TRUE;
UserRecordNum := 0;

  if RecordNum <> 0 then
  begin
    ResetUserFile;
      Seek(UserFile, RecordNum);
        Read(UserFile, User);

        User.UserPass := Decode(User.UserPass);
    Close(UserFile);
  end;

  Create_Tables(1);
  if not Passwords and (User.UserPass = '') then
    Create_Fields(2)
  else
    Create_Fields(3);

    with Table[1]^.ITTT do
    begin
      HiFCol := lightgray;
      HiBCol := black;
      LoFCol := black;
      LoBCol := lightgray;
      MsgFCol := black;
      MsgBCol := lightgray;
      WhiteSpace := #32;
      ErrorLine := 25;
      AllowEsc := TRUE;
    end;

    GrowMkWin(7,7,73,18,black,lightgray,6);
      FastWrite(9,9,Attr(black,lightgray),'User Name:');
      FastWrite(9,11,Attr(black,lightgray),'  User ID:');
      FastWrite(9,13,Attr(black,lightgray),' Password:');
      WriteCenter(16,black,lightgray,'BKTAB/UP for previous    TAB/DOWN for next');
      WriteCenter(17,black,lightgray,'F10 to register user');

    if not Passwords and (User.UserPass = '') then
    begin
      Add_Field(1,2,2,2,2,20,9);
        String_Field(1,User.UserName,Replicate(40,'@'));
      Add_Field(2,1,1,1,1,20,11);
        String_Field(2,User.UserID,'**********');
    end
    else
    begin
      Add_Field(1,3,2,3,2,20,9);
        String_Field(1,User.UserName,Replicate(40,'@'));
      Add_Field(2,1,3,1,3,20,11);
        String_Field(2,User.UserID,'**********');
        Add_Field(3,2,1,2,1,20,13);
          String_Field(3,User.UserPass,'********************');
    end;
        Assign_CharHook(RegisterUserHook);

      Process_Input(1);

        case I_Char of
          #27:
          begin
            {DON'T register user!}
          end;
          #196:
          begin
            User.UserName := Proper(User.UserName);
            User.UserID := Upper(User.UserID);
            User.UserPass := Encode(Upper(User.UserPass));

            ResetUserFile;
              if RecordNum <> 0 then
                UserRecordNum := RecordNum
              else
              begin
              found := FALSE;
                for count := 1 to NumOfUsers do
                begin
                  if UserRecordNum = 0 then
                  begin
                    Seek(UserFile, count);
                      Read(UserFile, TempUser);
                        if (Upper(TempUser.UserID) = Upper(User.UserID)) then
                          found := TRUE;

                        if (TempUser.UserName = '') and (UserRecordNum = 0) and not found then
                          UserRecordNum := count;
                  end;
                end;
              end;

              if UserRecordNum = 0 then
              begin
                OffCursor;
                  TempMessageBox(16, 12, black, lightgray, 7, ' That ID# is already in use, or there isn''t any more room. ');
                OnCursor;
              end;

              if UserRecordNum <> 0 then
              begin
                Seek(UserFile, UserRecordNum);
                  Write(UserFile, User);
              end;
            Close(UserFile);
          end;
        end;
    RmWin;
  Dispose_Fields;
  Dispose_Tables;
end;


function Encode(txt : string) : string;
var
  count : integer;
  vtxt  : string;
begin
vtxt := txt;

  for count := 1 to Length(vtxt) do
    vtxt[count] := Chr(Ord(vtxt[count]) + 5);

  Encode := vtxt;
end;


function Decode(txt : string) : string;
var
  count : integer;
  vtxt  : string;
begin
vtxt := txt;

  for count := 1 to Length(vtxt) do
    vtxt[count] := Chr(Ord(vtxt[count]) - 5);

  Decode := vtxt;
end;


procedure UserListColors;
begin
  if ColorScreen and ColorMonitor then
  begin
    LTTT.BoxFCol := blue;
    LTTT.BoxBCol := cyan;
    LTTT.CapFCol := blue;
    LTTT.BacCol := cyan;
    LTTT.NorFCol := blue;
    LTTT.HiFCol := cyan;
    LTTT.HiBCol := blue;
  end
  else
  begin
    LTTT.BoxFCol := black;
    LTTT.BoxBCol := lightgray;
    LTTT.CapFCol := black;
    LTTT.BacCol := lightgray;
    LTTT.NorFCol := black;
    LTTT.HiFCol := lightgray;
    LTTT.HiBCol := black;
  end;
end;


procedure AreaListColors;
begin
  if ColorScreen and ColorMonitor then
  begin
    LTTT.BoxFCol := white;
    LTTT.BoxBCol := red;
    LTTT.CapFCol := white;
    LTTT.BacCol := red;
    LTTT.NorFCol := white;
    LTTT.HiFCol := red;
    LTTT.HiBCol := lightgray;
  end
  else
  begin
    LTTT.BoxFCol := black;
    LTTT.BoxBCol := lightgray;
    LTTT.CapFCol := black;
    LTTT.BacCol := lightgray;
    LTTT.NorFCol := black;
    LTTT.HiFCol := lightgray;
    LTTT.HiBCol := black;
  end;
end;



var
  count,
  count1,
  count2  : integer;
  X,
  Y       : integer;
begin
if (ParamStr(1) = '/?') or (ParamStr(1) = '-?') then
begin
  WriteLn(Upper(ParamStr(0)),'  [-m | -c]');
  WriteLn('      -m = monochrome');
  WriteLn('      -c = color');
    halt;
end;

  if ColorScreen then
    ColorMonitor := TRUE
  else
    ColorMonitor := FALSE;

  if (Upper(ParamStr(1)) = '-M') or (Upper(ParamStr(1)) = '/M') then
    ColorMonitor := FALSE;
  if (Upper(ParamStr(1)) = '-C') or (Upper(ParamStr(1)) = '/C') then
    ColorMonitor := TRUE;

  Assign(AreaFile, '~_ALST.VTE');
  Assign(UserFile, 'U@CHS_2.VTE');
  Assign(INIFile, 'VOTE.INI');
    Write('* One moment...');
      ReadVoteINI;
      ReadAreas;

    if not Exist('U@CHS_2.VTE') then
    begin
      WriteLn;
      Write('* Creating user file...One moment...');
        X := WhereX;
        Y := WhereY;

        User.UserID := '';
        User.UserPass := '';
        User.Able2Vote := TRUE;

      Rewrite(UserFile);
        Seek(UserFile, 0);
          User.UserName := 'VSETUP User File' + Chr(0) + Chr(26);
            Write(UserFile, User);

        User.UserName := '';

        for count1 := 1 to Number_Of_Voting_Areas do
          for count2 := 1 to Number_Of_Choices do
            User.Choice[count1, count2] := FALSE;

        for count := 1 to NumOfUsers do
        begin
          Seek(UserFile, count);
            Write(UserFile, User);
              GotoXY(X,Y);
                Write(count);
        end;
      Close(UserFile);
    end;
end.
