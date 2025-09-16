Unit MainUnit;

Interface

Uses
  Winapi.Windows, Winapi.Messages, WinProcs, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids, Vcl.Menus, Vcl.ExtDlgs, WinUnitUser1, WinUnitUser2, InstructionUnit, DevUnit,
  Vcl.MPlayer, Vcl.Imaging.jpeg, Vcl.ExtCtrls, ComObj, ActiveX, ShlObj, Registry;

Type
  TMatrix = Array Of Array Of Integer;  //обычная матрица
  TCoordinates = Array[0..1] Of 0..9;   //для координат, где [0] = x, [1] = y (тоесть для матриц нужно писать наоборот)
  TMainForm = class(TForm)
    MainMenu: TMainMenu;
    StringGridUser1: TStringGrid;
    StringGridUser2: TStringGrid;
    InstructionLabel: TLabel;
    CoordEdit: TEdit;
    FileButtons: TMenuItem;
    OpenFile1Button: TMenuItem;
    OpenTextFileDialog: TOpenTextFileDialog;
    OpenFile2Button: TMenuItem;
    ShootButton: TButton;
    InstructionButton: TMenuItem;
    DevButton: TMenuItem;
    MediaPlayer: TMediaPlayer;
    BackGroundImage: TImage;
    Procedure PaintNearbuyCells(Const CurrentCoord: TCoordinates; Var StateOfBattleFieldUser: TMatrix);
    Procedure PrintCoordinatesLine();
    Procedure ReadBattleFieldFormFile(Const PathToFile: String; Var StateOfBattleFieldUser, StateShipsUser: TMatrix);
    Procedure SwitchPlayers();
    Procedure StringGridUser2KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    Procedure OpenFile1ButtonClick(Sender: TObject);
    Procedure OpenFile2ButtonClick(Sender: TObject);
    Procedure StringGridUser1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    Procedure FormCreate(Sender: TObject);
    Procedure ShootButtonClick(Sender: TObject);
    Procedure CoordEditChange(Sender: TObject);
    Procedure DestroyShip(Const Coord: TCoordinates; Var StateOfBattleFieldUser, StateShipsUser: TMatrix);
    Procedure HurtShip(Const Coord: TCoordinates; Var StateOfBattleFieldUser, StateShipsUser: TMatrix);
    Procedure Shoot(Const Coords: TCoordinates; Var StateOfBattleFieldUser, StateShipsUser: TMatrix);
    Procedure CoordEditKeyPress(Sender: TObject; var Key: Char);
    Procedure DevButtonClick(Sender: TObject);
    Procedure InstructionButtonClick(Sender: TObject);
    procedure CoordEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    Procedure CoordEditContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    Procedure CoordEditClick(Sender: TObject);
    Function GetFolderLocation(Const FolderType: String): String;
  Private
    { Private declarations }
  Public
    { Public declarations }
  End;

Var
    MainForm: TMainForm;
    InstructionForm : TInstructionForm;
    DevForm : TDevForm;
    WinFormUser1 : TWinFormUser1;
    WinFormUser2 : TWinFormUser2;
    CountOfInput : Integer;
    IsFirstPlayer, IsFirstPlayerFull, IsSecondPlayerFull, IsFieldGood, IsHit, IsOne: Boolean;
    StateShipsUser1, StateShipsUser2, StateOfBattleFieldUser1, StateOfBattleFieldUser2 : TMatrix;
Const
    SFolderKey = '\Software\Microsoft\Windows\CurrentVersion\' +
    'Explorer\Shell Folders';

Implementation

{$R *.dfm}


Procedure TMainForm.FormCreate(Sender: TObject);

Var
    SL: IShellLink;
    PF: IPersistFile;
    LnkName: WideString;
    AppName : String;
Begin
    AppName := ParamStr(0);
    CountOfInput := 0;
    MainForm.KeyPreview := True;
    IsFirstPlayer := True;
    IsHit := True;
    IsOne := False;
    BackGroundImage.Width := MainForm.ClientWidth;
    BackGroundImage.Height := MainForm.ClientHeight;
    PrintCoordinatesLine();

    OleCheck(CoCreateInstance(CLSID_ShellLink, nil, CLSCTX_INPROC_SERVER,
    IShellLink, SL));
    PF := SL as IPersistFile;
    OleCheck(SL.SetPath(PChar(AppName)));
    LnkName := GetFolderLocation('Desktop') + '\' +
        ChangeFileExt(ExtractFileName(AppName), '.lnk');
    PF.Save(PWideChar(LnkName), True);
