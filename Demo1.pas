program Demo1;

{A basic demo program to show some basic features of Pascal Programming on vintage Macs - 2019, BSS}

{$R-}
{$I-}
{$B+}
{$R demo1.rsrc}
{$T APPLDMO1}
{$U-}

Uses PasInOut,MemTypes,QuickDraw,OSIntf,ToolIntf,PackIntf,SANE;


var
    theEvent: EventRecord;
    MainWindow,FrontWindow: WindowPtr;
    DragArea,GoBtnArea: Rect;
    Finished: Boolean;
    MainRec: WindowRecord;
    MainPeek: WindowPeek;
    AppMenu: MenuHandle;
    GoBtn: ControlHandle;
    DemoDlg: DialogPtr;
    DemoDlgPeek: DialogPeek;
    ScreenPort: GrafPtr;
    
procedure ClearWindow(WPtr:WindowPtr);
var
    TRect: Rect;
begin
    {If the window is ours and its infront}
    if (WPtr = MainWindow) and (WPtr = FrontWindow) then
        EraseRect(WPtr^.portRect);
end;

{Launch a desk accessory based on menu item number}
procedure DoDeskAcc(Item:Integer);
var
    SavePort: GrafPtr;
    RefNum: Integer;
    DName: String;
begin
    GetPort(SavePort);
    GetItem(AppMenu,Item,DName);
    RefNum := OpenDeskAcc(DName);
    SetPort(SavePort);
end;

{Handle menu item clicks - in this case either show the about dialog or launch
the appropriate desk accessory}
procedure HandleMenu(MenuInfo:LongInt);
var 
    Item: Integer;
    AboutDlg: DialogPtr;
begin
    if LoWord(MenuInfo) = 1 then
    begin {show the about dialog}
        AboutDlg := GetNewDialog(1000,NIL,Pointer(-1));
        HiliteMenu(0);
        SetPort(AboutDlg);
        ShowWindow(AboutDlg);
        repeat
            ModalDialog(NIL,Item);
        until Item = OK;
        HideWindow(AboutDlg);
    end
    else if MenuInfo <> 0 then
    begin {launch a desk accessory}
        PenNormal;
        DoDeskAcc(LoWord(MenuInfo));
        HiliteMenu(0);
    end;
end;

procedure HandleClick(WPtr:WindowPtr;MLoc:Point);
var
    theControl: ControlHandle;
    SavePort,AboutDlg: WindowPtr;
    i,Item: Integer;
begin
    if WPtr = MainWindow then
    begin
        {bring the clicked window to the front if necessary}
        if WPtr <> FrontWindow then
            SelectWindow(WPtr);
            
        GetPort(SavePort);
        SetPort(MainWindow);
        GlobalToLocal(MLoc);
        
        {Find the control revieving the mouseDown. i=0 for no control (empty window space)}
        i := FindControl(MLoc,WPtr,theControl);
        
        {trying to track a click on no control will cause the system 
        to crash spectacularly. If no control was clicked exit before that happens}
        if i = 0 then exit;
        
        {Track the control. This tracks the mouse until it is released (incase of drag)
        i=0 if the user released the mouse after dragging OFF the control}
        i := TrackControl(theControl,MLoc,NIL);
        
        {if the user clicked the go button and released the mouse while still on the button, 
        show a dialog}
        if (theControl = GoBtn) and (i <> 0) then
        begin
            AboutDlg := GetNewDialog(1000,NIL,Pointer(-1));
            SetPort(AboutDlg);
            ShowWindow(AboutDlg);
            repeat {just wait until user presses 'OK'}
                ModalDialog(NIL,Item);
            until Item = OK;
            HideWindow(AboutDlg);
        end;
        SetPort(SavePort);
    end;
end;

{the go away box is the close box at the top left of the window}
procedure HandleGoAway(WPtr:WindowPtr;MLoc:Point);
var
    WPeek: WindowPeek;
begin
    if WPtr = FrontWindow then
    begin
        WPeek := WindowPeek(WPtr);
        if TrackGoAway(WPtr,MLoc) then {make sure the user releases the mouse inside the go away box}
            if WPeek^.WindowKind = UserKind then
                Finished := true {this will cause the event loop to exit, ending the program}
            else CloseDeskAcc(WPeek^.WindowKind);
    end
    else SelectWindow(WPtr); {if the window wasnt infront, put it infront}
