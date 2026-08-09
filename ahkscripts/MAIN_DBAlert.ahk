#NoEnv
#SingleInstance, Force
SetTitleMatchMode, 2
#MaxThreadsPerHotkey 2
SetWorkingDir, %A_ScriptDir%

global User := " "
global Server := " "
global startHOTKEY := "F1"
global stopHOTKEY := "F2"


IniRead, User, data.ini, usernames, user, %User%
IniRead, Server, data.ini, servers, server, %Server%

IniRead, startHOTKEY, data.ini, UserSettings, startk, %startHOTKEY%
IniRead, stopHOTKEY, data.ini, UserSettings, stopk, %stopHOTKEY%

Hotkey, %startHOTKEY%, StartMonitoring
Hotkey, %stopHOTKEY%, StopMonitoring

Gui, +AlwaysOnTop +Caption +Border +Resize MinSize350x175 +OwnDialogs
Gui, Add, Text,, Username: 
Gui, Add, Edit, vUserEdit gSaveData w120, %User%
Gui, Add, Text,, Server name: 
Gui, Add, Edit, vServerEdit gSaveData w120, %Server%
Gui, Show, Center, DB Alerter (NOT monitoring...)

Gui, Add, Button, vstartB gStartMonitoring w100 h27 xs ys125.5, % "(" . startHOTKEY . ")" "`nStart Monitoring"
Gui, Add, Button, vstopB gStopMonitoring w100 h27 xs100 ys125.5, % "(" . stopHOTKEY . ")" "`nStop Monitoring"
Gui, Add, Button, gHotkeySettingsGUI w100 h27 xs200 ys125.5, Hotkeys 

GuiIcon := DllCall("LoadImage", "Ptr", 0, "Str", "DB-seeker-pfp.ico","UInt",1, "Int", 64, "Int", 64, "UInt", 0x10, "Ptr") ; Rewrite these to something simpler in AHK v2 
TaskbarIcon := DllCall("LoadImage", "Ptr", 0, "Str", "DB-seeker-pfp.ico","UInt",1, "Int", 64, "Int", 64, "UInt", 0x10, "Ptr")

SendMessage, 0x80, 0, GuiIcon,, A
SendMessage, 0x80, 1, TaskbarIcon,, A
Menu, Tray, Icon, DB-seeker-pfp.ico

Gui, 2:New, +AlwaysOnTop +Caption +Border +Resize MinSize225x125  ;Hotkey GUI
Gui, 2:Add, Text,, Start Hotkey: 
Gui, 2:Add, Hotkey, vStartHotkey gSaveHotkeys w80, %startHOTKEY%
Gui, 2:Add, Text,, Stop Hotkey: 
Gui, 2:Add, Hotkey, vStopHotkey gSaveHotkeys w80, %stopHOTKEY%

global startHOTKEYPrev := startHOTKEY
global stopHOTKEYPrev := stopHOTKEY 


return 

HotkeyStates(State){
    Hotkey, %startHOTKEY%, %State% 
    Hotkey, %stopHOTKEY%, %State% 
}

UglyCode: 
    CoordMode, Mouse, Window 
    MouseGetPos, RnX, RnY  
    GuiControlGet, UserEdit, Pos 
    GuiControlGet, ServerEdit, Pos 
    RnX -= 10
    RnY -= 35    
    
    OnGuiElement(RnX, RnY, elementEditX, elementEditY, elementEditW, elementEditH) {
        if ((RnX - elementEditX) < (elementEditW +45) && (RnX - elementEditX) > (-45) && (RnY - elementEditY) < (elementEditH + 45) && (RnY - elementEditY) > (-45)){
            ;MsgBox,0x40000,, % "Touching GUI element"
            ;HotkeyStates("Off")
            return true      
 
        } else {
            ;HotkeyStates("On")
            return false 
        }
    }

    if  OnGuiElement(RnX, RnY, UserEditX, UserEditY, UserEditW, UserEditH) || OnGuiElement(RnX, RnY, ServerEditX, ServerEditY, ServerEditW, ServerEditH) {
        ;MsgBox,0x40000,, % "Touching GUI element"
        HotkeyStates("Off")
    } else {
        HotkeyStates("On")
    }         
return 



HotkeySettingsGUI:
     SetTimer, UglyCode, Off 
     Gui, 2:Show,, Hotkeys
     HotkeyStates("Off") 
return 

2GuiClose:
    Gui, 2:Hide
    HotkeyStates("On") 
    SetTimer, UglyCode, On   