End;

Procedure TMainForm.DevButtonClick(Sender: TObject);
Begin
    If Not Assigned(DevForm) Then
        DevForm := TDevForm.Create(Application);
    DevForm.ShowModal;
    DevForm.Free;
    DevForm := Nil;
End;

Function TMainForm.GetFolderLocation(Const FolderType: String): String;
Begin
    With TRegistry.Create Do
    Try
        RootKey := HKEY_CURRENT_USER;
        If Not OpenKey(SFolderKey, False) Then
            Raise ERegistryException.CreateFmt('Ключ "%s" не найден', [SFolderKey]);
        Result := ReadString(FolderType);
        if Result = '' Then
          Raise ERegistryException.CreateFmt('"%s" не найден в реестре', [FolderType]);
        CloseKey;
    Finally
        Free;
    End;
End;

Procedure TMainForm.InstructionButtonClick(Sender: TObject);
Begin
    If Not Assigned(InstructionForm) Then
        InstructionForm := TInstructionForm.Create(Application);
    InstructionForm.ShowModal;
    InstructionForm.Free;
    InstructionForm := Nil;
End;

Procedure TMainForm.PrintCoordinatesLine();
Var
    Alphabet: String;
Begin
    Alphabet := 'АБВГДЕЖЗИК';
    For Var I := 1 to StringGridUser1.ColCount - 1 Do
    Begin
        StringGridUser1.Cells[I,0] := Alphabet[I];
        StringGridUser2.Cells[I,0] := Alphabet[I];
        StringGridUser1.Cells[0,I] := IntToStr(I);
        StringGridUser2.Cells[0,I] := IntToStr(I);
    End;
    InstructionLabel.Caption := 'Игрок 1 и 2, выберите файл с игровым полем'; 
End;

Procedure TMainForm.CoordEditChange(Sender: TObject);
Begin
    If (Length(CoordEdit.Text) >= 3) Then
        ShootButton.Enabled := True
    Else
        ShootButton.Enabled := False;
End;

procedure TMainForm.CoordEditClick(Sender: TObject);
begin
    CoordEdit.SelStart := Length(CoordEdit.Text);
end;

Procedure TMainForm.CoordEditContextPopup(Sender: TObject; MousePos: TPoint;
  Var Handled: Boolean);
Begin
    Handled := True;
end;