end;
  
{any mouse down events for the whole screen come here, split them up based on where they happened}  
procedure HandleMouseDown(theEvent:EventRecord);
var
    theWindow: WindowPtr;
    MLoc: Point;
    WLoc: Integer;
begin
    MLoc := theEvent.Where;
    WLoc := FindWindow(MLoc,theWindow);
    case WLoc of
        InMenuBar: HandleMenu(MenuSelect(MLoc));
        InContent: HandleClick(theWindow,MLoc); {the mouse was pressed in the actual content of our window}
        InGoAway: HandleGoAway(theWindow,MLoc); {mousedown in the close box at the top left}
        InDrag: DragWindow(theWindow,MLoc,DragArea); {move the window if the user is dragging it}
        InSysWindow: SystemClick(theEvent,theWindow); {we have to tell the system if someone cliked in one of its windows}
    end;
end;

{update the window, this is called when the system sends us an update event}
procedure HandleUpdate(theEvent:EventRecord);
var 
    SavePort,theWindow: WindowPtr;
begin
    theWindow := WindowPtr(theEvent.Message);
    if theWindow = MainWindow then
    begin
        GetPort(SavePort);
        SetPort(theWindow);
        BeginUpdate(theWindow);
        ClearWindow(theWindow);
        DrawControls(theWindow);
        EndUpdate(theWindow);
        SetPort(SavePort);
    end;
end;

{set our window as the front window, called when the system sends us an activate event}
procedure HandleActivate(theEvent:EventRecord);
var
    AFlag: Boolean;
    theWindow: WindowPtr;
begin
    with theEvent do
    begin
        theWindow := WindowPtr(Message);
        AFlag := Odd(Modifiers);
        if AFlag then
        begin
            SetPort(theWindow);
            FrontWindow := theWindow;
        end
        else
        begin
            SetPort(ScreenPort);
            if theWindow = FrontWindow then
                FrontWindow := NIL;
        end;
        if theWindow = MainWindow then
            DrawMenuBar;
    end;
end;
    
    
procedure HandleEvent(theEvent:EventRecord);
begin
    case theEvent.What of {dispatch event handlers based on event type}
        MouseDown: HandleMouseDown(theEvent);
        UpdateEvt: HandleUpdate(theEvent);
        ActivateEvt: HandleActivate(theEvent);
    end;
end;

procedure Init;
var 
    ScreenArea: Rect;
begin
    InitGraf(@thePort);
    InitFonts;
    InitWindows;
    InitMenus;
    TEInit;
    InitDialogs(NIL);
    FlushEvents(everyEvent,0);
    
    {load the menu fron resources (menu resource ID 1000) and add it to the menubar}
    AppMenu := GetMenu(1000);
    AddResMenu(AppMenu,'DRVR');
    InsertMenu(AppMenu,0);
    DrawMenuBar;
    
    GetWMgrPort(ScreenPort);
    SetPort(ScreenPort);
    MainWindow := GetNewWindow(1000,@MainRec,Pointer(-1));
    SetPort(MainWindow);
    FrontWindow := MainWindow;
    MainPeek := WindowPeek(MainWindow);
    MainPeek^.WindowKind := UserKind;
    
    {set up the region for dragging the window}
    ScreenArea := ScreenBits.Bounds;
    with ScreenArea do
    begin
        SetRect(DragArea,5,25,Right-5,Bottom-10);
    end;
    
    {set the bounds and create a button}
    SetRect(GoBtnArea,50,50,100,100);
    GoBtn := NewControl(MainWindow,GoBtnArea,'Go!',true,0,0,0,0,1000);
    
    SetCursor(Arrow);
    Finished := False;
end;

procedure CleanUp;
begin
    DisposeWindow(MainWindow);
end;

begin
    Init;
    repeat
        SystemTask; {allow the system to perform tasks if it has any, COOPERATIVE multitasking!}
        if GetNextEvent(EveryEvent,theEvent) then
            HandleEvent(theEvent);
    until Finished;
    CleanUp;
end.