return 

RevertHotkeys:  
    GuiControl, 2:, StartHotkey, %StartHOTKEYPrev%
    startHOTKEY := StartHOTKEYPrev 
    GuiControl, 2:, StopHotkey, %stopHOTKEYPrev%
    stopHOTKEY := StopHOTKEYPrev
return 

SaveHotkeys:        
    Gui, 2:Submit, NoHide
                               
    HotkeySet := [StartHotkey, StopHotkey] 
    for _,hkey in HotkeySet {
        if (hkey = "" or hkey = " ") || (hkey = "!" or hkey = "^" or hkey = "+" or hkey = "^!"){
            Goto, RevertHotkeys 
            ;MsgBox,0x40000, % " "

        }
    }  
    ;no native AlphaNum checker, so gotta do it myself 
    ;MsgBox,0x40000,, % StartHotkey 
    HotkeySetAll := [StartHotkey, StopHotkey]
    i_start := 1   ; works based on a (n(n-1))/ 2 formula of comparisons for checking duplicates rather than doing n^2 (Basically sigma summmation)  
    while (i_start < (HotkeySetAll.Length())){
        i_end := HotkeySetAll.Length()
        while (i_end > i_start) {
            if HotkeySetAll[i_start] = HotkeySetAll[i_end] {
                Gosub, RevertHotkeys
                Gui +Disabled 
                MsgBox,0x40030,% "Duplicate Hotkey", % "Hotkey already in use!", 1.3
                Gui -Disabled 
                return 
            }  
            i_end -= 1
        }
        i_start += 1
    }
    
    startHOTKEY := StartHotkey
    stopHOTKEY := StopHotkey 
    
    StartHOTKEYPrev := startHOTKEY 
    StopHOTKEYPrev := stopHOTKEY 
    
    IniWrite, %startHOTKEY%, data.ini, UserSettings, startk
    IniWrite, %stopHOTKEY%, data.ini, UserSettings, stopk

    Hotkey, %startHOTKEY%, StartMonitoring, Off 
    Hotkey, %stopHOTKEY%, StopMonitoring, Off 
    GuiControl, 1:, startB, %startHOTKEY% (Start)
    GuiControl, 1:, stopB, %stopHOTKEY% (Stop)
 
return


SaveData:
    Gui Submit, NoHIde 

    User := UserEdit 
    Server := ServerEdit
    IniWrite, %User%, data.ini, usernames, user 
    IniWrite, %Server%, data.ini, servers, server  

return 

StartMonitoring:
    if !WinExist("Roblox"){
        MsgBox, Please have the roblox window open.
        return
    }
    Gui, Hide 
    Gui, Show, , DB Alerter (MONITORING!)
    Sleep, 500
    Gui, Minimize
    SetTimer, AntiAFK, 300000 ; 5 mins
    SetTimer, DBPixelFinder, 75
    SetTimer, UglyCode, Off 
return 

StopMonitoring:
    Gui, Hide
    Gui, Show, , DB Alerter (NOT monitoring...)
    SetTimer, AntiAFK, Off
    SetTimer, UglyCode, On             
return 

AntiAFK:
    Send, {m}
    Sleep, 500
    Send, {m}
    Sleep, 500
    Send, {Left}
    Sleep, 500
    Send, {Right}
return 

AlertTheBoys:
    disc_webhook := "https://discord.com/api/webhooks/1535589167373881354/VOIzzmGNx3ctHqKlCal9DaM4LAYOM2V99x_NFkVKMs-I0zIIacV-wcHJvQivwSzpk2cy"

    json := "{""content"":""@everyone DB located in SERVER_NAME by PLAYER""}"
    json := StrReplace(json, "SERVER_NAME by PLAYER", Server . " by " . User)

    alerter := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    alerter.Open("POST", disc_webhook, false)
    alerter.SetRequestHeader("Content-Type", "application/json")
    alerter.Send(json)
return 

DBPixelFinder:  
    TargetPixel := 0x94A430
    WinGetPos, winX, winY, winW, winH, Roblox 
    CoordMode, Pixel, Window
    PixelSearch, px, py
    , winX + (winW * 0.75), winY  
    , winX + (winW), winY + (winH * 0.4) 
    , TargetPixel 
    , 3
    , Fast RGB 
    if (ErrorLevel = 0){ 
        SetTimer, DBPixelFinder, Off
        MouseMove, px, py
        Gosub, AlertTheBoys
        Goto, StopMonitoring 
    } 
return 