Procedure TMainForm.CoordEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
Begin
    If (Key = VK_INSERT) And (ssShift In Shift) Then
        Key := Ord(#0);
    If (Key = Ord(#86)) And (ssCtrl In Shift) Then
        Key := Ord(#0)
    Else
        Case Key Of
            VK_DOWN:
                Key := Ord(#0);
            VK_UP:
                Key := Ord(#0);
            VK_LEFT:
                Key := Ord(#0);
            VK_RIGHT:
                Key := Ord(#0);
        End;
End;

Procedure TMainForm.CoordEditKeyPress(Sender: TObject; var Key: Char);
Begin
    If (Key = '.') Or (Key = '.') Then
        Key := #0
    Else
        If ((Key = #46) Or (Key = #8)) And (CountOfInput > 0) And (CoordEdit.SelLength = 0) Then
            Dec(CountOfInput)
        Else
        Begin
            Case CountOfInput Of
            0:
                If (((Key >= 'А') And (Key <= 'К')) And (Key <> 'Ё') And (Key <> 'Й')) Then
                    Inc(CountOfInput)
                Else
                    Key := #0;
            1:
                If (Key = '-') Then
                    Inc(CountOfInput)
                Else
                    Key := #0;
            2:
            Begin
                IsOne := False;
                If (Key <= '9') And (Key >= '1') Then
                Begin
                    Inc(CountOfInput);
                    If (Key = '1') Then
                        IsOne := True;
                End
                Else
                    Key := #0;
            End;
            3:
                If IsOne And (Key = '0') Then
                    Inc(CountOfInput)
                Else
                    Key := #0;
            Else
                Key := #0;
            End;
        End;
End;

Procedure TMainForm.OpenFile1ButtonClick(Sender: TObject);
Var
    PathToFile : String;
    IsCancel : Boolean;
Begin
    IsFieldGood := False;
    IsCancel := False;
    Repeat
        If OpenTextFileDialog.execute() Then
        Begin
            PathToFile := OpenTextFileDialog.FileName;
            ReadBattleFieldFormFile(PathToFile, StateOfBattleFieldUser1, StateShipsUser1);
        End
        Else
            IsCancel := True;
    Until IsFieldGood Or IsCancel;

    If Not IsCancel Then
    Begin
        IsFirstPlayerFull := True;
        If IsSecondPlayerFull Then
        Begin
            CoordEdit.Visible := True;
            ShootButton.Visible := True;
            OpenFile1Button.Enabled := False;
            OpenFile2Button.Enabled := False;
            InstructionLabel.Caption := 'Ход первого игрока';
        End
        Else
            InstructionLabel.Caption := 'Игрок 2, выберите файл с игровым полем';
    End;
End;

Procedure TMainForm.OpenFile2ButtonClick(Sender: TObject);
Var
    PathToFile : String;
    IsCancel : Boolean;
Begin
    IsFieldGood := False;
    IsCancel := False;
    Repeat
        If OpenTextFileDialog.execute() Then
        Begin
            PathToFile := OpenTextFileDialog.FileName;
            ReadBattleFieldFormFile(PathToFile, StateOfBattleFieldUser2, StateShipsUser2);
        End
        Else
            IsCancel := True;
    Until IsFieldGood Or IsCancel;

    If Not IsCancel Then
    Begin
        IsSecondPlayerFull := True;
        If IsFirstPlayerFull Then
        Begin
            CoordEdit.Visible := True;
            ShootButton.Visible := True;
            OpenFile1Button.Enabled := False;
            OpenFile2Button.Enabled := False;
            InstructionLabel.Caption := 'Ход первого игрока';
        End
        Else
            InstructionLabel.Caption := 'Игрок 1, выберите файл с игровым полем';
    End;
End;

Procedure TMainForm.StringGridUser1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
Begin
    If(Key <> null) Then
end;

Procedure TMainForm.StringGridUser2KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
Begin
    If(Key <> null) Then
End;

Procedure TMainForm.ReadBattleFieldFormFile(Const PathToFile: String; Var StateOfBattleFieldUser, StateShipsUser: TMatrix);
Var
    UserFile: TextFile;
    I, J, CurrentSize: Integer;
    Symbol: Char;
    ShipSizes: Array Of Integer;
    ShipIndex: Integer;
    CountM, CountK: Integer;

    Procedure InitializeMatrices;
    Begin
        SetLength(StateOfBattleFieldUser, 10, 10);
        SetLength(StateShipsUser, 9, 10);
        SetLength(ShipSizes, 10);
        For Var I := 0 To 8 Do
            For Var J := 0 To 9 Do
                StateShipsUser[I, J] := -6;
    End;

    Procedure SortShipsBySize;
    Var
        I, J, Temp: Integer;
        TempColumn: Array [0 .. 8] Of Integer;
    Begin
        For I := 0 To ShipIndex - 2 Do
        Begin
            For J := 0 To ShipIndex - 2 - I Do
            Begin
                If ShipSizes[J] < ShipSizes[J + 1] Then
                Begin
                    Temp := ShipSizes[J];
                    ShipSizes[J] := ShipSizes[J + 1];
                    ShipSizes[J + 1] := Temp;
                    For Var K := 0 To 8 Do
                    Begin
                        TempColumn[K] := StateShipsUser[K, J];
                        StateShipsUser[K, J] := StateShipsUser[K, J + 1];
                        StateShipsUser[K, J + 1] := TempColumn[K];
                    End;
                End;
            End;
        End;
    End;

    Procedure MarkShip(X, Y: Integer; Var Size: Integer; ShipCol: Integer);
    Begin
        If ((X >= 0) And (X < 10) And (Y >= 0) And (Y < 10)) And (StateOfBattleFieldUser[X, Y] = 1) Then
        Begin
            StateShipsUser[Size * 2, ShipCol] := Y;
            StateShipsUser[Size * 2 + 1, ShipCol] := X;
            StateOfBattleFieldUser[X, Y] := -1;
            Size := Size + 1;
            MarkShip(X + 1, Y, Size, ShipCol);
            MarkShip(X - 1, Y, Size, ShipCol);
            MarkShip(X, Y + 1, Size, ShipCol);
            MarkShip(X, Y - 1, Size, ShipCol);
        End;
    End;

    Procedure SetLastRowValues;
    Begin
        StateShipsUser[8, 0] := 4;
        StateShipsUser[8, 1] := 3;
        StateShipsUser[8, 2] := 3;
        StateShipsUser[8, 3] := 2;
        StateShipsUser[8, 4] := 2;
        StateShipsUser[8, 5] := 2;
        StateShipsUser[8, 6] := 1;
        StateShipsUser[8, 7] := 1;
        StateShipsUser[8, 8] := 1;
        StateShipsUser[8, 9] := 1;
    End;

    Procedure ValidateShipCounts;
    Var
        ShipCount: Array [1 .. 4] Of Integer;
        I: Integer;
    Begin
        For I := 1 To 4 Do
            ShipCount[I] := 0;

        For I := 0 To ShipIndex - 1 Do
        Begin
            If (ShipSizes[I] >= 1) And (ShipSizes[I] <= 4) Then
                ShipCount[ShipSizes[I]] := ShipCount[ShipSizes[I]] + 1
            Else
            Begin
                IsFieldGood := False;
            End;
        End;
        If (ShipCount[1] <> 4) Or (ShipCount[2] <> 3) Or (ShipCount[3] <> 2) Or (ShipCount[4] <> 1) Then
        Begin
            IsFieldGood := False;
        End;
    End;

    Procedure CheckShipsNeighbours;
    Type
        TArray = Array [0 .. 7] Of Integer;
    Const
        DX: TArray = (-1, -1, -1, 0, 0, 1, 1, 1);
        DY: TArray = (-1, -1, -1, 0, 0, 1, 1, 1);
    Var
        I, J, K: Integer;
        X, Y: Integer;
    Begin
        For I := 0 To High(StateOfBattleFieldUser) Do
        Begin
            For J := 0 To High(StateOfBattleFieldUser[I]) Do
            Begin
                If StateOfBattleFieldUser[I, J] > 0 Then
                Begin
                    For K := 0 To 7 Do
                    Begin
                        X := I + DX[K];
                        Y := J + DY[K];
                        If (X >= 0) And (X < 10) And (Y >= 0) And (Y < 10) Then
                        Begin
                            If (StateOfBattleFieldUser[X, Y] > 0) And (StateOfBattleFieldUser[X, Y] <> StateOfBattleFieldUser[I, J]) Then
                            Begin
                                IsFieldGood := False;
                            End;
                        End;
                    End;
                End;
            End;
        End;
    End;

Begin
    IsFieldGood := True;
    CountM := 0;
    CountK := 0;
    Try
        InitializeMatrices;
        AssignFile(UserFile, PathToFile);
        Reset(UserFile);
        Try
            For I := 0 To High(StateOfBattleFieldUser) Do
            Begin
                For J := 0 To High(StateOfBattleFieldUser[I]) Do
                Begin
                    Repeat
                        Read(UserFile, Symbol);
                    Until Not(Symbol = ' ');

                    If (Symbol = 'M') {английский} Or (Symbol = 'М') {русский} Then
                    Begin
                        StateOfBattleFieldUser[I, J] := 0;
                        CountM := CountM + 1
                    End
                    Else
                        If (Symbol = 'K') {английский} Or (Symbol = 'К') {русский} Then
                        Begin
                            StateOfBattleFieldUser[I, J] := 1;
                            CountK := CountK + 1;
                        End
                        Else
                            IsFieldGood := FAlse;
                End;
                ReadLn(UserFile);
            End;
            If (CountM <> 80) OR (CountK <> 20) Then
                IsFieldGood := False;
            ShipIndex := 0;
            For I := 0 To High(StateOfBattleFieldUser) Do
            Begin
                For J := 0 To High(StateOfBattleFieldUser[I]) Do
                Begin
                    If StateOfBattleFieldUser[I, J] = 1 Then
                    Begin
                        CurrentSize := 0;
                        MarkShip(I, J, CurrentSize, ShipIndex);
                        For Var XPos := 0 To High(StateOfBattleFieldUser) Do
                        Begin
                            For Var YPos := 0 To High(StateOfBattleFieldUser[XPos]) Do
                            Begin
                                If StateOfBattleFieldUser[XPos, YPos] = -1 Then
                                    StateOfBattleFieldUser[XPos, YPos] := CurrentSize;
                            End;
                        End;
                        ShipSizes[ShipIndex] := CurrentSize;
                        ShipIndex := ShipIndex + 1;
                    End;
                End;
            End;
            SortShipsBySize;
            SetLastRowValues;
            ValidateShipCounts;
            CheckShipsNeighbours;
        Finally
            CloseFile(UserFile);
        End;
    Except
        IsFieldGood := False;
    End;
End;

Function NotShooted(Const Coords : TCoordinates; Const StateOfBattleFieldUser : TMatrix) : Boolean;
Var
    IsNotShooted : Boolean;
Begin
    If (StateOfBattleFieldUser[Coords[1], Coords[0]] >= 0)  Then
        IsNotShooted := True
    Else
        IsNotShooted := False;
    NotShooted := IsNotShooted;
End;

Function IsThereAnyShips(Const StateShipsUser: TMatrix): Boolean;
Var
    I: Integer;
Begin
    IsThereAnyShips := False;
    For I := 0 To High(StateShipsUser[8]) Do
    Begin
        If StateShipsUser[8, I] > 0 Then
            IsThereAnyShips := True;
    End;
End;

Function IsShipInCell(Const Coords : TCoordinates; Const StateOfBattleFieldUser, StateShipsUser : TMatrix) : Boolean;
Begin
    IsShipInCell := StateOfBattleFieldUser[Coords[1]][Coords[0]] > 0;
End;

Function IsShipAlive(Const Coords : TCoordinates; Const StateShipsUser : TMatrix): Boolean;
Var
  J: Integer;
Begin
    IsShipAlive := False;
    For J := 0 To High(StateShipsUser[High(StateShipsUser)]) Do
        If StateShipsUser[High(StateShipsUser)][J] <> -6 Then
            IsShipAlive := True;
End;

Procedure TMainForm.PaintNearbuyCells(Const CurrentCoord: TCoordinates; Var StateOfBattleFieldUser: TMatrix);
var StringGridUser: TStringGrid;
begin
    If IsFirstPlayer then
        StringGridUser := StringGridUser2
    else
        StringGridUser := StringGridUser1;
    StateOfBattleFieldUser[CurrentCoord[1], CurrentCoord[0]] := -6;

    if (CurrentCoord[0] > 0) And (CurrentCoord[1] > 0) then
    begin
       StateOfBattleFieldUser[CurrentCoord[1]-1,CurrentCoord[0]-1]:=-5;
       StringGridUser.Cells[CurrentCoord[0],CurrentCoord[1]]:='·';
    end;

    if (CurrentCoord[0] < 9) And (CurrentCoord[1] < 9) then
    begin
       StateOfBattleFieldUser[CurrentCoord[1]+1,CurrentCoord[0]+1]:=-5;
       StringGridUser.Cells[CurrentCoord[0]+2,CurrentCoord[1]+2]:='·';
    end;

    if (CurrentCoord[0] < 9) And (CurrentCoord[1] > 0) then
    begin
       StateOfBattleFieldUser[CurrentCoord[1]-1,CurrentCoord[0]+1]:=-5;
       StringGridUser.Cells[CurrentCoord[0]+2,CurrentCoord[1]]:='·';
    end;

    if (CurrentCoord[0] > 0) And (CurrentCoord[1] < 9) then
    begin
       StateOfBattleFieldUser[CurrentCoord[1]+1,CurrentCoord[0]-1]:=-5;
       StringGridUser.Cells[CurrentCoord[0],CurrentCoord[1]+2]:='·';
    end;

    If (CurrentCoord[0] > 0) And (StateOfBattleFieldUser[CurrentCoord[1],CurrentCoord[0]-1] <> -6) then
    begin
       StateOfBattleFieldUser[CurrentCoord[1],CurrentCoord[0]-1]:=-5;
       StringGridUser.Cells[CurrentCoord[0],CurrentCoord[1]+1]:='·';
    end;

    If (CurrentCoord[0] < 9) And (StateOfBattleFieldUser[CurrentCoord[1],CurrentCoord[0]+1] <> -6) then
    begin
       StateOfBattleFieldUser[CurrentCoord[1],CurrentCoord[0]+1]:=-5;
       StringGridUser.Cells[CurrentCoord[0]+2,CurrentCoord[1]+1]:='·';
    end;

    If (CurrentCoord[1] > 0) And (StateOfBattleFieldUser[CurrentCoord[1]-1,CurrentCoord[0]] <> -6) then
    begin
       StateOfBattleFieldUser[CurrentCoord[1]-1,CurrentCoord[0]]:=-5;
       StringGridUser.Cells[CurrentCoord[0]+1,CurrentCoord[1]]:='·';
    end;

    If (CurrentCoord[1] < 9) And (StateOfBattleFieldUser[CurrentCoord[1]+1,CurrentCoord[0]] <> -6) then
    begin
       StateOfBattleFieldUser[CurrentCoord[1]+1,CurrentCoord[0]]:=-5;
       StringGridUser.Cells[CurrentCoord[0]+1,CurrentCoord[1]+2]:='·';
    end;
end;

Procedure TMainForm.DestroyShip(Const Coord: TCoordinates; Var StateOfBattleFieldUser, StateShipsUser: TMatrix);
Var
    NumOfShip, LengthOfShip: Integer;
    CurrentCoord: TCoordinates;
Begin
    For Var I := 0 To 7 Do
        For Var J := 0 To 9 Do
            If I Mod 2 = 1 Then
                Break
            Else
                If (Coord[0] = StateShipsUser[I, J]) And (Coord[1] = StateShipsUser[I + 1, J]) Then
                Begin
                    NumOfShip := J;
                    case J of
                        0: LengthOfShip:=4;
                        1..2: LengthOfShip:=3;
                        3..5: LengthOfShip:=2;
                        6..9: LengthOfShip:=1;
                    end;
                    Break
                End;
    For Var J := LengthOfShip - 1 Downto 0 Do
    Begin
        CurrentCoord[0] := StateShipsUser[J * 2, NumOfShip];
        CurrentCoord[1] := StateShipsUser[J * 2 + 1, NumOfShip];
        If(IsFirstPlayer) Then
            StringGridUser2.Cells[CurrentCoord[0]+1,CurrentCoord[1]+1] := 'У'
        else
            StringGridUser1.Cells[CurrentCoord[0]+1,CurrentCoord[1]+1] := 'У';
        PaintNearbuyCells(CurrentCoord, StateOfBattleFieldUser);
    End;

    If(Not IsThereAnyShips(StateShipsUser)) Then
        If(IsFirstPlayer) Then
        Begin
            If Not Assigned(WinFormUser1) Then
                WinFormUser1 := TWinFormUser1.Create(Application);
            WinFormUser1.ShowModal;
            WinFormUser1.Free;
            WinFormUser1 := Nil;
        End
        Else
        Begin
            If Not Assigned(WinFormUser2) Then
                WinFormUser2 := TWinFormUser2.Create(Application);
            WinFormUser2.ShowModal;
            WinFormUser2.Free;
            WinFormUser2 := Nil;
        End;
End;

Procedure TMainForm.HurtShip(Const Coord: TCoordinates; Var StateOfBattleFieldUser, StateShipsUser: TMatrix);
Var
    I, J, temp1, temp2: Integer;
Begin
    I := 0;
    While I < 8 Do
    Begin
        For J := 0 To 9 Do
        Begin
            If (StateShipsUser[I, J] = Coord[0]) And (StateShipsUser[I + 1, J] = Coord[1]) Then
            Begin
                Dec(StateShipsUser[8, J]);
                If (StateShipsUser[8, J] = 0) Then
                Begin
                    MediaPlayer.Filename := ExtractFileDir(ExtractFileDir(ExtractFileDir(ParamStr(0)))) + '\Sounds\death_of_ship.mp3';
                    MediaPlayer.Open;
                    MediaPlayer.Play;
                    DestroyShip(Coord, StateOfBattleFieldUser, StateShipsUser);
                End
                Else
                Begin
                    MediaPlayer.Filename := ExtractFileDir(ExtractFileDir(ExtractFileDir(ParamStr(0)))) + '\Sounds\hit_ship.mp3';
                    MediaPlayer.Open;
                    MediaPlayer.Play;
                    If(IsFirstPlayer) Then
                        StringGridUser2.Cells[Coord[0] + 1, Coord[1] + 1] := 'Р'   //grid
                    Else
                        StringGridUser1.Cells[Coord[0] + 1, Coord[1] + 1] := 'Р';  //grid
                End;
            End;
        End;
        I := I + 2;
    End;
    StateOfBattleFieldUser[Coord[1], Coord[0]] := -6;  // потому что матрица
    
End;

Function InputCoordinates(UserInput: String): TCoordinates;
Var
    Column: Char;
    Row: Integer;
    X, Y: Integer;
    Answer: TCoordinates;
Begin

    Column := UserInput[1];

    If Ord(Column) = Ord('К') Then
        X := Ord(Column) - Ord('А') - 1
    Else
        X := Ord(Column) - Ord('А');
    If Length(UserInput) = 3 Then
        Row := StrToInt(Copy(UserInput, 3, 1))
    Else
        If Length(UserInput) = 4 Then
            Row := StrToInt(Copy(UserInput, 3, 2));

    Y := Row - 1;

    Answer[0] := X;
    Answer[1] := Y;
    InputCoordinates := Answer;
End;

Procedure TMainForm.Shoot(Const Coords: TCoordinates; Var StateOfBattleFieldUser, StateShipsUser: TMatrix);
Begin
    If NotShooted(Coords, StateOfBattleFieldUser) Then
    Begin
        If (Pos('Введеная координата уже задействована', InstructionLabel.Caption) <> 0) Then
            If(IsFirstPlayer) Then
                InstructionLabel.Caption := 'Ход первого игрока'
            Else
                InstructionLabel.Caption := 'Ход второго игрока';
        If IsShipInCell(Coords, StateOfBattleFieldUser, StateShipsUser) Then
            HurtShip(Coords, StateOfBattleFieldUser, StateShipsUser)
        Else
        Begin
            MediaPlayer.Filename := ExtractFileDir(ExtractFileDir(ExtractFileDir(ParamStr(0)))) + '\Sounds\water.mp3';
            MediaPlayer.Open;
            MediaPlayer.Play;
            StateOfBattleFieldUser[Coords[1], Coords[0]] := -5;
            If(IsFirstPlayer) Then
                StringGridUser2.Cells[Coords[0] + 1, Coords[1] + 1] := '·'
            Else
                StringGridUser1.Cells[Coords[0] + 1, Coords[1] + 1] := '·';
            IsHit := False;
        End
    End
    Else
        If (Pos('Введеная координата уже задействована', InstructionLabel.Caption) = 0) Then
            InstructionLabel.Caption := InstructionLabel.Caption + #13#10 +'Введеная координата уже задействована';
End;

Procedure TMainForm.ShootButtonClick(Sender: TObject);
Begin
      If(IsFirstPlayer) Then
          Shoot(InputCoordinates(CoordEdit.Text), StateOfBattleFieldUser2, StateShipsUser2)
      Else
          Shoot(InputCoordinates(CoordEdit.Text), StateOfBattleFieldUser1, StateShipsUser1);
      If Not IsHit Then
      Begin
          IsHit := True;
          SwitchPlayers();
      End;
      CoordEdit.Text := '';
      CountOfInput := 0;
End;

Procedure TMainForm.SwitchPlayers();
Begin
    If(StringGridUser1.Visible = True) Then
    Begin
        StringGridUser1.Visible := False;
        StringGridUser2.Visible := True;
        InstructionLabel.Caption := 'Ход первого игрока';
        IsFirstPlayer := True;
    End
    Else
    Begin
        StringGridUser1.Visible := True;
        StringGridUser2.Visible := False;
        InstructionLabel.Caption := 'Ход второго игрока';
        IsFirstPlayer := False;
    End;
End;

end.
